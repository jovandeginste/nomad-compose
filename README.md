# nomad-compose
Use docker-compose yml files as input for Hashicorp's nomad

This script converts docker-compose yml files to nomad job templates

Usage: ./compose2nomad compose.yml [servicename]

This script resolves `extends` stanzas. You can add specific labels the compose file
to influence some nomad-specific options, such as count, constraints, etc.
The implementation depends on the setting. Examples:

```yaml
    nomad.count: 1
    nomad.datacenters:
      - mydc
    nomad.constraints._cluster._type: constraint
    nomad.constraints._cluster.attribute: '${meta.role}'
    nomad.constraints._cluster.value: myrole
    nomad.constraints._distinct._type: constraint
    nomad.constraints._distinct.distinct_hosts: true
```

TODO:

* currently only a single task is generated (while both compose and nomad
  support multiple tasks in a single file)
* add more nomad-specific configuration options

