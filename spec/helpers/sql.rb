module Serverspec
  module Type
    class Sql < Command
      def initialize(the_sql=nil)
        formatting = <<-eos
          SET SERVEROUTPUT OFF;
          SET NEWPAGE NONE;
          SET PAGESIZE 0;
          SET SPACE 0;
          SET LINESIZE 16000;
          SET ECHO OFF;
          SET FEEDBACK OFF;
          SET VERIFY OFF;
          SET HEADING OFF;
          SET TERMOUT OFF;
          SET TRIMOUT ON;
          SET TRIMSPOOL ON;
        eos
        @display_name = the_sql
        @name = "su - oracle -c 'sqlplus -S / as sysdba' <<EOF\n#{formatting}\n#{the_sql}\nEOF\n"
      end
    end

  end

  module Helper
    module Type
      define_method 'sql' do |*args|
        self.class.const_get('Serverspec').const_get('Type').const_get('Sql').new(args.first)
      end
    end
  end
end