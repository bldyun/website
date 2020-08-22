#!/bin/sh
# inject config data into container
@author jimminh@163.com

set -e

THIS_SCRIPT=$(realpath $(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)/$(basename ${BASH_SOURCE:-$0}))
#automatic detection TOPDIR
SCRIPT_DIR=$(dirname $(realpath ${THIS_SCRIPT}))

if [ -f /usr/share/zoneinfo/Asia/Shanghai ];then
  echo "tz set to Asia/Shanghai"
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  export TZ="Asia/Shanghai"
else
  echo "warn: no tzdata"
fi

export  JAVA_OPTS=" -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"

mkdir -p /cfg/
if [ -f /cfg/env.txt ]; then
    echo "/cfg/env.txt mounted"
    set -a # automatically export all variables
    . /cfg/env.txt
    set +a
    echo "import  $(wc -l /cfg/env.txt) env vars from /cfg/env.txt done"
else
    echo "/cfg/env.txt not found!"
fi
if [ -f ${SCRIPT_DIR}/initdata/init.sh ]; then
    echo "${SCRIPT_DIR}/initdata/init.sh"
    sh "${SCRIPT_DIR}/initdata/init.sh"
fi
if [ -z ${HOSTNAME} ];then
    HOSTNAME=no-name-service
fi

K8S_NS_FILE="/var/run/secrets/kubernetes.io/serviceaccount/namespace"
if [ -f ${K8S_NS_FILE} ];then
K8S_NS=`head -n 1 ${K8S_NS_FILE}`
else
K8S_NS="cant-get-ns"
fi
SVC_NAME=`echo ${K8S_NS}.${HOSTNAME} | rev | cut -d'-'  -f 3- | rev`
MY_K8S_NS=${K8S_NS}
MY_K8S_SVC_NAME=$(echo ${SVC_NAME} | awk -F. '{print $NF}')
echo "SVC_NAME=${SVC_NAME}"
echo "MY_K8S_NS=${MY_K8S_NS}"
echo "MY_K8S_SVC_NAME=${MY_K8S_SVC_NAME}"
export MY_K8S_NS
export MY_K8S_SVC_NAME



exec nginx -g 'daemon off;error_log /dev/stdout info;'
