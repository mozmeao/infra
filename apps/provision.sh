#!/bin/bash

k8s_apps=(basket bedrock careers mdn nucleus snippets surveillance)
for app in ${k8s_apps[@]}; do
  echo "-> ${app}"
done

### TODO: monitoring!!!

