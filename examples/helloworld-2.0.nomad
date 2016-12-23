job "helloworld-prod" {
  datacenters = [
    "mydc",
  ]
  update {
    stagger = "5s"
    max_parallel = 1
  }
  constraint {
    attribute = "${meta.role}"
    value = "myrole"
  }
  constraint {
    distinct_hosts = true
  }
  group "helloworld-prod" {
    count = 3
    restart {
      interval = "3m"
      attempts = 10
      delay = "5s"
      mode = "delay"
    }
    task "helloworld-prod" {
      driver = "docker"
      config {
        image = "jovandeginste/hello:2.0"
        port_map {
          
        }
        logging {
          type = "journald"
        }
      }
      env {
        SERVICE_NAME = "helloworld"
        SERVICE_80_TAGS = "http,urlprefix-prod.helloworld.service.svcd/"
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