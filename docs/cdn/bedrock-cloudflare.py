from diagrams import Cluster, Diagram, Edge
from diagrams.saas.cdn import Cloudflare
from diagrams.k8s.compute import Deployment
from diagrams.k8s.network import SVC
from diagrams.aws.general import User
from diagrams.aws.network import Route53, ELB
from diagrams.gcp.network import LoadBalancing
from diagrams.k8s.compute import Pod, RS, DS, Deployment
from diagrams.k8s.storage import Vol


with Diagram("Bedrock Cloudflare", show=True):

    with Cluster("Cloudflare"):
        mozcf = Cloudflare("Moz.org")

    User("User") >> Edge(label="www.mozilla.org") >> mozcf

    # traffic policy
    tp = Route53("Traffic Policy")

    mozcf >> Edge(label="bedrock.prod.moz.works") >> tp

    # dns for each cluster
    with Cluster("AWS Frankfurt"):
        tp >> Edge(label="bedrock-prod.frankfurt.moz.works") >> ELB("frankfurt") >> SVC("bedrock-prod") >> Deployment("bedrock-prod")

    with Cluster("GCP Iowa"):
        tp >> Edge(label="bedrock-prod.gcp.moz.works") >> LoadBalancing("iowa-a") >> SVC("bedrock-prod") >> Deployment("bedrock-prod")

with Diagram("Bedrock k8s setup", show=True):

    np = SVC("Bedrock Nodeport")

    with Cluster("Bedrock Web"):
        web = Pod("Bedrock Web")
        Deployment("Bedrock Web") >> RS("Bedrock Web") >> web

    with Cluster("Bedrock Data"):
        data = Pod("Bedrock Data")
        DS("Bedrock Data") >> data

    with Cluster("GeoIP"):
        geoip = Pod("Bedrock GeoIP")
        DS("Bedrock GeoIP") >> geoip

    data >> Vol("data volume") << web
    geoip >> Vol("geo volume") << web

    np >> web
