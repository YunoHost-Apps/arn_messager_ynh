Veuillez créer un compte Matrix qui servira vous servira à configurer ARN-Messager. Ses identifiants `botaccount` et `botpassword` seront demandés à l'installation. 

Comment créer un compte Matrix :
- `sudo -u $homeserver $synapse_install_dir/venv/bin/register_new_matrix_user -u $botaccount -p $botpassword -a -c /etc/matrix-$homeserver/homeserver.yaml`
- Use https://github.com/YunoHost-Apps/synapse-admin_ynh
- Use https://element-hq.github.io/synapse/latest/admin_api/register_api.html