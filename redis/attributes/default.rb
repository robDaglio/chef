# Docker Credentials
default[:redis][:docker][:user] = 'kbadmin'
default[:redis][:docker][:pass] = 'Sck2Support'
default[:redis][:docker][:url] = 'docker.mysck.net'
default[:redis][:docker][:email] = 'helpdesk@kitchenbrains.com'

# Docker Repositories
default[:redis][:docker][:third_party_repo] = 'third-party'

# Docker Images
default[:redis][:docker][:redis_img_name] = 'redis'
default[:redis][:docker][:redis_img_tag] = '6.2.6'
default[:redis][:docker][:redis_img_full_name] = 'docker.mysck.net/third-party/redis'

# Database directory
default[:redis][:db][:redis_db] = '/opt/redis'

# OS
default[:redis][:os][:user] = 'sck'