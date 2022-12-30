fx_version 'cerulean'
game 'gta5'

author 'AngelicXS'
version '1.5'

client_script 'client.lua'

server_script {
	'server.lua',
    '@mysql-async/lib/MySQL.lua'
}

shared_script 'config.lua'
