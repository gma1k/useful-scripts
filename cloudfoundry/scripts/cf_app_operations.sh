#!/bin/bash

# This script uses the cf CLI commands to perform various operations on Cloud Foundry apps, such as creating, updating, deleting, scaling, showing information, etc. 
# The script also uses the cf curl command to access the Cloud Foundry API endpoints and get more detailed information about the apps. 
# The script also uses the jq and dig commands to parse JSON data and get IP addresses.
# The script also allows the user to save the output of each operation to a file.

save_to_file() {
  read -p "Do you want to save the information to a file? (y/n): " answer
  if [[ $answer == y || $answer == Y ]]; then
    FILENAME="${OPERATION}_of_${APP_NAME}.txt"
    echo "$INFORMATION" > $FILENAME
    echo "The information has been saved to $FILENAME"
  fi
}

show_app_summary() {
  APP_GUID=$(cf app $APP_NAME --guid)
  INFORMATION=$(cf curl /v2/apps/$APP_GUID/summary)
  echo "$INFORMATION"
  OPERATION="app_summary"
  save_to_file "$OPERATION" "$INFORMATION"
}

show_app_usage_events() {
  APP_GUID=$(cf app $APP_NAME --guid)
  INFORMATION=$(cf curl "/v2/app_usage_events?q=app_guid:$APP_GUID")
  echo "$INFORMATION"
  OPERATION="app_usage_events"
  save_to_file "$OPERATION" "$INFORMATION"
}

show_app_ip_address() {
  APP_GUID=$(cf app $APP_NAME --guid)
  INFORMATION=$(cf curl /v2/apps/$APP_GUID/summary)
  ROUTE=$(echo "$INFORMATION" | jq -r '.routes[0].host')
  DOMAIN=$(echo "$INFORMATION" | jq -r '.routes[0].domain.name')
  APP_URL="$ROUTE.$DOMAIN"
  IP_ADDRESS=$(dig +short $APP_URL)
  echo "The IP address of $APP_NAME is $IP_ADDRESS"
  OPERATION="app_ip_address"
  save_to_file "$OPERATION" "$IP_ADDRESS"
}

show_c2c_policy() {
  INFORMATION=$(cf curl /networking/v1/external/policies)
  echo "$INFORMATION"
  OPERATION="c2c_policy"
  save_to_file "$OPERATION" "$INFORMATION"
}

show_app_ports() {
  APP_GUID=$(cf app $APP_NAME --guid)
  INFORMATION=$(cf curl /v2/apps/$APP_GUID/ports)
  echo "$INFORMATION"
  OPERATION="app_ports"
  save_to_file "$OPERATION" "$INFORMATION"
}

show_app_stats() {
  APP_GUID=$(cf app $APP_NAME --guid)
  INFORMATION=$(cf curl /v2/apps/$APP_GUID/stats)
  echo "$INFORMATION"
  OPERATION="app_stats"
  save_to_file "$OPERATION" "$INFORMATION"
}

show_network_policies() {
  INFORMATION=$(cf network-policies)
  echo "$INFORMATION"
  OPERATION="network_policies"
   save_to_file "$OPERATION" "$INFORMATION"
}

show_app_routes() {
   APP_GUID=$(cf app $APP_NAME --guid)
   INFORMATION=$(cf curl /v2/apps/$APP_GUID/routes)
   echo "$INFORMATION"
   OPERATION="app_routes"
   save_to_file "$OPERATION" "$INFORMATION"
}

show_app_health_check() {
   INFORMATION=$(cf health-check $APP_NAME)
   echo "$INFORMATION"
   OPERATION="app_health_check"
   save_to_file "$OPERATION" "$INFORMATION"
}

show_app_instances() {
   INFORMATION=$(cf app $APP_NAME)
   echo "$INFORMATION"
   OPERATION="app_instances"
   save_to_file "$OPERATION" "$INFORMATION"
}

show_app_features() {
   INFORMATION=$(cf feature-flags)
   echo "$INFORMATION"
   OPERATION="app_features"
   save_to_file "$OPERATION" "$INFORMATION"
}

