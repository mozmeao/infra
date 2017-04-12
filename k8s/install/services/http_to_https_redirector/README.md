# MozMEAO http->https redirector

### Building the image

```shell
make image
```

### Deploying the service

```shell
make deploy
```

http is automatically redirected to https for ELBs configured via elbs/tf/elb_utils.sh


