require 'spec_helper'

describe 'w_apache::phpmyadmin' do

	describe file('/opt/phpmyadmin/config.inc.php') do
	  it { should be_file }
	end

end