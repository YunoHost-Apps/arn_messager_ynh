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

for b in ${bridge//,/ }
do
	if [ "$b" == "mautrix_signal"* ]; then
		botname_sg=$(ynh_app_setting_get --app $b --key botname)
		#command_prefix_sg=$(ynh_app_setting_get --app $b --key command_prefix)
		username_template_sg=$(ynh_app_setting_get --app $b --key username_template) | sed 's/{{.}}//'
	fi
	if [ "$b" == "mautrix_telegram"* ]; then
		botname_tg=$(ynh_app_setting_get --app $b --key botname)
		#command_prefix_tg=$(ynh_app_setting_get --app $b --key command_prefix)
		username_template_tg=$(ynh_app_setting_get --app $b --key username_template) | sed 's/{{.}}//'
	fi
	if [ "$b" == "mautrix_whatsapp"* ]; then
		botname_wa=$(ynh_app_setting_get --app $b --key botname)
		#command_prefix_wa=$(ynh_app_setting_get --app $b --key command_prefix)
		username_template_wa=$(ynh_app_setting_get --app $b --key username_template) | sed 's/{{.}}//'
	fi
done

}

#=================================================
# CONFIG PANEL SETTERS
#=================================================

set_arrays_in_yaml() {
  local -A args_array=([f]=file= [k]=key= [v]=values=)
  local file
  local key
  local values
  ynh_handle_getopts_args "$@"

  config_path="$file" key="$key" values="$values" python3 - <<'END_SCRIPT'
import yaml
config_path=os.environ[config_path"]
key=os.environ["key"]
values=os.environ["values"]

with open(config_path, "r") as infile:
    config = yaml.safe_load(infile)
    config[key]=values.split(",").replace(" ","")

with open(config_path, "w+") as outfile:
    yaml.dump(config, outfile)
END_SCRIPT
}

set__bot_users() {
  ynh_app_setting_set --key=bot_users --value="$bot_users"
  set_arrays_in_yaml --file="$install_dir/config.yaml" --key="bot_users" --values="$bot_users"
  ynh_store_file_checksum "$install_dir/config.yaml"
}


set__admins() {
  ynh_app_setting_set --key=admins --value="$admins"
  set_arrays_in_yaml --file="$install_dir/config.yaml" --key="admins" --values="$admins"
  ynh_store_file_checksum "$install_dir/config.yaml"
}
