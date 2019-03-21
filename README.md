# Reproduction of [Nomad Issue #5408](https://github.com/hashicorp/nomad/issues/5408)

This is a clean environment attempt to reproduce [nomad issue #5408](https://github.com/hashicorp/nomad/issues/5408).

## Steps:

```
# initial load
vagrant up

# default restart policy - verbatim from ticket
vagrant ssh -- JOB_FILE=hello.nomad /tmp/vagrant/test.sh
# no-restart policy
vagrant ssh -- JOB_FILE=hello-no-restart.nomad /tmp/vagrant/test.sh
# no-restart no-reschedule policy
vagrant ssh -- JOB_FILE=hello-no-reschedule.nomad /tmp/vagrant/test.sh


# upon modifications of files, always run `vagrant provision`, e.g.
vagrant provision; vagrant ssh -- JOB_FILE=hello.nomad /tmp/vagrant/test.sh
```

## Observations:

1. In all cases, nomad detected that the process was killed, as evident by alloc task events.  Nomad emits a Terminated event when process is killed.

```
$ grep -B1 'Exit Code' sample-run-1/*-run.txt
sample-run-1/default-run.txt-2019-03-20T21:37:26Z  Restarting  Task restarting in 18.603882766s
sample-run-1/default-run.txt:2019-03-20T21:37:26Z  Terminated  Exit Code: 137, Signal: 9
--
sample-run-1/no-reschedule-run.txt-2019-03-20T21:40:57Z  Not Restarting  Policy allows no restarts
sample-run-1/no-reschedule-run.txt:2019-03-20T21:40:57Z  Terminated      Exit Code: 137, Signal: 9
--
sample-run-1/no-restart-run.txt-2019-03-20T21:39:31Z  Not Restarting  Policy allows no restarts
sample-run-1/no-restart-run.txt:2019-03-20T21:39:31Z  Terminated      Exit Code: 137, Signal: 9

$ grep 'failed: Wait' sample-run-1/*-nomad.log
sample-run-1/default-nomad.log:    2019/03/20 21:37:26.947950 [INFO] client: task "hello" for alloc "1b0ba82f-6bc3-f056-043a-93c37b4432f5" failed: Wait returned exit code 137, signal 9, and error <nil>
sample-run-1/no-reschedule-nomad.log:    2019/03/20 21:40:57.485719 [INFO] client: task "hello" for alloc "b8f37400-534c-0e3f-975e-438141c81399" failed: Wait returned exit code 137, signal 9, and error <nil>
sample-run-1/no-restart-nomad.log:    2019/03/20 21:39:31.393566 [INFO] client: task "hello" for alloc "232c7bec-b906-4afc-d88e-10092b0ff0a0" failed: Wait returned exit code 137, signal 9, and error <nil>
```

2. The job and alloc status after process is killed is dependent on the type job and restart/reschedule policy associated with it.  UI shows that status:

| Case          | Job Status | Alloc Client Status | file                                   |
|---------------|------------|---------------------|----------------------------------------|
| default       | running    | pending             | `./sample-run-1/default-run.txt`       |
| no-restart    | pending    | failed              | `./sample-run-1/no-restart-run.txt`    |
| no-reschedule | dead       | failed              | `./sample-run-1/no-reschedule-run.txt` |

3. With default restart policy, eventually the alloc would be restarted and both job and alloc status would have `running` status.

4. Nomad recovers well by killing process when SIGTERM is sent to either `nomad executor` or `hello-signals`, or if `SIGKILL` is setn to `hello-signals` process.
   * If `SIGKILL` is sent to `nomad executor` process, the `hello-signal` process is leaked and we plan to address this soon.
