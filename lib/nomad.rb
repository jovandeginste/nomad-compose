class Nomad
  def self.defaults
    {
      'constraints' => {},
      'datacenters' => ['mydc'],
      'network_mbits' => 1,
    }
  end
  def self.make_command(params)
    command = params['command']
    entrypoint = params['entrypoint']

    return "#{entrypoint} #{command}".strip
  end
  def self.generate_nomad_hcl(service, compose_params, nomad_params)
    {
      "#{service}" => {
	_type: 'job',
	type: nomad_params['job_type'],
	datacenters: nomad_params['datacenters'],
	update: nomad_params['update'],
	periodic: nomad_params['periodic'],
      } + nomad_params['constraints'] + {
	  "#{service}" => {
	    _type: 'group',
	    count: nomad_params['count'],
	    restart: nomad_params['restart'],
	    "#{service}" => {
	      _type: 'task',
	      driver: 'docker',
	      config: {
		image: compose_params['image'],
		command: self.make_command(compose_params),
		port_map: nomad_params['ports'],
		labels: compose_params['labels'],
		logging: {
		  type: nomad_params['logging'],
		},
		volumes: compose_params['volumes'],
	      },
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
