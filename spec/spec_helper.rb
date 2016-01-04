require 'chefspec'
require 'chefspec/berkshelf'
require 'mymatchers'

ChefSpec::Coverage.start! do
  add_filter(%r{[\/\\]apt[\/\\]})
  add_filter(%r{[\/\\]xinetd[\/\\]})
end

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '14.04'
end

def web_apps
  [
    { vhost: { main_domain: 'example.com', aliases: ['www.example.com', 'ex.com'], docroot: '/websites/example.com/www'  } , deploy: { repo_ip: '9.9.9.9', repo_domain: 'git.examplewebsite.com', repo_path: '/websites/example.com', repo_url: 'https://git.examplewebsite.com/www.git' }   , connection_domain: { webapp_domain: 'webapp.example.com', db_domain: 'db.example.com', varnish_domain: 'varnish.example.com' }, mysql: [ { db: 'db',                  user: 'user', password: 'password' }], varnish: { purge_target: true }  },
    { vhost: { main_domain: 'example2.com',                                        docroot: '/websites/example2.com/sub' } , deploy: { repo_ip: '9.9.9.9', repo_domain: 'git.examplewebsite.com', repo_path: '/websites/example2.com', repo_url: 'https://git.examplewebsite.com/www2.git' } , connection_domain: { webapp_domain: 'webapp.example.com', db_domain: 'db.example.com'                                        }, mysql: [ { db: ['db2', 'db3', 'db4'], user: 'user', password: 'password' }]                                   },
    { vhost: { main_domain: 'example3.com',                                        docroot: '/websites/example3.com/sub' }                                                                                                                                                                   , connection_domain: { webapp_domain: 'webapp.example.com', db_domain: 'db.example.com'                                        }, mysql: [ { db: ['db2', 'db3', 'db4'], user: 'user', password: 'password' }]                                   },
    { vhost: { main_domain: 'docroot-only-vhost.com',                              docroot: '/websites/dov'              }}
  ]
end
