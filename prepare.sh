#!/bin/bash

if test $# != 3;then
 echo "prepare.sh <guid> <sandboxzone> <usernum>"
 exit
fi

GUID=$1
SANDBOXZONE=$2
USERNUM=$3
HANDSON_NAMESPACE="handson"

oc new-project $HANDSON_NAMESPACE

oc process postgresql-persistent --param POSTGRESQL_USER=ether --param POSTGRESQL_PASSWORD=ether --param POSTGRESQL_DATABASE=etherpad --param POSTGRESQL_VERSION=10 --param VOLUME_CAPACITY=4Gi --labels=app=etherpad_db -n openshift | oc apply -f -
oc process -f https://raw.githubusercontent.com/wkulhanek/docker-openshift-etherpad/master/etherpad-template.yaml -p DB_TYPE=postgres -p DB_HOST=postgresql -p DB_PORT=5432 -p DB_DATABASE=etherpad -p DB_USER=ether -p DB_PASS=ether -p ETHERPAD_IMAGE=quay.io/wkulhanek/etherpad:1.8.4 -p ADMIN_PASSWORD=secret | oc apply -f -

for userid in $(seq ${USERNUM}); do
    echo user$userid
    oc login -u user${userid} -p openshift $(oc whoami --show-server)
    users+=("user${userid}")
done

oc login -u opentlc-mgr -p r3dh4t1! https://api.cluster-${GUID}.${GUID}.${SANDBOXZONE}.opentlc.com:6443

oc adm groups new handson-cluster-admins "${users[@]}"
oc adm policy add-cluster-role-to-group cluster-admin handson-cluster-admins --rolebinding-name=handson-cluster-admins

oc login -u opentlc-mgr -p r3dh4t1!
