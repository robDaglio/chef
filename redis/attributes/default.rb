# Docker Credentials
default[:redis][:docker][:user] = ''
default[:redis][:docker][:pass] = ''
default[:redis][:docker][:url] = ''
default[:redis][:docker][:email] = ''

# Docker Repositories
default[:redis][:docker][:third_party_repo] = ''

# Docker Images
default[:redis][:docker][:redis_img_name] = ''
default[:redis][:docker][:redis_img_tag] = ''
default[:redis][:docker][:redis_img_full_name] = ''

# Database directory
default[:redis][:db][:redis_db] = ''

# OS
default[:redis][:os][:user] = ''