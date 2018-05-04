FROM python:3-slim

# from https://github.com/mozmeao/docker-pythode/blob/master/Dockerfile.footer

# Extra python env
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# add non-priviledged user
RUN adduser --uid 1000 --disabled-password --gecos '' --no-create-home blocker

# end from Dockerfile.footer

WORKDIR /app

# Install app
COPY block_aws.py /app/block_aws.py
COPY block-aws-networkpolicy.yaml /app/block-aws-networkpolicy.yaml
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install kubectl
# to get latest version: "curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt"
ENV KUBECTL_VERSION="v1.10.1"
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

CMD ["python", "/app/block_aws.py"]

# Change User
RUN chown blocker.blocker -R .
USER blocker

