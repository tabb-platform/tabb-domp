#! /bin/bash

app_name=""

main() {
  case $app_name in
    -[a] | -adminer | --adminer) shift
			install_adminer
			;;  
		*)             
	esac
	shift
}

install_adminer() {
  echo "installing"
  docker exec -it litespeed /usr/local/bin/clientappinstallctl.sh --install_app adminer 32105
}


while [ ! -z "${1}" ]; do
	case ${1} in
    -[a] | -app | --app) shift
			app_name="${1}"
      echo $app_name
      main
			;;  
		*)             
	esac
	shift
done