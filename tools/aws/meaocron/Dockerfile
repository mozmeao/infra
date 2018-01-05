FROM python:3.6-slim

# from https://github.com/mozmeao/docker-pythode/blob/master/Dockerfile.footer

# Extra python env
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# add non-priviledged user
RUN adduser --uid 1000 --disabled-password --gecos '' --no-create-home webdev

# Add apt script
COPY docker/bin/apt-install /usr/local/bin/

RUN apt-install curl

#CMD [ "python", "./your-daemon-or-script.py" ]