show_app_metadata() {
   APP_GUID=$(cf app $APP_NAME --guid)
   INFORMATION=$(cf curl /v2/apps/$APP_GUID)
   echo "$INFORMATION"
   OPERATION="app_metadata"
   save_to_file "$OPERATION" "$INFORMATION"
}

create_app() {
   read -p "Enter the app name: " APP_NAME
   read -p "Enter the app path: " APP_PATH
   INFORMATION=$(cf push $APP_NAME -p $APP_PATH)
   echo "$INFORMATION"
   OPERATION="create_app"
   save_to_file "$OPERATION" "$INFORMATION"
}

update_app() {
   read -p "Enter the app name: " APP_NAME
   read -p "Enter the app path: " APP_PATH
   INFORMATION=$(cf push $APP_NAME -p $APP_PATH)
   echo "$INFORMATION"
   OPERATION="update_app"
   save_to_file "$OPERATION" "$INFORMATION"
}

delete_app() {
  cf apps | tail -n +5 | awk '{print NR ") " $1}'
  read -p "Enter your choice: " choice
  APP_NAME=$(cf apps | tail -n +5 | sed -n "${choice}p" | awk '{print $1}')
  INFORMATION=$(cf delete $APP_NAME -f)
  echo "$INFORMATION"
  OPERATION="delete_app"
  save_to_file "$OPERATION" "$INFORMATION"
}

scale_app() {
  read -p "Enter the app name: " APP_NAME
  read -p "Enter number of instances (or press Enter to skip): " INSTANCES
  read -p "Enter memory limit (or press Enter to skip): " MEMORY_LIMIT
  read -p "Enter disk limit (or press Enter to skip): " DISK_LIMIT

  COMMAND="cf scale $APP_NAME"
  if [[ -n $INSTANCES ]]; then  
    COMMAND="$COMMAND -i $INSTANCES"  
  fi  
  if [[ -n $MEMORY_LIMIT ]]; then  
    COMMAND="$COMMAND -m $MEMORY_LIMIT"  
  fi  
  if [[ -n $DISK_LIMIT ]]; then  
    COMMAND="$COMMAND -k $DISK_LIMIT"  
  fi  
  INFORMATION=$($COMMAND)
  echo "$INFORMATION"
  OPERATION="scale_app"
  save_to_file "$OPERATION" "$INFORMATION"
}

create_route() {
  read -p "Enter domain: " DOMAIN
  read -p "Enter hostname (or press Enter to skip): " HOSTNAME
  read -p "Enter path (or press Enter to skip): " PATH

  COMMAND="cf create-route $SPACE_NAME $DOMAIN"
  if [[ -n $HOSTNAME ]]; then  
    COMMAND="$COMMAND --hostname $HOSTNAME"  
  fi  
  if [[ -n $PATH ]]; then  
    COMMAND="$COMMAND --path $PATH"  
  fi  
  INFORMATION=$($COMMAND)
  echo "$INFORMATION"
  OPERATION="create_route"
  save_to_file "$OPERATION" "$INFORMATION"
}

delete_route() {
  read -p "Enter domain: " DOMAIN
  read -p "Enter hostname (or press Enter to skip): " HOSTNAME
  read -p "Enter path (or press Enter to skip): " PATH

  COMMAND="cf delete-route $DOMAIN"
  if [[ -n $HOSTNAME ]]; then  
    COMMAND="$COMMAND --hostname $HOSTNAME"  
  fi  
  if [[ -n $PATH ]]; then  
    COMMAND="$COMMAND --path $PATH"  
  fi  
  INFORMATION=$($COMMAND -f)
  echo "$INFORMATION"
  OPERATION="delete_route"
  save_to_file "$OPERATION" "$INFORMATION"
}

