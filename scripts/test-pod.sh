#!/bin/bash

kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl backend-service/