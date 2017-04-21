stage('kubectl apply') {
  sh 'kubectl config use-context virginia'
  env.GIT_COMMIT_SHORT = 'a3a53b7'
  env.MEMCACHED_RELEASE = 'mdn-dev'
  env.MYSQL_RELEASE = 'manageable-puffin'
  //TODO use j2 from docker to eliminate system dependency
  sh 'j2 mdn/k8s/mdn-dev.yaml.jinja | kubectl apply -n mdn-dev -f -'
}
