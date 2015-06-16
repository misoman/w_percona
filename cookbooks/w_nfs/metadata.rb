name             'w_nfs'
description 'Installs/Configures nfs'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0'

depends 'nfs'
depends 'cron'
depends 'firewall'