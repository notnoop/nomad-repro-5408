# Reproduction of [Nomad Issue #5408](https://github.com/hashicorp/nomad/issues/5408)

This is a clean environment attempt to reproduce [nomad issue #5408](https://github.com/hashicorp/nomad/issues/5408).

## Steps:

```
# initial load
vagrant up

# to try with restart policy
vagrant ssh -- JOB_FILE=hello.nomad /tmp/vagrant/test.sh
# to try service with no-restart policy
vagrant ssh -- JOB_FILE=hello-no-restart.nomad /tmp/vagrant/test.sh
# to try batch with no-restart no-reschedule policy
vagrant ssh -- JOB_FILE=hello-batch-no-restart.nomad /tmp/vagrant/test.sh


# upon modifications of files, always run `vagrant provision`, e.g.
vagrant provision; vagrant ssh -- JOB_FILE=hello.nomad /tmp/vagrant/test.sh
```

## Observations:

1. In all cases, nomad detected that the process was killed, as evident by alloc task events.  Nomad emits a Terminated event when process is killed.

```
mars-2:centos notnoop$ cat sample-run-1/*-run.txt | grep -B1 'Exit Code'
2019-03-20T20:39:32Z  Not Restarting  Policy allows no restarts
2019-03-20T20:39:32Z  Terminated      Exit Code: 137, Signal: 9
--
2019-03-20T20:35:41Z  Restarting  Task restarting in 16.769843104s
2019-03-20T20:35:41Z  Terminated  Exit Code: 137, Signal: 9
--
2019-03-20T20:36:59Z  Not Restarting  Policy allows no restarts
2019-03-20T20:36:59Z  Terminated      Exit Code: 137, Signal: 9
```

2. The job and alloc status after process is killed is dependent on the type job and restart/reschedule policy associated with it.  UI shows that status:

| Case          | Job Status | Alloc Client Status | file                                   |
|---------------|------------|---------------------|----------------------------------------|
| default       | running    | pending             | `./sample-run-1/default-run.txt`       |
| no-restart    | pending    | failed              | `./sample-run-1/no-restart-run.txt`    |
| no-reschedule | dead       | failed              | `./sample-run-1/no-reschedule-run.txt` |

3. With default restart policy, eventually the alloc would be restarted and both job and alloc status would have `running` status.
