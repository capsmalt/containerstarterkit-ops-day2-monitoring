#!/bin/bash

oc project handson
oc new-app --name='httpd' httpd~./text
sleep 60
oc start-build httpd --from-dir=./text
oc expose svc httpd

#oc delete is,bc,dc,svc,route -l app=httpd
