FROM python:3.6-slim

# from https://github.com/mozmeao/docker-pythode/blob/master/Dockerfile.footer

# Extra python env
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# add non-priviledged user
RUN adduser --uid 1000 --disabled-password --gecos '' --no-create-home webdev
WORKDIR /meaocron

# Add apt script
COPY docker/bin/apt-install /usr/local/bin/

COPY cron.py /meaocron/cron.py
COPY requirements.txt /meaocron/requirements.txt
RUN pip install --no-cache-dir -r /meaocron/requirements.txt

RUN apt-install curl

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

CMD [ "python", "-m", "meaocron.cron" ]