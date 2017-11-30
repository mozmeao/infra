# -*- coding: utf-8 -*-

import boto3
from kubernetes import client, config
import os
import pytest

# fixtures starting with k8s_ return K8s API objects
#   documented here: https://github.com/kubernetes-incubator/client-python/blob/master/kubernetes/README.md
# fixtures starting with aws_ return boto3 objects
#   documented here: http://boto3.readthedocs.io/en/latest/index.html


@pytest.fixture(scope="module")
def k8s():
    """A Kubernetes client"""
    config.load_kube_config(os.environ['KUBECONFIG'])
    return client.CoreV1Api()


def k8s_web_service():
    """Returns the MDN web service K8s object"""
    services = k8s().list_namespaced_service(os.environ['K8S_NAMESPACE'])
    web_service = [
        elb for elb in services.items if elb.metadata.name == 'web'][0]
    return web_service


@pytest.fixture(scope="module")
def k8s_web_service_elb_hostname():
    """returns the first chunk of the elb name for the web service"""
    elb_hostname = k8s_web_service().status.load_balancer.ingress[0].hostname
    # an unsafe way to split the domain by . and then by -
    return elb_hostname.split(".")[0].split("-")[0]


@pytest.fixture(scope="module")
def k8s_web_service_ssl_port():
    """returns the K8s SSL port object"""
    return [k8s_port for k8s_port in k8s_web_service().spec.ports
            if k8s_port.port == 443][0]


@pytest.fixture(scope="module")
def k8s_redirector_port():
    """returns the K8s nodeport object for the redirector service"""
    services = k8s().list_namespaced_service('redirector')
    redirector_service = [elb for elb in services.items
                          if elb.metadata.name == 'redirector'][0]
    http_port = [port for port in redirector_service.spec.ports
                 if port.name == 'http'][0]
    return http_port


@pytest.fixture(scope="module")
def aws_elb_client():
    """returns a boto3 ELB client"""
    return boto3.client('elb', region_name=os.environ['AWS_REGION'])


@pytest.fixture(scope="module")
def aws_ec2_client():
    """returns a boto3 EC2 client"""
    return boto3.client('ec2', region_name=os.environ['AWS_REGION'])


@pytest.fixture(scope="module")
def aws_elb_security_group():
    """returns the boto3 object representing the elb_access security group"""
    result = aws_ec2_client().describe_security_groups(
        Filters=[{'Name': 'group-name', 'Values': ['elb_access']}])
    return result['SecurityGroups'][0]['GroupId']


@pytest.fixture(scope="module")
def aws_web_service_elb_attributes():
    """returns the boto3 object representing elb attributes for the MDN web service"""
    response = aws_elb_client().describe_load_balancer_attributes(
        LoadBalancerName=k8s_web_service_elb_hostname())
    return response


@pytest.fixture(scope="module")
def aws_web_service_elb():
    elb_host = k8s_web_service_elb_hostname()
    result = aws_elb_client().describe_load_balancers(
        LoadBalancerNames=[elb_host])
    return result['LoadBalancerDescriptions'][0]


class TestELB(object):
    def test_k8s_connection(self):
        assert k8s_web_service_elb_hostname() is not None

    def test_aws_connection(self):
        assert aws_elb_security_group() is not None

    def test_elb_listeners(self):
        elb = aws_web_service_elb()
        # there should be http and https listeners
        assert len(elb['ListenerDescriptions']) == 2
        listeners = elb['ListenerDescriptions']

        # get the listner using port 80
        http = [l for l in listeners
                if l['Listener']['LoadBalancerPort'] == 80][0]
        assert http is not None
        # check configured protocol
        assert http['Listener']['Protocol'] == 'TCP'
        # check that elb port 80 is pointing at the internal redirector service
        # node port
        assert http['Listener']['InstancePort'] == k8s_redirector_port().node_port

        https = [l for l in listeners
                 if l['Listener']['LoadBalancerPort'] == 443][0]
        assert https is not None
        # check configured protocol
        assert https['Listener']['Protocol'] == 'HTTPS'
        # check that elb port 443 is pointing at the internal mdn web service
        # node port
        assert https['Listener']['InstancePort'] == k8s_web_service_ssl_port(
        ).node_port

    def test_elb_security_group(self):
        elb = aws_web_service_elb()
        # is the ELB in the correct security group?
        assert aws_elb_security_group() in elb['SecurityGroups']

    def test_elb_timeout(self):
        # is the ELB IdleTimeout set correctly?
        elb_timeout = aws_web_service_elb_attributes(
        )['LoadBalancerAttributes']['ConnectionSettings']['IdleTimeout']
        assert elb_timeout == int(os.environ['WEB_GUNICORN_TIMEOUT'])

    def test_elb_logging(self):
        # is logging enabled?
        elb_logging = aws_web_service_elb_attributes(
        )['LoadBalancerAttributes']['AccessLog']
        assert elb_logging['Enabled'] is True
