from quay.io/mozmar/base:latest

ENV AWS_ACCESS_KEY_ID setme
ENV AWS_SECRET_ACCESS_KEY setme
ENV LOCAL_DIR /data
ENV REMOTE_DIR /backups/
ENV BUCKET s3://mdn-shared-backup

# set to either PUSH or PULL
ENV PUSH_OR_PULL PUSH

WORKDIR /meaosync

RUN apt update && apt -y upgrade && apt install -y python3-pip curl
RUN pip3 install awscli --upgrade --user
RUN pip3 install --upgrade pip

# add awscli to the path
ENV PATH="/root/.local/bin/:${PATH}"

ADD efs_sync.sh /meaosync/efs_sync.sh
CMD ["/meaosync/efs_sync.sh"]
