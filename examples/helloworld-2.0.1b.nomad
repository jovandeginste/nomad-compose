job "helloworld-2.0.1b-dev" {
  datacenters = [
    "icts",
  ]
  update {
    stagger = "5s"
    max_parallel = 1
  }
  constraint {
    attribute = "${meta.role}"
    value = "kstest"
  }
  constraint {
    distinct_hosts = true
  }
  group "helloworld-2.0.1b-dev" {
    count = 1
    restart {
      interval = "3m"
      attempts = 10
      delay = "5s"
      mode = "delay"
    }
    task "helloworld-2.0.1b-dev" {
      driver = "docker"
      config {
        image = "jovandeginste/hello:2.0.1b"
        port_map {
          
        }
        logging {
          type = "journald"
        }
      }
      env {
        SERVICE_NAME = "helloworld"
        SERVICE_80_TAGS = "http,urlprefix-dev.helloworld.service.svcd/2.0.1b strip=/2.0.1b"
        SERVICE_80_IPV6 = "tcp"
        SERVICE_80_CHECK_HTTP = "/"
        SERVICE_80_CHECK_INTERVAL = "15s"
      }
      resources {
        memory = 50
        cpu = 100
        network {
          mbits = 1
        }
      }
    }
  }
}