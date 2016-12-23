class Nomad
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
		port_map: nomad_params['ports'],
		logging: {
		  type: "journald"
		},
	      },
	      volumes: compose_params['volumes'],
	      env: compose_params['environment'],
	      resources: {
		memory: 50,
		cpu: 100,
		network: {
		  mbits: 1,
		} + nomad_params['network_ports'],
	      },
	    },
	  },
	}
    }
  end
end
