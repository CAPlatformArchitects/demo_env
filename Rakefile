require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :test => :spec

task :install do
  system('scripts/db/fetch_dump_file.sh') or exit(1)
  system('scripts/db/create_dp_directory.sh') or exit(1)
end

task :default => [ :install, :test ]