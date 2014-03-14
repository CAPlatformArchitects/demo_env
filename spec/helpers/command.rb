module Serverspec
  module Type
    class Command
      def to_s
        type = self.class.name.split(':')[-1]
        type.gsub!(/([a-z\d])([A-Z])/, '\1 \2')
        type.capitalize!
        %Q!#{type} "#{@display_name || @name}"!
      end
    end
  end
end