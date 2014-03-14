module SpecInfra
  module Command
    class RedHat < Linux
      def start_priority(service_name)
        "grep -o 'chkconfig.\\+$' /etc/init.d/#{service_name} | awk '{print $3}'"
      end

      def stop_priority(service_name)
        "grep -o 'chkconfig.\\+$' /etc/init.d/#{service_name} | awk '{print $4}'"
      end
    end
  end
end

module Serverspec
  module Type
    class Service < Base
      def start_before?(other_service)
        start_priority < start_priority(other_service) || @name < other_service
      end

      def start_after?(other_service)
        start_priority > start_priority(other_service) || @name > other_service
      end

      def start_priority(service_name=@name)
        backend.run_command( commands.start_priority(service_name) ).stdout.strip.to_i
      end
    end
  end
end

RSpec::Matchers.define :start_before do |other_service|
  match do |subject|
    subject.start_before? other_service
  end
end

RSpec::Matchers.define :start_after do |other_service|
  match do |subject|
    subject.start_after? other_service
  end
end
