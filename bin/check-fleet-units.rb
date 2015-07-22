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
#   gem: sensu-plugin
#   gem: fleet = 0.9.0
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

#
# Check for dead/invactive fleet units
#
class CheckFleetUnits < Sensu::Plugin::Check::CLI
  option :endpoint,
         description: 'The fleetctl endpoint address',
         short: '-e ENDPOINT',
         long: '--endpoint ENDPOINT'

  option :filter,
           description: 'Filter units so they contain FILTER',
           short: '-f FILTER',
           long: '--filter FILTER'

 option :units,
         description: 'A comma delimited list of unit names to check',
         short: '-u UNITS',
         long: '--units UNITS'

  def run
    #Argument setup/parsing/checking
    cli = CheckFleetUnits.new
    cli.parse_options
    endpoint = cli.config[:endpoint]
    filter = cli.config[:filter]
    units = cli.config[:units]

    if not endpoint
      unknown 'No endpoint specified'
    end

    if filter and units
      unknown 'Filter and units flag specified, only 1 can be used'
    end

    if not filter
      filter = ''
    end

    if units and not units.include?(",")
      unknown 'Invalid formatting for units'
    elsif units
      units = units.split(',')
    end


    #Setup fleet client and fetch services
    Fleet.configure do |fleet|
      fleet.fleet_api_url = endpoint
    end
    client = Fleet.new
    services = client.list

    #Iterate over each unit file and search for failures
    failed_services = false
    service_list = ""
    services.each do |entry|
        if units
           units.each do |unit|
             if not entry[:sub_state].include?("running") and entry[:name].include?(unit)
               failed_services = true
               service_list += entry[:name]+" "+entry[:machine_ip]+", "
             end
           end
        else
          if not entry[:sub_state].include?("running") and entry[:name].include?(filter)
            failed_services = true
            service_list += entry[:name]+" "+entry[:machine_ip]+", "
          end
      end
    end

    if failed_services
      critical "Found failed unit(s)!: "+service_list
    else
      ok "All units running"
    end

  end
end
