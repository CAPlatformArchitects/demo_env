require 'serverspec'
require 'helpers/command'
require 'helpers/sql'
require 'helpers/service'

spec_host = ENV['SPEC_HOST'].to_s.strip

if spec_host.empty?
  puts 'Running specs locally'
  include Serverspec::Helper::Exec
  include Serverspec::Helper::DetectOS

  RSpec.configure do |c|
    c.before :all do
      c.os = backend(Serverspec::Commands::Base).check_os
    end
  end

else
  require 'pathname'
  require 'net/ssh'
  include Serverspec::Helper::Ssh
  include Serverspec::Helper::DetectOS

  def spec_host_ssh(host, username, password)
    options  = Net::SSH::Config.for(host)
    user     = username
    options[:password] = password
    options[:paranoid] = false
    Net::SSH.start(host, user, options)
  end

  spec_user = ENV['SPEC_USER'] || 'root'
  spec_password = ENV['SPEC_PASSWORD']
  puts "Running specs remotely on [#{spec_user}@#{spec_host}]"

  raise 'Environment variable SPEC_PASSWORD must be set when running specs remotely' if spec_password.empty?
  spec_host_ssh(spec_host, spec_user, spec_password).close

  RSpec.configure do |c|
    c.before :all do
      if c.host != spec_host
        c.ssh.close if c.ssh
        c.host = spec_host
        c.ssh = spec_host_ssh c.host, spec_user, spec_password
      end
    end
  end

end
