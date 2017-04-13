image:
	docker build -t quay.io/mozmar/redirector .
	docker push quay.io/mozmar/redirector

deploy:
	kubectl create namespace redirector
	kubectl -n redirector create configmap redirector-config --from-file=redirector-config=redirector.conf
	kubectl -n redirector create -f ./deployment.yaml
	kubectl -n redirector create -f service.yaml
