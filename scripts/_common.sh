#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

get_synapse_db_name() {
	# Parameters: synapse instance identifier
	# Returns: database name
	ynh_app_setting_get --app="$1" --key=db_name
}

#=================================================
# BRIDGES CONFIG SETTERS
#=================================================

set_bridge_config_from_ids() {

# mautrix_ynh settings: synapsenumber botname bot_synapse_admin encryption botadmin botusers enable_relaybot
#mautrix_botname=$(ynh_app_setting_get --app "mautrix_$bridge" --key botname)
# command_prefix=$(ynh_app_setting_get --app "mautrix_$bridge" --key command_prefix)
# username_template=$(ynh_app_setting_get --app "mautrix_$bridge" --key username_template)
#puppet=$(ynh_app_setting_get --app "mautrix_$bridge" --key puppet)
#encryption=$(ynh_app_setting_get --app "mautrix_$bridge" --key encryption)
#enable_relaybot=$(ynh_app_setting_get --app "mautrix_$bridge" --key enable_relaybot)

botname_sg='signalbot'
botname_tg='telegrambot' # OK see bot_username
botname_wa='whatsappbot'
username_template_sg='sg_' # modifier mautrix_signal_ynh avec sg_{{.}}
  # {userid} is replaced with the user ID of the Telegram user.
  #username_template: "telegram_{userid}"
username_template_tg='telegram_' # modifier mautrix_telegram_ynh avec telegram_{userid}
username_template_wa='whatsapp_' # modifier mautrix_whatsapp_ynh avec whatsapp_{{.}}
# à ajouter au config panel de https://github.com/YunoHost-Apps/mautrix_signal_ynh/blob/master/conf/config.yaml#L31
command_prefix_sg='!signal'
# à ajouter au config panel de https://github.com/YunoHost-Apps/mautrix_telegram_ynh/blob/master/conf/config.yaml#L482
command_prefix_tg='!tg'
# à ajouter au config panel de https://github.com/YunoHost-Apps/mautrix_whatsapp_ynh/blob/master/conf/config.yaml#L314
command_prefix_wa='!wa'

# TODO handle im_bridged array
if [ "$bridge" == "mautrix_signal" ]; then
	botname_sg=$(ynh_app_setting_get --app $bridge --key botname)
	#command_prefix_sg=$(ynh_app_setting_get --app $bridge --key command_prefix)
	username_template_sg=$(ynh_app_setting_get --app $bridge --key username_template) | sed 's/{{.}}//'
fi
if [ "$bridge" == "mautrix_telegram" ]; then
	botname_tg=$(ynh_app_setting_get --app $bridge --key botname)
	#command_prefix_tg=$(ynh_app_setting_get --app $bridge --key command_prefix)
	username_template_tg=$(ynh_app_setting_get --app $bridge --key username_template) | sed 's/{{.}}//'
fi
if [ "$bridge" == "mautrix_whatsapp" ]; then
	botname_wa=$(ynh_app_setting_get --app $bridge --key botname)
	#command_prefix_wa=$(ynh_app_setting_get --app $bridge --key command_prefix)
	username_template_wa=$(ynh_app_setting_get --app $bridge --key username_template) | sed 's/{{.}}//'
fi

}

#=================================================
# CONFIG PANEL SETTERS
#=================================================

apply_permissions() {
    set -o noglob # Disable globbing to avoid expansions when passing * as value.
    declare values="list$role"
    newValues="${!values}" # Here we expand the dynamic variable we created in the previous line. ! Does the trick
    newValues="${newValues//\"}"
    usersArray=(${newValues//,/ }) # Split the values using comma (,) as separator.

    if [ -n "$newValues" ]
    then
        #ynh_systemctl --service="$app" --action=stop
        # Get all entries between "permissions:" and "relay:" keys, remove the role part, remove commented parts, format it with newlines and clean whitespaces and double quotes.
        allDefinedEntries=$(awk '/permissions:/{flag=1; next} /relay:/{flag=0} flag' "$install_dir/config.yaml" | sed "/: $role/d" | sed -r 's/: (admin|user|relay)//' | tr -d '[:blank:]' | sed '/^#/d' | tr -d '\"' | tr ',' '\n' )
        # Delete everything from the corresponding role to insert the new defined values. This way we also handle deletion of users.
        sed -i "/permissions:/,/relay:/{/: $role/d;}" "$install_dir/config.yaml"
        # Ensure that entries with value surrounded with quotes are deleted too. E.g. "users".
        sed -i "/permissions:/,/relay:/{/: \"$role\"/d;}" "$install_dir/config.yaml"
      	for user in "${usersArray[@]}"
            do
              if grep -q -x "${user}" <<< "$allDefinedEntries"
              then
                ynh_print_info "User $user already defined in another role."
              else
                sed -i "/permissions:/a \        \\\"$user\": $role" "$install_dir/config.yaml" # Whitespaces are needed so that the file can be correctly parsed
              fi
        done
    fi
    set +o noglob

    ynh_print_info "Users with role $role added in $install_dir/config.yaml"
}

set__listuser() {
  role="user"
  ynh_app_setting_set --key=listuser --value="$listuser"
  apply_permissions
  ynh_store_file_checksum "$install_dir/config.yaml"
}


set__listadmin() {
  role="admin"
  ynh_app_setting_set --key=listadmin --value="$listadmin"
  apply_permissions
  ynh_store_file_checksum "$install_dir/config.yaml"
}
