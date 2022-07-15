$cb = node[cookbook_name]

$mqtt_img_name = $cb[:docker][:mqtt_img_name]
$mqtt_img_full_name = $cb[:docker][:mqtt_img_full_name]
$mqtt_conf_dir = $cb[:conf][:mqtt_conf_dir]
$mqtt_db = $cb[:db][:mqtt_db]


bash ' mqtt : uninstall ' do

    code <<-EOH

        function log () {
            echo "${BASHPID} $(date '+%d-%m-%Y %H:%M:%S'): $1"
        }

        
        function stop_and_remove_container() {
            
            log "Stopping and removing legacy containers."
            
            log "Retrieving container ids for #{$mqtt_img_full_name}."
            container_id=$(docker ps -a | grep "#{$mqtt_img_full_name}" | awk '{print $1}')
            
            if [[ -n "${container_id}" ]]; then
                log "Id found: ${container_id}"

                if [[ $(echo "${container_id}" | wc -l) > 1 ]]; then
                    for id in "${container_id}"; do
                        log "Stopping ${id}."
                        docker stop $id
                        
                        log "Removing ${id}."
                        docker rm $id
                    done
                else
                    log "Stopping ${container_id}."
                    docker stop $container_id

                    log "Removing ${container_id}."
                    docker rm $container_id
                fi
            else
                echo "No containers found for #{$mqtt_img_full_name}."
            fi
        }


        function delete_image () {

            log "Deleting legacy images."

            image_id=$(docker images -q "#{$mqtt_img_full_name}")
            
            if [[ -n "${image_id}" ]]; then
                if [[ $(echo "${image_id}" | wc -l) > 1 ]]; then
                    for id in "${image_id}"; do
                        log "Removing ${id}"
                        docker rmi -f $id
                    done
                else
                    log "Removing ${image_id}"
                    docker rmi -f $image_id
                fi
            else
                log "No images found for #{$mqtt_img_full_name}"
            fi
        }


        function delete_conf_directories () {
            
            log "Removing configuration directories."
            
            conf_dir="/opt/mqtt"

            if [[ -d "${conf_dir}" ]]; then
                log "Removing ${conf_dir}."
                rm -rf $conf_dir
            fi
        }

        stop_and_remove_container
        delete_image
        delete_conf_directories

        log "Pruning obsolete images."
        docker system prune -f

        EOH
    end