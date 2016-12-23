class Nomad
  def self.defaults
    {
      'count' => 1,
      'constraints' => {},
      'datacenters' => [],
      'memory' => 50,
      'cpu' => 100,
      'network_mbits' => 1,
    }
  end
  def self.generate_nomad_hcl(service, compose_params, nomad_params)
    {
      "#{service}" => {
	_type: 'job',
	datacenters: nomad_params['datacenters'],
	update: {
	  stagger: '5s',
	  max_parallel: 1,
	},
      } + nomad_params['constraints'] + {
	  "#{service}" => {
	    _type: 'group',
	    count: nomad_params['count'],
	    restart: {
	      interval: '3m',
	      attempts: 10,
	      delay: '5s',
	      mode: 'delay',
	    },
	    "#{service}" => {
	      _type: 'task',
	      driver: 'docker',
	      config: {
		image: compose_params['image'],
		command: compose_params['command'],
		entrypoint: compose_params['entrypoint'],
		port_map: nomad_params['ports'],
		logging: {
		  type: "journald"
		},
	      },
	      volumes: compose_params['volumes'],
	      env: compose_params['environment'],
	      resources: {
		memory: nomad_params['memory'],
		cpu: nomad_params['cpu'],
		network: {
		  mbits: nomad_params['network_mbits'],
		} + nomad_params['network_ports'],
	      },
	    },
	  },
	}
    }
  end
end
