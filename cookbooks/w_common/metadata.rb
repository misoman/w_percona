name 'w_common' #
maintainer 'Joel Handwell'
maintainer_email 'joelhandwell@gmail.com'
license 'apachev2'
description 'Installs/Configures common components among all virtual machines'
long_description 'Installs/Configures common components such as sudo, iptables for ssh, etc'
version '0.0'

depends 'sudo'
depends 'ntp'
depends 'timezone'
depends 'firewall'
depends 'vmware-tools'