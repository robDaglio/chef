$cb = node[cookbook_name]

# Docker credentials
$docker_user = $cb[:docker][:user]
$docker_pass = $cb[:docker][:pass]
$docker_url = $cb[:docker][:url]
$docker_repo = $cb[:docker][:repo]
$docker_email = $cb[:docker][:email]

# Redis Image
$redis_img_name = $cb[:docker][:redis_img_name]
$redis_img_tag = $cb[:docker][:redis_img_tag]
$redis_img_full_name = $cb[:docker][:redis_img_full_name]

# Database
$redis_db = $cb[:db][:redis_db]

# OS
$user = $cb[:os][:user]


bash ' redis : install ' do

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


        function configure_redis (){
            log "Configuring Redis log directory."

            if [[ -d "#{$redis_db}" ]]; then
                log "#{$redis_db} exists - skipping."

            else
                log "#{$redis_db} does not exist. Creating it."
                mkdir -p #{$redis_db}

                log "Setting ownership for #{$redis_db}."
                chown -R #{$user}:#{$user} #{$redis_db}
                printf "\n"
            fi

        }


        function rebuild_container () {
            
            container_id=$(docker ps -aqf 'name=#{$redis_img_name}')

            # If container does not exist, create it
            if [[ -z "${container_id}" ]]; then
                start_redis
            else
                log "Rebuilding container: #{$redis_img_name} | ${container_id}."

                docker stop "${container_id}"
                docker rm "${container_id}"

                start_redis
            fi
        }


        function pull_latest () {

            log "Pulling latest image version."
            docker pull #{$redis_img_full_name} | grep "Image"

            # If image is not up to date, rebuild the container
            if [[ $? -ne 0 ]]; then
                log "Newer image found."
                rebuild_container
            else
                log "Nothing to do."
                rebuild_container
            fi
        }


        function start_redis () {
            log "Starting Redis."
            
            docker run \
                --name redis \
                -v #{$redis_db}:/data \
                -v /etc/localtime:/etc/localtime:ro \
                -p 6379:6379 --restart=always \
                -d #{$redis_img_full_name} redis-server \
                --save 60 1 \
                --appendonly yes
        }

        configure_redis
        docker_reg_login
        pull_latest

    EOH
end