#! /usr/bin/env ruby
#
#   check-fleet-units
#
# DESCRIPTION:
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: fleet >= 1.0.0
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Barry Martin <nyxcharon@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'fleet'
require 'json'

# Check for dead/invactive fleet units
class CheckFleetUnits < Sensu::Plugin::Check::CLI
  @exclude_list = Array.[]
  option :endpoint,
         description: 'The fleetctl endpoint address',
         short: '-e ENDPOINT',
         long: '--endpoint ENDPOINT',
         required: true

  option :units,
         description: 'A comma delimited list of unit names to check',
         short: '-u UNITS',
         long: '--units UNITS',
         proc: proc { |a| a.split(',') },
         default: []

  option :ignoredead,
         description: 'Also fail on dead units',
         short: '-d',
         default: false

  option :ignore,
         description: 'A comma delimited list of unit names to ignore',
         short: '-i UNITS',
         long: '--ignore UNITS',
         proc: proc { |a| a.split(',') },
         default: ['']

  def run
    begin
      Fleet.configure do |fleet|
        fleet.fleet_api_url = config[:endpoint]
      end
      client = Fleet.new
      services = client.list
      unknown 'Could not fetch fleet units' unless services
    rescue => e
      unknown "Could not connect to fleet: #{e.backtrace}"
    end

    @exclude_list = config[:ignore]
    service_list = if !config[:units].empty?
                     check_unit_list(services, config[:units])
                   else # Check everything
                     check_all_units(services)
                   end
    unless service_list.empty?
      critical 'Found failed unit(s)!: ' + service_list
    else
      ok 'All units running'
    end
  end

  def check_all_units(services)
    service_list = ''
    services.each do |entry|
      if unit_failed?(entry)
        ip = if entry[:machine_ip].nil?
               ''
             else
               entry[:machine_ip]
             end
        service_list += "#{entry[:name]}  #{ip} , "
      end
    end
    service_list
  end

  def check_unit_list(services, list)
    hash = Hash[list.map { |x| [x, false] }]
    service_list = ''
    services.each do |entry|
      hash.each do |k, _|
        if unit_failed?(entry) && entry[:name].include?(k)
          unless service_list.include?("#{entry[:name]} #{entry[:machine_ip]},")
            service_list += "#{entry[:name]} #{entry[:machine_ip]},"
          end
        end
        hash[k] = true if entry[:name].include?(k)
      end
    end
    return service_list unless hash.value?(false)
    warning 'Could not check all specified services(s)'
  end

  def unit_failed?(entry)
    return false if @exclude_list.include?(entry[:name])
    if entry[:sub_state].include?('failed') || entry[:sub_state].include?('dead')
      return false unless config[:ignoredead] && entry[:sub_state].include?('dead')
      return true
    end
  end

  def parse_list(list)
    return list.split(',') if list && list.include?(',')
    return [list] if list
    ['']
  end
end
