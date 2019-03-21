job "hello" {
  type = "service"
  datacenters = ["dc1"]

  task "hello" {
    driver = "raw_exec"

    config {
      command = "hello-signals"
    }
  }
}

