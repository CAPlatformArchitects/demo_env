require 'spec_helper'

## some example tests for you
describe command 'echo "hello world"' do
  its(:stdout) { should match /hel+o/ }
  its(:stdout) { should match 'world' }
end

describe file '/etc/shadow' do
  it { should be_a_file }
end

describe service('dbora') do
  it { should be_enabled }
  it { should start_before 'rallyapp' }
end


## ok - do the real stuff here
describe file '/root/demo_env/oradump' do
  it { should be_a_directory }
end

describe sql("SELECT directory_name FROM dba_directories WHERE directory_name = 'DEMO_DUMP_DIR';") do
  its(:stdout) { should match 'DEMO_DUMP_DIR' }
end
