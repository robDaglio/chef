# Docker Credentials
default[:mqtt][:docker][:user] = 'kbadmin'
default[:mqtt][:docker][:pass] = 'Sck2Support'
default[:mqtt][:docker][:url] = 'docker.mysck.net'
default[:mqtt][:docker][:email] = 'helpdesk@kitchenbrains.com'

# Docker Repositories
default[:mqtt][:docker][:third_party_repo] = 'third-party'

# Docker Images
default[:mqtt][:docker][:mqtt_img_name] = 'mqtt'
default[:mqtt][:docker][:mqtt_img_full_name] = 'docker.mysck.net/third-party/eclipse-mosquitto'

# Configuration
default[:mqtt][:conf][:mqtt_conf] = '/opt/mqtt/conf/mosquitto.conf'
default[:mqtt][:conf][:mqtt_conf_dir] = '/opt/mqtt/conf'
default[:mqtt][:conf][:mqtt_dest_conf] = '/mosquitto/config/mosquitto.conf'

# Database
default[:mqtt][:db][:mqtt_db] = '/opt/mqtt/db'
default[:mqtt][:db][:mqtt_db_target] = '/mosquitto/data'

# OS
default[:mqtt][:os][:user] = 'sck'