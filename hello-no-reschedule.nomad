job "hello" {
  type = "service"
  datacenters = ["dc1"]

  group "hello" {
    task "hello" {
      driver = "raw_exec"

      config {
        command = "hello-signals"
      }

    }

    reschedule {
      attempts       = 0
      unlimited = false
    }

    restart {
      attempts = 0
      interval = "1h"
      mode = "fail"
    }
  }

}

