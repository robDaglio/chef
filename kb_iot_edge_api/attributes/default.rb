# Docker Credentials
default[:kb_iot_edge_api][:docker][:user] = 'kbadmin'
default[:kb_iot_edge_api][:docker][:pass] = 'Sck2Support'
default[:kb_iot_edge_api][:docker][:url] = 'docker.mysck.net'
default[:kb_iot_edge_api][:docker][:email] = 'helpdesk@kitchenbrains.com'

# Docker Images
default[:kb_iot_edge_api][:docker][:iot_img_name] = 'kb_iot_edge_api'
default[:kb_iot_edge_api][:docker][:iot_release_full_name] = 'docker.mysck.net/release/iot/kb_iot_edge_api'
default[:kb_iot_edge_api][:docker][:iot_snapshot_full_name] = 'docker.mysck.net/snapshot/iot/kb_iot_edge_api'

# Configuration directories
default[:kb_iot_edge_api][:conf][:kb_iot_edge_api_log_dir] = '/var/log/kb/kb-iot-edge-api'
default[:kb_iot_edge_api][:conf][:kb_iot_edge_api_conf_dir] = '/opt/kb-iot-edge-api'


# OS
default[:kb_iot_edge_api][:os][:user] = 'sck'