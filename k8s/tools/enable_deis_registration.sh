#!/bin/bash
kubectl --namespace=deis patch deployments deis-controller -p '{"spec":{"template":{"spec":{"containers":[{"name":"deis-controller","env":[{"name":"REGISTRATION_MODE","value":"enabled"}]}]}}}}'
