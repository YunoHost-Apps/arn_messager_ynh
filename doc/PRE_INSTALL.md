Please create a Matrix User that will serve as the ARN-Messager Robot. You will be asked for `botaccount` and `botpassword` at install. Some options:
- `sudo -u $homeserver $synapse_install_dir/venv/bin/register_new_matrix_user -u $botaccount -p $botpassword -a -c /etc/matrix-$homeserver/homeserver.yaml`
- Use https://github.com/YunoHost-Apps/synapse-admin_ynh
- Use https://element-hq.github.io/synapse/latest/admin_api/register_api.html