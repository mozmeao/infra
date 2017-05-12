stage('virginia') {
  sh 'kubectl config use-context virginia'
  //TODO use j2 from docker to eliminate system dependency
  sh '. virginia-env && j2 mdn/k8s/mdn-dev.yaml.jinja | kubectl apply -n mdn-dev -f -'
}
