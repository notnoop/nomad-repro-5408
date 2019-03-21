#!/bin/bash

set -e

JOB_FILE="${JOB_FILE:-hello.nomad}"

echo "=====> Start nomad"
nomad_log="/tmp/nomad-logs-$(date +%s)"
echo "start nomad with logs in ${nomad_log}"
sudo nomad agent -dev -bind 0.0.0.0 > "${nomad_log}" 2>&1 &
trap "sudo pkill nomad" SIGINT SIGTERM EXIT

# wait a bit for nomad to be up
echo -n 'waiting for nomad to be up: '
while ! nomad node status -self > /dev/null 2>/dev/null;
do
	echo -n .
	sleep 1
done
echo .

echo
echo "====> Run job"
echo

nomad job run "/tmp/vagrant/${JOB_FILE}"

echo -n 'wait for alloc to be running: '
alloc_id=""
while [[ -z "${alloc_id}" ]]
do
	echo -n .
	alloc_id="$(nomad job status hello | grep running | grep hello | awk '{print $1;}')"
	sleep 1
done
echo


echo
echo "====> Kill exec"
ps -ef | grep /bin/hello-signals
sudo pkill -9 hello-signals

sleep 3
echo
echo "====> Check status after Killed"

ps -ef |grep /bin/hello-signals || true

echo
echo '### JOB STATUS'
nomad job status hello

echo
echo '### ALLOC STATUS'
nomad alloc status "${alloc_id}"

echo ''
echo '### ALLOC LOGS'
nomad alloc logs "${alloc_id}"
nomad alloc logs --stderr "${alloc_id}"
