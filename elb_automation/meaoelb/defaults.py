from meaoelb.config import *


class ELBConfigDefaults:
    """
    This class can generate a default ELB config from a set of supplied values,
    including listeners and healthchecks
    """

    def __init__(
            self,
            elb_ctx,
            target_cluster,
            asg_name=None,
            vpc_id=None,
            subnet_ids=None):
        self.elb_ctx = elb_ctx
        self.target_cluster = target_cluster
        self.asg_name = asg_name
        self.vpc_id = vpc_id
        self.subnet_ids = subnet_ids

    def default_health_check(self, service_namespace, service_name):
        """
        Generate a health check using the services nodeport
        """
        service_nodeport = self.elb_ctx.get_service_nodeport(
            service_namespace, service_name)
        return ELBHealthCheckConfig(
            target_path='/',
            target_port=service_nodeport,
            target_proto='HTTP',
            healthy_threshold=2,
            unhealthy_threshold=6,
            timeout=5,
            interval=10)

    def default_redirector_listener(self):
        """
        Generate a ELB listener using the redirector nodeport
        """
        redirector_port = self.elb_ctx.get_redirector_service_nodeport()
        return ELBListenerConfig(
            protocol='HTTP',
            load_balancer_port=80,
            instance_protocol='HTTP',
            instance_port=redirector_port,
            ssl_arn=None)

    def default_service_listener(
            self,
            service_namespace,
            service_name,
            ssl_arn=None,
            protocol='HTTPS',
            port=443):
        """
        Generate a ELB listener using the services nodeport
        """
        service_nodeport = self.elb_ctx.get_service_nodeport(
            service_namespace, service_name)
        return ELBListenerConfig(
            protocol=protocol,
            load_balancer_port=port,
            instance_protocol='HTTP',
            instance_port=service_nodeport,
            ssl_arn=ssl_arn)


    def default_elb_config(self,
                           service_namespace,
                           service_name,
                           vpc_id,
                           subnet_ids,
                           ssl_arn):
        """
        Generate an ELB configuration using the supplied values.
        Return value must be used as a child of a ServiceConfig.
        """

        redirector_listener = self.default_redirector_listener()
        service_listener = self.default_service_listener(
            service_namespace, service_name, ssl_arn)
        listeners = [redirector_listener, service_listener]
        health_check = self.default_health_check(
            service_namespace, service_name)
        security_groups = [self.elb_ctx.get_elb_access_security_group(vpc_id)]
        tags = [{'Key': 'Stack',
                 'Value': service_namespace},
                {'Key': 'KubernetesCluster',
                 'Value': self.elb_ctx.get_cluster_name()}]

        return ELBConfig(
            service_namespace,
            listeners,
            security_groups,
            subnet_ids,
            tags,
            health_check)

    def default_elb_config_http(self,
                                service_namespace,
                                service_name,
                                vpc_id,
                                subnet_ids,
                                ssl_arn):
        """
        Generate an ELB configuration using the supplied values.
        Both 80 and 443 listeners use the same K8s nodeport, the
        K8s redirector service is not used.
        Return value must be used as a child of a ServiceConfig.
        """
        http_service_listener = self.default_service_listener(
            service_namespace, service_name, protocol='HTTP', port=80)
        https_service_listener = self.default_service_listener(
            service_namespace, service_name, ssl_arn)
        listeners = [http_service_listener, https_service_listener]
        health_check = self.default_health_check(
            service_namespace, service_name)
        security_groups = [self.elb_ctx.get_elb_access_security_group(vpc_id)]
        tags = [{'Key': 'Stack',
                 'Value': service_namespace},
                {'Key': 'KubernetesCluster',
                 'Value': self.elb_ctx.get_cluster_name()}]

        return ELBConfig(
            service_namespace,
            listeners,
            security_groups,
            subnet_ids,
            tags,
            health_check)


    def generic_service_config(self,
                               target_cluster,
                               service_namespace,
                               service_name,
                               vpc_id,
                               subnet_ids,
                               ssl_arn):
        """
        Generate a service config, supplying most values.
        See default_service_config
        """
        elb_config = self.default_elb_config(
            service_namespace,
            service_name,
            vpc_id,
            subnet_ids,
            ssl_arn)
        return ServiceConfig(
            namespace=service_namespace,
            name=service_name,
            target_cluster=target_cluster,
            elb_config=elb_config,
            vpc_id=vpc_id,
            subnet_ids=subnet_ids)


    def default_service_config(self,
                               service_namespace,
                               service_name,
                               ssl_arn):
        """
        Generate a service config using defaults supplied to the ConfigDefaults
        constructor
        """
        elb_config = self.default_elb_config(
            service_namespace,
            service_name,
            self.vpc_id,
            self.subnet_ids,
            ssl_arn)
        return ServiceConfig(
            namespace=service_namespace,
            name=service_name,
            target_cluster=self.target_cluster,
            elb_config=elb_config,
            vpc_id=self.vpc_id,
            subnet_ids=self.subnet_ids)


    def default_service_config_http(self,
                               service_namespace,
                               service_name,
                               ssl_arn):
        """
        Generate a service config using defaults supplied to the ConfigDefaults
        constructor. Both 80 and 443 listeners use the same K8s nodeport, the
        K8s redirector service is not used.
        """
        elb_config = self.default_elb_config_http(
            service_namespace,
            service_name,
            self.vpc_id,
            self.subnet_ids,
            ssl_arn)
        return ServiceConfig(
            namespace=service_namespace,
            name=service_name,
            target_cluster=self.target_cluster,
            elb_config=elb_config,
            vpc_id=self.vpc_id,
            subnet_ids=self.subnet_ids)

