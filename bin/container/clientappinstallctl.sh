#! /bin/bash
app_name=""
app_port=""
vhroot=""
vhdoc=""
lsdir="/usr/local/lsws"

installation_url=""
installation_dir="/tmp/installation_file.tgz"

vhosts_config_url=""
vhosts_config_dir=""

ols_httpd_conf="$lsdir/conf/httpd_config.conf"

EPACE='        '

echow(){
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}

install_vh() {
  set_vh_root
  get_file $installation_url
  install_app
  add_vh
  add_listener
  add_vh_config
  restart_ols
}

set_vh_root() {
  vhroot="$lsdir/$app_name"
  vhdoc="$lsdir/$app_name/html"
}

get_file() {

  installation_url="$1"

	curl -o $installation_dir --GET --location $installation_url

  if [ -e "$installation_dir" ]; then

		file_type=$(file -b "$installation_dir")

    echo $file_type

		if [[ ! $file_type == *"gzip compressed data"* ]]; then
			echo "$installation_url is not tgz format."
      exit
		fi
		
	else
		echo "Can't download installation file $installation_url."
		exit 1
	fi
}

install_app() {
  
  mkdir -p $vhroot/{html,logs,certs}

  cp $installation_dir $vhroot && 
  cd $vhroot
    tar xzf $vhroot/installation_file.tgz --strip-components=1
    
  rm $installation_dir
}

add_vh() {
  new_content="virtualhost $app_name {
    vhRoot                  $app_name/
    configFile              conf/vhosts/$app_name/vhconf.conf
    allowSymbolLink         1
    enableScript            1
    restrained              1
  }"
  printf '%s\n' "$new_content" >> ${ols_httpd_conf}
}

add_listener() {
  new_content="listener $app_name {
    address                 *:$app_port
    secure                  0
    map                     $app_name *
  }"
  printf '%s\n' "$new_content" >> ${ols_httpd_conf}
}

add_vh_config() {
  mkdir $lsdir/conf/vhosts/$app_name
  cp /usr/local/bin/config/vhconf.conf $lsdir/conf/vhosts/$app_name/vhconf.conf
}

restart_ols() {
  /usr/local/lsws/bin/lswsctrl restart
  exit;
}

help_message() {
	echo -e "\033[1mOPTIONS\033[0m"
    echow '-A, -app [myapp] -D, --installation_url [https://website/myapp.tar.gz]'
    echo "${EPACE}${EPACE}Example: clientappinstallctl.sh --app myapp --installation_url https://website/myapp.tar.gz"
    echow '-H, --help'
    echo "${EPACE}${EPACE}Display help and exit."
    exit 0
}

check_input(){
    if [ -z "${1}" ]; then
        help_message
        exit 1
    fi
}

while [ ! -z "${1}" ]; do
	case ${1} in
		-[hH] | -help | --help)
			help_message
			;;
		-[a] | -app | --app) shift
			check_input "${1}"
			app_name="${1}"
			;;
    -[p] | -port | --port) shift
			check_input "${1}"
			app_port="${1}"
			;;
		-[i] | -installation_url | --installation_url) shift
			check_input "${1}"
			installation_url="${1}"
			;;
		-vhosts_config_url | --vhosts_config_url) shift
      check_input "${1}"
			vhosts_config_url="${1}"
		  ;;
    -install_app | --install_app) shift
			app_name=$1
      app_port=$2
			installation_url=$3
      install_vh
		  ;;   
		*)             
	esac
	shift
done