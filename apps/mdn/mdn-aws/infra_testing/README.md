MDN K8s infra tests
========================

```
# install deps
make init

source ../k8s/regions/portland/stage.sh
# or
source ../k8s/regions/portland/prod.sh
make test
```

> NOTE: Do NOT include test failure output in log files as it will contain sensitive information!
