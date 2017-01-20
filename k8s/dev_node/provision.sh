KOPS_URL="https://github.com/kubernetes/kops/releases/download/1.5.0-alpha3/kops-linux-amd64"

sudo apt -y update
sudo apt -y upgrade

sudo apt -y install git jq python3 python3-pip curl silversearcher-ag
sudo usermod -a -G docker admin


# Download and install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Download and install kops
wget ${KOPS_URL}
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops
