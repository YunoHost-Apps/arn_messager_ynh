Please create a Matrix User that you will use to configure ARN-Messager. You will be asked for its identifiers `botaccount` and `botpassword` at install. 

How to create a Matrix User:
- `sudo -u $homeserver $synapse_install_dir/venv/bin/register_new_matrix_user -u $botaccount -p $botpassword -a -c /etc/matrix-$homeserver/homeserver.yaml`
- Via Synapse Admin GUI https://github.com/YunoHost-Apps/synapse-admin_ynh
- See https://element-hq.github.io/synapse/latest/admin_api/register_api.html