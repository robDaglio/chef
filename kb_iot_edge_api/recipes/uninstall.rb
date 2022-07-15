$cb = node[cookbook_name]

$iot_img_name = $cb[:docker][:iot_img_name]

$iot_release_full_name = $cb[:docker][:iot_release_full_name]
$iot_snapshot_full_name = $cb[:docker][:iot_snapshot_full_name]


$kb_iot_edge_api_log_dir = $cb[:conf][:kb_iot_edge_api_log_dir]
$kb_iot_edge_api_conf_dir = $cb[:conf][:kb_iot_edge_api_conf_dir]


bash ' kb_iot_edge_api : uninstall ' do

    code <<-EOH

        function log () {
            echo "${BASHPID} $(date '+%d-%m-%Y %H:%M:%S'): $1"
        }

        function stop_and_remove_container () {
            
            log "Stopping and removing legacy containers."
            
            log "Retrieving container ids for ${1}."
            container_id=$(docker ps -a | grep "${1}" | awk '{print $1}')

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
                log "No containers found for ${1}."
            fi
        }


        function delete_image () {

            log "Deleting legacy images."

            image_id=$(docker images -q "${1}")
            
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
                log "No images found for ${1}"
            fi
        }

        function delete_log_directory () {
            
            log "Removing configuration directories."
            
            for dir in "#{$kb_iot_edge_api_conf_dir}" "#{$kb_iot_edge_api_log_dir}"; do 
                if [[ -d "${dir}" ]]; then
                    log "Removing ${dir}."
                    rm -rf $dir
                fi
            done
        }


        for i in #{$iot_release_full_name} #{$iot_snapshot_full_name}; do
            stop_and_remove_container $i
            delete_image $i
        done

        delete_log_directory

        log "Pruning obsolete images."
        docker system prune -f

        EOH
    end