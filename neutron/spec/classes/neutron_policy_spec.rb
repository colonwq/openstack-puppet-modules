require 'spec_helper'

describe 'neutron::policy' do

  let :default_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron policies' do
    let :params do
      {
        :policy_path => '/etc/neutron/policy.json',
        :policies    => {
          'context_is_admin' => {
            'key'   => 'context_is_admin',
            'value' => 'foo:bar'
          }
        }
      }
    end

    it 'set up the policies' do
      is_expected.to contain_openstacklib__policy__base('context_is_admin').with({
        :key   => 'context_is_admin',
        :value => 'foo:bar'
      })
    end
  end

  context 'on Debian platforms' do
    let :facts do
      default_facts.merge({ :osfamily => 'Debian' })
    end

    it_configures 'neutron policies'
  end

  context 'on RedHat platforms' do
    let :facts do
      default_facts.merge({ :osfamily => 'RedHat' })
    end

    it_configures 'neutron policies'
  end
end
