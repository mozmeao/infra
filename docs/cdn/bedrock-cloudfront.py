from diagrams import Cluster, Diagram, Edge
from diagrams.aws.network import Route53, CloudFront, ELB
from diagrams.aws.storage import S3
from diagrams.generic.blank import Blank
from diagrams.gcp.network import LoadBalancing
from diagrams.k8s.compute import Deployment

from diagrams.generic.blank import Blank

domain_name_dev = "mozorg-dev.moz.works"
domain_name_stage = "mozorg-stage.moz.works"
prod_domain_name = "mozorg.moz.works"

with Diagram("Bedrock Dev Cloudfront", show=True):

    with Cluster("Cloudfronts"):
        www_dev = CloudFront("www-dev")

    # Mapping domains to subportions of cloudfront
    with Cluster("External DNS Names"):
        Blank(width="4", height="0")
        Route53(f"www-dev.{domain_name_dev}") >> www_dev

    with Cluster("Destinations"):
        with Cluster("bedrock-dev.gcp.moz.works\niowa-a gke"):
            www_dev >> LoadBalancing("DEV") >> Deployment("DEV")

        # media buckets
        www_dev >> Edge(label="\nmedia/*") >> S3("bedrock-dev-media")


with Diagram("Bedrock Staging Cloudfront", show=True):

    with Cluster("Staging Cloudfronts"):
        www = CloudFront("www")

    # Mapping domains to subportions of cloudfront
    with Cluster("External DNS Names"):
        Blank(width="4", height="0")
        Route53(f"www.{domain_name_stage}") >> www

    with Cluster("Destinations"):
        # bedrock itself, using dns to send traffic around
        with Cluster("bedrock-stage.gcp.moz.works\niowa-a gke"):
            www >> LoadBalancing("STG") >> Deployment("STG")
        with Cluster("bedrock-stage.frankfurt.moz.works\nfrankfurt aws"):
            www >> ELB("STG") >> Deployment("STG")

        # media buckets
        www >> Edge(label="media/*\n") >> S3("bedrock-media")


with Diagram("Bedrock Prod Cloudfront", show=True):

    with Cluster("Prod Cloudfronts"):
        www = CloudFront("www")

    # Mapping domains to subportions of cloudfront
    with Cluster("External DNS Names"):
        Blank(width="4", height="0")
        Route53(f"www.{prod_domain_name}") >> www

    with Cluster("Destinations"):
        # bedrock itself, using dns to send traffic around
        with Cluster("bedrock-prod.gcp.moz.works\niowa-a gke"):
            www >> LoadBalancing("PROD") >> Deployment("PROD")
        with Cluster("bedrock-prod.frankfurt.moz.works\nfrankfurt aws"):
            www >> ELB("PROD") >> Deployment("PROD")

        # media buckets
        www >> Edge(label="media/*\n") >> S3("bedrock-media")
