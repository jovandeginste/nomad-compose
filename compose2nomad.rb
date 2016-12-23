#!/usr/bin/env ruby

require 'yaml'
require 'json'

path = File.dirname(__FILE__)

Dir.glob(File.join(path, 'lib', '*.rb')).each{|f| load f}

DEBUG = false

unless source = ARGV.shift
  puts "Usage: #{$0} filename.yml"
  exit 1
end

service = ARGV.shift

def load_compose(file, service = nil)
  input = YAML.load(File.read(file))

  service ||= input.keys.first
  result = input[service]

  if extends = result.delete('extends')
    result.level_merge(load_compose(extends['file'], extends['service'])['data'])
  end

  return {'service' => service, 'data' => result}
end

compose_data = load_compose(source)
service = compose_data['service']
data = compose_data['data']
data['ports'] ||= {}
nomad_params = {}
data['labels'].each do |key, value|
  next unless key.match(/^nomad\./)
  nomad_params[key.sub(/^nomad\./, '')] = value
end

nomad_params = Nomad.defaults + nomad_params.from_labels

ports = nomad_params['ports'] ||= {}
network_ports = nomad_params['network_ports'] ||= {}

data['ports'].each do |port|
  src, dst = port.split(':').map(&:to_i)
  if dst
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

nomad_data = Nomad.generate_nomad_hcl(service, data, nomad_params)

destination = "#{source.sub(/\.ya?ml$/, '')}.nomad"

puts "Converting #{source} to #{destination}..."

if DEBUG
puts "Compose data:"
puts compose_data.to_yaml

puts "This is the nomad_data:"
puts nomad_data.to_hcl
end

File.write destination, nomad_data.to_hcl
