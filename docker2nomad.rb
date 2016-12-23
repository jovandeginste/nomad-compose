#!/usr/bin/env ruby

require 'yaml'
require 'json'

path = File.dirname(__FILE__)

Dir.glob(File.join(path, 'lib', '*.rb')).each{|f| load f}

DEBUG = false

unless source = ARGV.shift
  puts "Usage: #{$0} container"
  exit 1
end

docker_data = JSON.load(%x[docker inspect #{source}]).first

data = {
  'image' => docker_data['Config']['Image'],
  'command' => docker_data['Config']['Cmd'].join(' '),
  'entrypoint' => docker_data['Config']['Entrypoint'],
  'environment' => Hash[docker_data['Config']['Env'].map{|e| e.split('=', 2)}],
  'labels' => docker_data['Config']['Labels'],
}

nomad_params = {}
data['labels'].each do |key, value|
  next unless key.match(/^nomad\./)
  nomad_params[key.sub(/^nomad\./, '')] = value
end

nomad_params = Nomad.defaults + nomad_params.from_labels

ports = nomad_params['ports'] ||= {}
network_ports = nomad_params['network_ports'] ||= {}

docker_data['HostConfig']['PortBindings'].each do |port, port_config|
	src = port.split('/').first
	dst = port_config.first['HostPort']
  if dst and dst != ''
    ports["port_#{dst}"] = dst
    network_ports["port_#{dst}"] = {
      _type: 'port',
      static: src,
    }
  else
    ports["port_#{src}"] = src
    network_ports["port_#{src}"] = {
      _type: 'port',
    }
  end
end

nomad_data = Nomad.generate_nomad_hcl(source, data, nomad_params)

destination = "#{source}.nomad"

puts "Converting #{source} to #{destination}..."

if DEBUG
puts "Compose data:"
puts docker_data.to_yaml

puts "This is the nomad_data:"
puts nomad_data.to_hcl
end

File.write destination, nomad_data.to_hcl
