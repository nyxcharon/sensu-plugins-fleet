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
require 'os'

#
# Check for dead/invactive fleet units
#
class CheckFleetUnits < Sensu::Plugin::Check::CLI
  option :endpoint,
         description: 'The fleetctl endpoint address',
         short: '-e ENDPOINT',
         long: '--endpoint'

  def run
    #Argument setup/parsing/checking
    cli = CheckFleetUnits.new
    cli.parse_options
    endpoint = cli.config[:endpoint]

    if not endpoint
      warning 'No endpoint specified'
    end

    #Run fleetctl
    bin_dir = File.expand_path(File.dirname(__FILE__))
    if OS.osx?
      shell_script_path = File.join(bin_dir, 'fleetctl-mac')
    elsif OS.linux?
      shell_script_path = File.join(bin_dir, 'fleetctl-linux')
    else
      warning 'Running on unsupported platform'
    end

    #puts "#{shell_script_path} --endpoint #{endpoint} list-units"
    output=`#{shell_script_path} --endpoint #{endpoint} list-units 2>&1`
    #puts output
    #Parse output
    if output.include?('Unable to initialize client: URL scheme undefined')
      warning "Invalid endpoint specified"
    end

    failed=false
    failed_units=""
    output.each_line do |line|
      if line.include?('failed')
        failed=true
      end
    end

    if failed
      critical "Found failed units!"
    else
      ok "All units running"
    end

  end
end
