require 'spec_helper'

describe 'w_comman::hosts' do

	describe host('0webapp.examplewebsite.com') do
    it { should be_resolvable.by('hosts') }
    its(:ipaddress) { should eq '172.31.3.12' }
  end

	describe host('0db.examplewebsite.com') do
    it { should be_resolvable.by('hosts') }
    its(:ipaddress) { should eq '172.31.6.12' }
  end
  
	describe host('localhost') do
    it { should be_resolvable.by('hosts') }
    its(:ipaddress) { should eq '::1' }
  end
        
end