create_network_policy() {
   read -p "Enter source app: " SOURCE_APP
   read -p "Enter destination app: " DESTINATION_APP
   read -p "Enter protocol: " PROTOCOL
   read -p "Enter port range: " PORT_RANGE

   INFORMATION=$(cf add-network-policy $SOURCE_APP --destination-app $DESTINATION_APP --protocol $PROTOCOL --port $PORT_RANGE)
   echo "$INFORMATION"
   OPERATION="create_network_policy"
   save_to_file "$OPERATION" "$INFORMATION"
}

delete_network_policy() {
   read -p "Enter source app: " SOURCE_APP
   read -p "Enter destination app: " DESTINATION_APP
   read -p "Enter protocol: " PROTOCOL
   read -p "Enter port range: " PORT_RANGE

   INFORMATION=$(cf remove-network-policy $SOURCE_APP --destination-app $DESTINATION_APP --protocol $PROTOCOL --port $PORT_RANGE)
   echo "$INFORMATION"
   OPERATION="delete_network_policy"
   save_to_file "$OPERATION" "$INFORMATION"
}

show_app_info_menu() {
   echo "Please select an option to show app information:"
   echo "1) App summary"
   echo "2) App events"
   echo "3) App logs (recent)"
   echo "4) App logs (tail)"
   echo "5) App environment variables"
   echo "6) App service bindings"
   echo "7) App usage events"
   echo "8) App IP address"
   echo "9) Container-to-container networking policy"
   echo "10) App ports"
   echo "11) App stats"
   echo "12) Network policies"
   echo "13) App routes"
   echo "14) App health check"
   echo "15) App instances"
   echo "16) App features"
   echo "17) App metadata"
   echo "X) Quit"
   read -p "Enter your choice: " choice
   case $choice in
     1) show_app_summary;;
     2) cf events $APP_NAME;;
     3) cf logs $APP_NAME --recent;;
     4) cf logs $APP_NAME;;
     5) cf env $APP_NAME;;
     6) cf services --app $APP_NAME;;
     7) show_app_usage_events;;
     8) show_app_ip_address;;
     9) show_c2c_policy;;
     10) show_app_ports;;
     11) show_app_stats;;
     12) show_network_policies;;
     13) show_app_routes;;
     14) show_app_health_check;;
     15) show_app_instances;;
     16) show_app_features;;
     17) show_app_metadata;;
     X|x) exit;;
     *) echo "Invalid option";;
   esac
}

show_space_menu() {
  echo "Please select a space to switch to:"
  cf spaces | tail -n +4 | awk '{print NR ") " $0}'
  echo "X) Quit"
  read -p "Enter your choice: " choice
  if [[ $choice =~ ^[0-9]+$ ]]; then
    SPACE_NAME=$(cf spaces | tail -n +4 | sed -n "${choice}p")
    if [[ -n $SPACE_NAME ]]; then
      cf target -s $SPACE_NAME
      cf apps | tail -n +5 | awk '{print NR ") " $1}'
      echo "X) Quit"
      read -p "Enter your choice: " choice2

      case $choice2 in  
        [1-3]) APP_NAME=$(cf apps | tail -n +5 | sed -n "${choice2}p" | awk '{print $1}')
               show_app_info_menu;;  
        X|x) exit;;  
        *) echo "Invalid option";;  
      esac  

    else  
      echo "Invalid space name"  
      exit  
    fi  
  elif [[ $choice == X || $choice == x ]]; then  
    exit  
  else  
    echo "Invalid option"  
    exit  
  fi  
  }

show_main_menu() {
   echo "Please select an option:"
   echo "1) Show space menu"
   echo "2) Create an app"
   echo "3) Update an app"
   echo "4) Delete an app"
   echo "5) Scale an app"
   echo "6) Create a route"
   echo "7) Delete a route"
   echo "8) Create a network policy"
   echo "9) Delete a network policy"
   echo "X) Quit"

   read -p "Enter your choice: " choice

   case $choice in
     1) show_space_menu;;
     2) create_app;;
     3) update_app;;
     4) delete_app;;
     5) scale_app;;
     6) create_route;;
     7) delete_route;;
     8) create_network_policy;;
     9) delete_network_policy;;
     X|x) exit;;
     *) echo "Invalid option";;
   esac

}

show_main_menu
