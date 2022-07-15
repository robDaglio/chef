$cb = node[cookbook_name]

# Docker credentials
$docker_user = $cb[:docker][:user]
$docker_pass = $cb[:docker][:pass]
$docker_url = $cb[:docker][:url]
$docker_repo = $cb[:docker][:repo]
$docker_email = $cb[:docker][:email]

# Mqtt Image
$mqtt_img_name = $cb[:docker][:mqtt_img_name]
$mqtt_img_tag = $cb[:docker][:mqtt_img_tag]
$mqtt_img_full_name = $cb[:docker][:mqtt_img_full_name]

# Configuration files
$mqtt_conf = $cb[:conf][:mqtt_conf]
$mqtt_conf_dir = $cb[:conf][:mqtt_conf_dir]
$mqtt_dest_conf = $cb[:conf][:mqtt_dest_conf]

# Database
$mqtt_db = $cb[:db][:mqtt_db]
$mqtt_db_target = $cb[:db][:mqtt_db_target]

# OS
$user = $cb[:os][:user]


bash ' mqtt : install ' do

    code <<-EOH

        function log () {
            echo "${BASHPID} $(date '+%d-%m-%Y %H:%M:%S'): $1"
        }


        function docker_reg_login () {
            # If os is centos, use legacy docker API call, else use current
            log "Logging into the docker registry."

            if [[ -e "/etc/centos-release" ]]; then
                docker login -e #{$docker_email} -p #{$docker_pass} -u #{$docker_user} #{$docker_url} > /dev/null 2>&1
            else
                docker login -p #{$docker_pass} -u #{$docker_user} #{$docker_url} > /dev/null 2>&1
            fi

            if [ $? -eq 0 ]; then
                log "Docker registry login succeeded!"
            else
                log "Docker registry login failed."
                return 1
            fi
        }
    

        function write_conf () {
            log "Writing Mosquitto configuration to #{$mqtt_conf}."

                mosquitto_conf="listener 1883
                    allow_anonymous true
                    persistence true
                    persistence_location /mosquitto/data
                    autosave_interval 1
                    autosave_on_changes true"
                
                while read line; do
                    echo "${line}" >> #{$mqtt_conf}
                done <<< "${mosquitto_conf}"
        }


        function configure_mqtt () {
            log "Checking for pre-existing configuration."

            if [[ -e "#{$mqtt_conf}" ]]; then
                log "Mosquitto configuration found- overwriting."
                rm #{$mqtt_conf}
                write_conf
            else
                log "Writing new configuration file - #{$mqtt_conf}"
                write_conf
            fi
        }


        function create_conf_dirs (){
            log "Configuring MQTT."

            for dir in "#{$mqtt_conf_dir}" "#{$mqtt_db}"; do
                if [[ -d "${dir}" ]]; then
                    log "${dir} exists - skipping."

                else
                    log "${dir} does not exist. Creating it."
                    mkdir -p $dir

                    log "Setting ownership for ${dir}."
                    chown -R #{$user}:#{$user} $dir
                    printf "\n"
                fi
            done
        }


        function rebuild_container () {
            
            container_id=$(docker ps -aqf 'name=#{$mqtt_img_name}')

            # If container does not exist, create it
            if [[ -z "${container_id}" ]]; then
                start_mqtt
            else
                log "Rebuilding container: #{$mqtt_img_name} | ${container_id}."

                docker stop "${container_id}"
                docker rm "${container_id}"

                start_mqtt
            fi
        }


        function pull_latest () {

            echo "Pulling latest image version."
            docker pull #{$mqtt_img_full_name} | grep "Image"

            # If image is not up to date, rebuild the container
            if [[ $? -ne 0 ]]; then
                log "Newer image found."
                rebuild_container
            else
                log "Nothing to do."
                rebuild_container
            fi
        }


        function start_mqtt () {
            log "Starting MQTT."

            docker run \
                --name mqtt \
                --mount type=bind,source=#{$mqtt_conf},target=#{$mqtt_dest_conf} \
                -v #{$mqtt_db}:#{$mqtt_db_target} \
                -v /etc/localtime:/etc/localtime:ro \
                -p 1883:1883 \
                --restart=always \
                -d #{$mqtt_img_full_name}
        }

        
        create_conf_dirs
        configure_mqtt

        docker_reg_login
        pull_latest

    EOH
end