FROM python:3-slim

# from https://github.com/mozmeao/docker-pythode/blob/master/Dockerfile.footer

# Extra python env
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# add non-priviledged user
RUN adduser --uid 1000 --disabled-password --gecos '' --no-create-home webdev

# end from Dockerfile.footer

WORKDIR /app

# Install app
COPY block-aws.py /app/block-aws.py
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "/app/block-aws.py"]

# Change User
RUN chown webdev.webdev -R .
USER webdev

