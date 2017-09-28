from quay.io/mozmar/base:latest

ENV AWS_ACCESS_KEY_ID setme
ENV AWS_SECRET_ACCESS_KEY setme
ENV LOCAL_DIR /data
ENV REMOTE_DIR /backups/
ENV BUCKET s3://mdn-shared-backup

# set to either PUSH or PULL
ENV PUSH_OR_PULL PUSH

# install packages
RUN apt update && apt -y upgrade && apt install -y python3-pip curl

RUN groupadd --gid 1000 kuma
RUN useradd -ms /bin/bash --uid 1000 --gid 1000 kuma
USER kuma:kuma

WORKDIR /mdnsync
RUN pip3 install awscli --upgrade --user
#RUN pip3 install --upgrade pip


ENV PATH="/home/kuma/.local/bin/:${PATH}"
ADD mdn_sync.sh /mdnsync/mdn_sync.sh
CMD ["/mdnsync/mdn_sync.sh"]
