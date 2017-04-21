stage('virginia') {
  sh 'kubectl config use-context virginia'
  env.GIT_COMMIT_SHORT = 'a3a53b7'
  env.MEMCACHED_RELEASE = 'mdn-dev'
  env.MYSQL_RELEASE = 'manageable-puffin'
  //TODO use j2 from docker to eliminate system dependency
  sh 'j2 mdn/k8s/mdn-dev.yaml.jinja | kubectl apply -n mdn-dev -f -'
}

stage('tokyo') {
  sh 'kubectl config use-context tokyo'
  env.GIT_COMMIT_SHORT = 'a3a53b7'
  //TODO helm install memchachd
  env.MEMCACHED_RELEASE = 'mdn-dev'
  //TODO helm install mysql
  env.MYSQL_RELEASE = 'mdn-dev'
  //TODO use j2 from docker to eliminate system dependency
  //TODO create mdn-dev namespace
  sh 'j2 mdn/k8s/mdn-dev.yaml.jinja | kubectl apply -n mdn-dev -f -'
}
