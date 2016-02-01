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

#
# Check for dead/invactive fleet units
#
class CheckFleetUnits < Sensu::Plugin::Check::CLI
  option :endpoint,
          description: 'The fleetctl endpoint address',
          short: '-e ENDPOINT',
          long: '--endpoint ENDPOINT',
          required: true

  option :units,
          description: 'A comma delimited list of unit names to check',
          short: '-u UNITS',
          long: '--units UNITS'

  option :ignoredead,
          description: 'Also fail on dead units',
          short: '-d',
          default: false

  def run
    #Argument setup/parsing/checking
    cli = CheckFleetUnits.new
    cli.parse_options
    endpoint = cli.config[:endpoint]
    units = cli.config[:units]

    #Setup fleet client and fetch services
    begin
      Fleet.configure do |fleet|
        fleet.fleet_api_url = endpoint
      end
      client = Fleet.new
      services = client.list

      if not services
        unknown "Could not fetch fleet units"
      end
    rescue
     unknown "Could not connect to fleet"
    end

    if units and units.include?(",") #List of services to check
      units = units.split(',')
      service_list = checkUnitList(services,units)
    elsif units
      units = [ units ]
      service_list = checkUnitList(services,units)
    else #Check everything
      service_list = checkAllUnits(services)
    end

    if service_list.length > 0
      critical "Found failed unit(s)!: "+service_list
    else
      ok "All units running"
    end
  end#End method


  def checkAllUnits(services)
    service_list = ""
    services.each do |entry|
      if isUnitFailed(entry)
        service_list += entry[:name]+" "+entry[:machine_ip]+", "
      end
    end
    return  service_list
  end #End method

  def checkUnitList(services,list)
    hash = Hash[list.map {|x| [x, false]}]
    service_list = ""
    services.each do |entry|
      hash.each do |k,v|
        if isUnitFailed(entry) and entry[:name].include?(k)
          if not service_list.include?(entry[:name]+" "+entry[:machine_ip]+", ")
            service_list += entry[:name]+" "+entry[:machine_ip]+", "
          end
        end
        if entry[:name].include?(k)
          hash[k] = true
        end
      end
    end
    if hash.has_value?(false) #We didn't check a service, so warn since it's missing
      warning 'Could not check all specified services(s)'
    else
      return service_list
    end
  end #End method

  def isUnitFailed(entry)
    if entry[:sub_state].include?("failed") or entry[:sub_state].include?("dead")
        if not config[:ignoredead] and entry[:sub_state].include?("dead")
          return false
        elsif entry[:sub_state].include?("dead")
          return true
        else #otherwise it's failed
          return true
        end
    end
  end

end #End class
