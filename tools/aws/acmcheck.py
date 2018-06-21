# This script shows all ACM certs for a set of regions, including the method of validation
# and aws resources that use a cert.

import boto3
from munch import Munch
import sys
import csv

FIELDS = ['region', 'domain_name', 'arn', 'validation_method', 'used_by', 'not_after']

def check_region(region_name):
    acm_client = boto3.client('acm', region_name=region_name)
    certs = Munch.fromDict(acm_client.list_certificates())
    
    for c in certs.CertificateSummaryList:
        cert_def = Munch.fromDict(acm_client.describe_certificate(CertificateArn=c.CertificateArn))
        region_cert = { 'region': region_name,
                        'domain_name': c.DomainName,
                        'arn': c.CertificateArn,
                        'validation_method': cert_def.Certificate.DomainValidationOptions[0].ValidationMethod,
                        'used_by': cert_def.Certificate.InUseBy}
        writer.writerow(region_cert)

writer = csv.DictWriter(sys.stdout, fieldnames=FIELDS, dialect='excel-tab')
writer.writeheader()

check_region('us-west-2')
check_region('eu-central-1')
check_region('ap-northeast-1')
