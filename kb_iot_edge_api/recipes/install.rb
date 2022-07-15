$cb = node[cookbook_name]

# Docker credentials
$docker_user = $cb[:docker][:user]
$docker_pass = $cb[:docker][:pass]
$docker_url = $cb[:docker][:url]
$docker_email = $cb[:docker][:email]

# KB-IoT-Edge API Image
$iot_img_name = $cb[:docker][:iot_img_name]
$iot_release_full_name = $cb[:docker][:iot_release_full_name]

# Configuration
$kb_iot_edge_api_log_dir = $cb[:conf][:kb_iot_edge_api_log_dir]
$kb_iot_edge_api_conf_dir = $cb[:conf][:kb_iot_edge_api_conf_dir]

# OS
$user = $cb[:os][:user]


bash ' kb_iot_edge_api : install ' do

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


        function configure_project_dirs (){
            
            log "Configuring project directories."

            for dir in "#{$kb_iot_edge_api_conf_dir}" "#{$kb_iot_edge_api_log_dir}"; do
                log "Processing ${dir}"
                
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
            
            container_id=$(docker ps -aqf 'name=#{$iot_img_name}')

            # If container does not exist, create it
            if [[ -z "${container_id}" ]]; then
                start_kb_iot_edge_api
            else
                log "Rebuilding container: #{$iot_img_name} | ${container_id}."

                docker stop "${container_id}"
                docker rm "${container_id}"

                start_kb_iot_edge_api
            fi
        }


        function pull_latest () {

            echo "Pulling latest image version."
            docker pull #{$iot_release_full_name} | grep "Image"

            # If image is not up to date, rebuild the container
            if [[ $? -ne 0 ]]; then
                log "Newer image found."
                rebuild_container
            else
                log "Image is up to date."
                rebuild_container
            fi
        }


        function start_kb_iot_edge_api () {
            
            log "Starting KB-IoT-Edge."

            docker run \
                -e LOG_LEVEL='DEBUG' \
                -e LOG_FILE='#{$kb_iot_edge_api_log_dir}/KB_IoT_Edge_API_service.log' \
                -v #{$kb_iot_edge_api_log_dir}:#{$kb_iot_edge_api_log_dir}:rw \
                -v /etc/localtime:/etc/localtime:ro \
                --net host \
                --name kb_iot_edge_api \
                --restart=always \
                -d #{$iot_release_full_name}
        }


        configure_project_dirs
        docker_reg_login
        pull_latest

    EOH
end
