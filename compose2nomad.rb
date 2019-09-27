#!/usr/bin/env ruby

require 'yaml'
require 'json'

path = File.dirname(__FILE__)

Dir.glob(File.join(path, 'lib', '*.rb')).each{|f| load f}

DEBUG = true

unless source = ARGV.shift
  puts "Usage: #{$0} filename.yml service(optional)"
  exit 1
end

def load_compose(file, service = nil)
  if file == '-'
    input = YAML.load(STDIN.read)
  else
    input = YAML.load(File.read(file))
  end

  # Delete docker-compose protected root keys
  ["networks", "version", "volumes", "configs"].each do |key|
    input.delete(key)
  end

  if input['services']
    input = input['services']
  end

  # If no service is defined, just take the first one
  unless service = ARGV[0]
    service ||= input.keys.first
  end

  puts "Service: #{service}"

  result = input[service]

  if extends = result.delete('extends')
    load_file = File.absolute_path(extends['file'], File.dirname(file))
    if File.exist?(load_file)
      puts "Loading file '#{load_file}'..."
      result.level_merge(load_compose(load_file, extends['service'])['data'])
    else
      puts "Could not load file '#{load_file}' -- does not exist."
    end
  end

  return {'service' => service, 'data' => result}
end

compose_data = load_compose(source)

service = compose_data['service']
data = compose_data['data']
data['ports'] ||= {}
nomad_params = {}
data['labels'] ||= {}
data['labels'].each do |key, value|
  next unless key.match(/^nomad\./)
  nomad_params[key.sub(/^nomad\./, '')] = value
end

nomad_params = Nomad.defaults + nomad_params.from_labels + data.from_compose_data

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

puts "Converting #{source} to #{destination} ..."

if DEBUG
puts "Compose data:"
puts compose_data.to_yaml

puts "This is the nomad_data:"
puts nomad_data.to_hcl
end

File.write destination, nomad_data.to_hcl
