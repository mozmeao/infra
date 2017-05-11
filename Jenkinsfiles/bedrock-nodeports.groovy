stage('virginia') {
  sh 'kubectl config use-context virginia'
  sh 'kubectl apply -n bedrock-stage -f apps/bedrock/k8s/bedrock-stage-nodeport.yaml'
  sh 'kubectl apply -n bedrock-prod -f apps/bedrock/k8s/bedrock-prod-nodeport.yaml'
}

stage('tokyo') {
  sh 'kubectl config use-context tokyo'
  sh 'kubectl apply -n bedrock-stage -f apps/bedrock/k8s/bedrock-stage-nodeport.yaml'
  sh 'kubectl apply -n bedrock-prod -f apps/bedrock/k8s/bedrock-prod-nodeport.yaml'
}
