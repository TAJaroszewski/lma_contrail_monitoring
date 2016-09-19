require 'spec_helper'
describe 'lma_contrail_monitoring' do

  context 'with defaults for all parameters' do
    it { should contain_class('lma_contrail_monitoring') }
  end
end
