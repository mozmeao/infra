FROM debian:jessie-slim


# postgresql-client fails to install in slim if this man directory doesn't exist
# bash expansion man{1,7} doesn't work here
RUN mkdir -p /usr/share/man/man1 && mkdir -p /usr/share/man/man7
RUN apt update && apt -y upgrade && apt install -y curl mysql-client openssl postgresql-client python unzip
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip && \
     ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
     rm -rf ./awscli-bundle
COPY ./rdsbackup.sh /usr/bin/
RUN mkdir /backup
CMD ["/usr/bin/rdsbackup.sh"]
