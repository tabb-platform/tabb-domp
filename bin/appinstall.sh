#!/usr/bin/env bash
APP_NAME=''
DOMAIN=''
EPACE='        '
TITLE=''
USERNAME=''
PASSWORD=''
EMAIL=''
CANVAS_CONFIGURATION=''

echow(){
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}

help_message(){
    echo -e "\033[1mOPTIONS\033[0m"
    echow '-A, --app [app_name] -D, --domain [DOMAIN_NAME]'
    echo "${EPACE}${EPACE}Example: appinstall.sh -A wordpress -D example.com"
    echo "${EPACE}${EPACE}Will install WordPress CMS under the example.com domain"
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

app_download(){
    docker compose exec litespeed su -c "appinstallctl.sh --app ${1} --domain ${2} --canvas-configuration '${3}'"
    bash bin/webadmin.sh -r
    exit 0
}

main(){
  if [ "${APP_NAME}" = 'wordpress' ] || [ "${APP_NAME}" = 'wp' ]; then
    app_download ${APP_NAME} ${DOMAIN} ${CANVAS_CONFIGURATION} ${TITLE} ${USERNAME} ${PASSWORD} ${EMAIL}
    status_code=$(curl --data-urlencode "weblog_title=${TITLE}" \
         --data-urlencode "user_name=${USERNAME}" \
         --data-urlencode "admin_password=${PASSWORD}" \
         --data-urlencode "admin_password2=${PASSWORD}" \
         --data-urlencode "admin_email=${EMAIL}" \
         --data-urlencode "Submit=Install+WordPress" \
         --silent \
         --write-out '%{http_code}' \
         http://${DOMAIN}/wp-admin/install.php?step=2)
    echo "Status $status_code"
    if [[ "$status_code" -ne 200 ]]; then
      echo "Set up failed, you need to set up manually via your domain"
    else
      echo "Set up full-configured wordpress successfully"
    fi
  fi
  if [ "${APP_NAME}" = 'empty' ] || [ "${APP_NAME}" = 'mt' ]; then
    app_download ${APP_NAME} ${DOMAIN}
  fi
}

check_input ${1}
while [ ! -z "${1}" ]; do
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -[aA] | -app | --app) shift
            check_input "${1}"
            APP_NAME="${1}"
            ;;
        -[dD] | -domain | --domain) shift
            check_input "${1}"
            DOMAIN="${1}"
            ;;
        -[tT] | -title | --title) shift
            check_input "${1}"
            TITLE="${1}"
            ;;
         -[uU] | -username | --username) shift
            check_input "${1}"
            USERNAME="${1}"
            ;;
        -[pP] | -password | --password) shift
            check_input "${1}"
            PASSWORD="${1}"
            ;;
        -[eE] | -email | --email) shift
            check_input "${1}"
            EMAIL="${1}"
            ;;
        -app_port | --app_port) shift
            check_input "${1}"
            APP_PORT="${1}"
            ;;
        -app_url | --app_url) shift
            check_input "${1}"
            APP_URL="${1}"
            ;;
        -canvas-configuration | --canvas-configuration) shift
            CANVAS_CONFIGURATION="${1}"
            ;;
        *) 
            help_message
            ;;              
    esac
    shift
done

main