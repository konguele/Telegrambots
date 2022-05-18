#!/bin/bash

#############################################################################
#                       Version 1.0.0 (21/03/2022)                          #
############################################################################

#############################################################################
# Copyright 2022 Juanjo García. Propiedad de Stilu Group
#
# Contacto para el soporte al cliente:
# @ e-mail      juanjo.gmanzano@gmail.com
# > GitHub      konguele
# > Instagram   @konguele
#############################################################################

#############################################################################
#                              VARIABLES                                    #
#############################################################################

# Versión Robocop
ROBOCOP_VERSION='1.0'

ME=$(whoami)
USER_ROBOCOP=$(cut -d':' -f1 /etc/passwd | grep -i robocop)
SERVER=$(hostname)
if [ -f /usr/bin/robocop_source ]; then
        source /home/ansible/git/Telegrambots/robocop/conf/robocop.conf 1>/dev/null 2>&1
fi
TIME_FOLDER=${HOME_DIRECTORY}monit/time/3s
#############################################################################
#                               ARGUMENTS                                   #
#############################################################################

# habilitar todas las opciones
while test -n "$1"; do
    case "$1" in
        # options
        --version|-version|version|--v|-v)
            ARGUMENT_VERSION='1'
            ARGUMENT_OPTION='1'
            shift
            ;;
        --info|-info)
            ARGUMENT_INFO='1'
            ARGUMENT_OPTION='1'
            shift
            ;;
        --help|-help|help|--h|-h)
            ARGUMENT_HELP='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --install|install|-i)
            ARGUMENT_INSTALL='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

	--reboot|reboot)
	    ARGUMENT_REBOOT='1'
	    ARGUMENT_OPTION='1'
	    shift
	    ;;

        --cron)
            ARGUMENT_CRON='1'
            ARGUMENT_OPTION='1'
            shift
            ;;
        --start)
            ARGUMENT_START='1'
            ARGUMENT_OPTION='1'
            shift
            ;;
        --stop)
            ARGUMENT_STOP='1'
            ARGUMENT_OPTION='1'
            shift
            ;;
        --uninstall)
            ARGUMENT_UNINSTALL='1'
            ARGUMENT_OPTION='1'
            shift
            ;;
        --maintenance)
            ARGUMENT_MAINTENANCE='1'
            ARGUMENT_OPTION='1'
            shift
            ;;
        --delete)
            ARGUMENT_DELETE='1'
            ARGUMENT_OPTION='1'
            shift
            ;;
	--kill_proc)
            ARGUMENT_KILL_PROC='1'
            ARGUMENT_OPTION='1'
	    PROCESS=$2
            shift
            ;;
	--start_proc)
            ARGUMENT_START_PROC='1'
            ARGUMENT_OPTION='1'
	    PROCESS=$2
            shift
            ;;
	--stop_proc)
            ARGUMENT_STOP_PROC='1'
            ARGUMENT_OPTION='1'
	    PROCESS=$2
            shift
            ;;

        # features
        --overview|overview)
            ARGUMENT_OVERVIEW='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        --metrics|metrics)
            ARGUMENT_METRICS='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;
        --alert|alert)
            ARGUMENT_ALERT='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        --install_updates|install_updates)
            ARGUMENT_UPDATES='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        # Métodos
        --cli|cli)
            ARGUMENT_CLI='1'
            ARGUMENT_METHOD='1'
            shift
            ;;

        --robocop|robocop)
            ARGUMENT_ROBOCOP='1'
            ARGUMENT_METHOD='1'
            shift
            ;;

        --email|email)
            ARGUMENT_EMAIL='1'
            ARGUMENT_METHOD='1'
            shift
            ;;

        # metrics
        --cpu|-cpu|cpu)
            ARGUMENT_CPU='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;
        --memory|-mem|memory|mem)
            ARGUMENT_MEMORY='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;
        --fs|-fs|fs)
            ARGUMENT_FS='1'
            ARGUMENT_FEATURE='1'
            FS=$2
            shift
            ;;
        --server)
            AUTOCRON='1'
            SERVER=$2
            shift
            ;;
	--server_group|server_group)
	    ARGUMENT_GROUP='1'
	    SERVER=$2
	    shift
	    ;;
        --ping)
            ARGUMENT_PING='1'
            shift
            ;;
        --service|-service|service)
            ARGUMENT_SERVICE='1'
            ARGUMENT_FEATURE='1'
            SERVICE=$2
            PROCESS=$3
            shift
            ;;
        --url)
            ARGUMENT_WEB='1'
            WEBSITE=$2
            shift
            ;;
        --time|-time|time)
            ARGUMENT_TIME='1'
            MAINT_TIME=$2
            shift
            ;;
        --update|-update|update)
            ARGUMENT_UPDATE='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        # otro
        *)
            ARGUMENT_NONE='1'
            shift
            ;;
    esac
done

#############################################################################
#                               INSTALADOR                                  #
#############################################################################

function robocop_install {
        internet_requerido

        # Comprobamos que exista el home directory
        source robocop.conf
        if [ "${HOME_DIRECTORY}" == "poner_directorio" ]; then
                echo "[?] ¿En qué directorio vas a instalar Robocop?"
                read HOME_DIRECTORY
        fi

	if [ "${USER_ROBOCOP}" == "robocop" ]; then
                        echo "[i] Buen trabajo, el usuario robocop existe."
                        echo "[!] No olvides compartir las ssh keys, para un correcto funcionamiento"
        else
                        echo "[?] El usuario robocop no existe, ¿con qué usuario deseas trabajar?"
                        echo "[i] Recuerda que si no existe o no has compartido las ssh keys, no funcionará"
                        read -r -p '[?] Añade el nombre del usuario: ' USER
        fi

        # Creamos la estructura de carpetas
        if [ -d ${HOME_DIRECTORY} ]; then
                if [ -f ${HOME_DIRECTORY}logs/robocop.log ] && [ -f ${HOME_DIRECTORY}conf/robocop.conf ]; then
                        source ${HOME_DIRECTORY}conf/robocop.conf
                        echo "${DATE} Llamada a Robocop...">>${HOME_DIRECTORY}logs/robocop.log

                else
                        mkdir ${HOME_DIRECTORY}logs
                        touch ${HOME_DIRECTORY}logs/robocop.log
                        touch ${HOME_DIRECTORY}logs/robocop_telegram.log
			touch ${HOME_DIRECTORY}logs/bot.log
                        chmod  755 ${HOME_DIRECTORY}logs
                        chown -R ${USER}: ${HOME_DIRECTORY}logs
                        mkdir ${HOME_DIRECTORY}conf
                        chmod 755 ${HOME_DIRECTORY}conf
                        wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/stable/robocop.conf -O ${HOME_DIRECTORY}conf/robocop.conf
                        chown -R ${USER}: ${HOME_DIRECTORY}conf
                        mkdir ${HOME_DIRECTORY}monit
                        mkdir ${HOME_DIRECTORY}monit/exe
                        mkdir ${HOME_DIRECTORY}monit/time
                        mkdir ${HOME_DIRECTORY}monit/maintenance
                        chmod -R 755 ${HOME_DIRECTORY}monit
                        chown -R ${USER}: ${HOME_DIRECTORY}monit
			mkdir ${HOME_DIRECTORY}telebot
			wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/stable/main.py -O ${HOME_DIRECTORY}telebot/main.py
			wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/stable/check_telebot -O ${HOME_DIRECTORY}telebot/check_telebot
			touch ${HOME_DIRECTORY}telebot/usuarios.txt
			chmod -R 755 ${HOME_DIRECTORY}telebot
                        chown -R ${USER}: ${HOME_DIRECTORY}telebot
			mkdir ${HOME_DIRECTORY}ansible
			mkdir ${HOME_DIRECTORY}ansible/os_updates
			mkdir ${HOME_DIRECTORY}ansible/reboot
			mkdir ${HOME_DIRECTORY}ansible/inventario
			mkdir ${HOME_DIRECTORY}ansible/os_updates/os_updates
			mkdir ${HOME_DIRECTORY}ansible/os_updates/os_updates/tasks
			mkdir ${HOME_DIRECTORY}ansible/os_updates/os_updates/handlers
			chmod -R 755 ${HOME_DIRECTORY}ansible
                        chown -R ${USER}: ${HOME_DIRECTORY}ansible

                fi

        else
                mkdir ${HOME_DIRECTORY}
                mkdir ${HOME_DIRECTORY}logs
                mkdir ${HOME_DIRECTORY}conf
                chmod 755 ${HOME_DIRECTORY}
                wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/stable/robocop.conf -O ${HOME_DIRECTORY}conf/robocop.conf
		source ${HOME_DIRECTORY}conf/robocop.conf

        fi


        # Creamos la ubicación del fichero conf si no existe
        if [ -d ${HOME_DIRECTORY} ]; then
                echo "[+] El directorio ya está creado...">>${HOME_DIRECTORY}logs/robocop.log 2>&1
        else
                mkdir ${HOME_DIRECTORY}
        fi

        # Instalamos el bot
        if [ "${TOKEN}" == 'poner_token' ]; then
                echo '                                                                                            '
                echo '     //   ) )     //   ) )     //   ) )     //   ) )     //   ) )     //   ) )     //   ) ) '
                echo '    //___/ /     //   / /     //___/ /     //   / /     //           //   / /     //___/ /  '
                echo '   / ___ (      //   / /     / __  (      //   / /     //           //   / /     / ____ /   '
                echo '  //   | |     //   / /     //    ) )    //   / /     //           //   / /     //          '
                echo ' //    | |    ((___/ /     //____/ /    ((___/ /     ((____/ /    ((___/ /     //           '
                echo
                echo "robocop ${ROBOCOP_VERSION}"
                echo "Copyright 2022 Juanjo García. Propiedad de Stilu Group."
                echo
                echo "Creado por Juanjo García"
                echo ""
                echo ""
                echo "[!] El barrio va a estar seguro, ROBOCOP ha llegado y se está instalando..."
                echo ""
                echo ""
                echo ""
                read -r -p '[?] Añade el TOKEN del bot: ' TOKEN
                read -r -p '[?] Añade un CHAT ID (Después podrás añadir el resto):   ' CHAT_ID
                sed -i s%'poner_token'%"${TOKEN}"%g ${HOME_DIRECTORY}conf/robocop.conf
                sed -i s%'poner_id'%"${CHAT_ID}"%g ${HOME_DIRECTORY}conf/robocop.conf
		sed -i s%'robocop'%"${USER}"%g ${HOME_DIRECTORY}conf/robocop.conf
                sed -i s%'poner_directorio'%"${HOME_DIRECTORY}"%g ${HOME_DIRECTORY}conf/robocop.conf
		sed -i s%'poner_token'%"${TOKEN}"%g ${HOME_DIRECTORY}telebot/main.py
		sed -i s%'poner_log'%"${HOME_DIRECTORY}logs/bot.log"%g ${HOME_DIRECTORY}telebot/main.py
		sed -i s%'poner_userdir'%"${HOME_DIRECTORY}telebot/usuarios.txt"%g ${HOME_DIRECTORY}telebot/main.py
		sed -i s%'poner_dir'%"${HOME_DIRECTORY}telebot/main.py"%g ${HOME_DIRECTORY}telebot/check_telebot
		sed -i s%'poner_source'%"${HOME_DIRECTORY}conf/robocop.conf"%g ${HOME_DIRECTORY}telebot/check_telebot

                # Actualizar SO
		so_requerimientos
                echo "[+] Instalando dependencias..."
		# instalar dependencias para diferentes administradores de paquetes
                if [ "${PACKAGE_MANAGER}" == "dnf" ]; then
			dnf install -y epel-release
                        dnf install wget git bc ansible python3 --assumeyes --quiet
                elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
                        yum install -y epel-release
			yum install wget git bc ansible python3 --assumeyes --quiet
                elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
                        apt-get install aptitude bc curl git python ansible --assume-yes --quiet
                elif [ "${PACKAGE_MANAGER}" == "pkg" ]; then
                        pkg install bc wget git ansible python
                fi
                echo "[+] instalando la última versión de ROBOCOP..."
                wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/stable/robocop.sh -O /usr/bin/robocop
                #cp ${HOME_DIRECTORY}robocop.sh /usr/bin/robocop
                touch /usr/bin/robocop_source
                echo "source ${HOME_DIRECTORY}conf/robocop.conf" > /usr/bin/robocop_source
                chmod 755 /usr/bin/robocop /usr/bin/robocop_source
		
		echo "[i] Instalamos los scripts de automatización"
		wget --quiet https://raw.githubusercontent.com/konguele/ansible_roles/master/inventario/inv1 -O ${HOME_DIRECTORY}ansible/inventario/inv1
		wget --quiet https://raw.githubusercontent.com/konguele/ansible_roles/master/os_updates/updates.yml -O ${HOME_DIRECTORY}ansible/os_updates/updates.yml
		wget --quiet https://raw.githubusercontent.com/konguele/ansible_roles/master/os_updates/os_updates/tasks/main.yml -O ${HOME_DIRECTORY}ansible/os_updates/os_updates/tasks/main.yml
		wget --quiet https://raw.githubusercontent.com/konguele/ansible_roles/master/os_updates/os_updates/tasks/updates_DEB.yml -O ${HOME_DIRECTORY}ansible/os_updates/os_updates/tasks/updates_DEB.yml
		wget --quiet https://raw.githubusercontent.com/konguele/ansible_roles/master/os_updates/os_updates/tasks/updates_RHEL.yml -O ${HOME_DIRECTORY}ansible/os_updates/os_updates/tasks/updates_RHEL.yml
		wget --quiet https://raw.githubusercontent.com/konguele/ansible_roles/master/os_updates/os_updates/handlers/main.yml -O ${HOME_DIRECTORY}ansible/os_updates/os_updates/handlers/main.yml
		wget --quiet https://raw.githubusercontent.com/konguele/ansible_roles/master/reboot/reboot.yml -O ${HOME_DIRECTORY}ansible/reboot/reboot.yml
				
                # Recargamos el source con los datos buenos
                source ${HOME_DIRECTORY}conf/robocop.conf

                #Enviamos mensaje de prueba
                curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MENSAJE">${HOME_DIRECTORY}logs/robocop_telegram.log 2>&1
                cat ${HOME_DIRECTORY}logs/robocop_telegram.log>>${HOME_DIRECTORY}logs/robocop.log
                ERROR_ENVIO=$(cat ${HOME_DIRECTORY}logs/robocop_telegram.log | grep -i false | wc -l)
                if [ ${ERROR_ENVIO} -ne 0 ]; then
                        echo "ERROR: El mensaje no se ha podido enviar, revisa tu Token y tu usuario de Telegram. Cancelamos la instalación"
                        exit 0
                else
                        echo "[+] El mensaje ha sido enviado correctamente a Telegram"
                fi
		echo "[+] Arrancamos el Telegrambot para que pueda ejecutar tareas..."
                echo "[?] ¿Quieres configurar las alertas de CRON? (si/no): "
                read CRON
                if [ $CRON == 'si' ]; then
                        /bin/bash /usr/bin/robocop --cron
                fi
	# Activamos el job de cron para revisar el bot de Telegram
   	echo '[+] Actualización de cronjob para revisar que el bot de Telegram esté activo...'
        echo -e "# Este cronjob comprueba el bot de Telegram en el horario elegido\n${CRON_JOB_TIME} ${USER} ${HOME_DIRECTORY}telebot/check_telebot" > /etc/cron.d/check_bot
	systemctl restart crond

        elif [ "${TOKEN}" == '' ]; then
                echo "Algo ha salido mal, no se han cargado las variables de entorno. Las cargo y volvemos a empezar :)"
                echo "Si vuelves a ver este mensaje, revisa que exista el fichero ${HOME_DIRECTORY}conf/robocop.conf"
                source ${HOME_DIRECTORY}conf/robocop.conf

        elif [ "${TOKEN}" != 'poner_token' ]; then
                echo "Robocop está instalado y vigilando. Elige una opción o revisa robocop --help"
                echo "Si por el contrario no está instalado y aparece este mensaje, utiliza robocop --uninstall o robocop -u para eliminar cualquier problema"

        fi
}

#############################################################################
#                           FUNCIÓN TELEGRAM                                #
#############################################################################

function desc_metricas_telegram {

    if [ ${ARGUMENT_CPU} == '1' ]; then
        reunir_ping
        reunir_info_servidor
        STATUS_PING=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_ping.log)
        if [ ${STATUS_PING} == KO ]; then
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
                MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        else
                reunir_metricas_cpu
                # crear mensaje para Telegram
                STATUS=$(grep "OK\|KO" ${HOME_DIRECTORY}monit/status_cpu.log)
                if [ ${STATUS} == OK  ]; then
                        STATUS="<b>OK</b> - CPU dentro de los umbrales acordados"
                elif [ ${STATUS} == KO ]; then
                        STATUS="<b>ALARMA!!</b> La CPU supera el umbral ${THRESHOLD_CPU}. El proceso ${PROCESS} tiene un consumo de ${CPU_CONS}!! Revisad lo antes posible"
                fi
        MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n<b>Tiempo activo</b>:  <code>${UPTIME}</code>\\n\\n<b>CPU</b>:         <code>${COMPLETE_LOAD}</code>\\n<b>Status:</b>      <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
        fi
    fi

    if [ ${ARGUMENT_PING} == '1' ]; then
        reunir_ping
        reunir_info_servidor
        # crear mensaje para Telegram
        STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_ping.log)
        if [ ${STATUS} == OK  ]; then
                STATUS="<b>OK</b> - El servidor ${SERVER} responde a ping correctamente"
        else
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
        fi

        MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n<b>Tiempo activo</b>:  <code>${UPTIME}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

    fi

    if [ ${ARGUMENT_MEMORY} == '1' ]; then
        reunir_ping
        reunir_info_servidor
        STATUS_PING=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_ping.log)
        if [ ${STATUS_PING} == KO ]; then
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
                MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        else
                reunir_metricas_memoria
                # crear mensaje para Telegram
                STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_mem.log)
                if [ ${STATUS} == OK  ]; then
                        STATUS="<b>OK</b> - Memoria dentro de los umbrales acordados"
                else
                        STATUS="<b>ALARMA!!</b> La memoria supera el umbral del ${THRESHOLD_MEMORY}. El proceso ${PROCESS} tiene un consumo de ${RAM_CONS}!! Revisad lo antes posible"
                fi

                MESSAGE="$(echo -e "<b>Host:</b>                <code>${SERVER}</code>\\n<b>Tiempo activo</b>:          <code>${UPTIME}</code>\\n\\n<b>MEMORIA:</b>             ${USED_MEMORY}M/${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
        fi

    fi

    if [ ${ARGUMENT_INFO} == '1' ]; then
        reunir_ping
        reunir_info_servidor
        STATUS_PING=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_ping.log)
        if [ ${STATUS_PING} == KO ]; then
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
                MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        else
                reunir_info_servidor
                reunir_info_red
                reunir_info_distro
                reunir_metricas_cpu
                reunir_metricas_memoria
		reunir_metricas_disco
                source ${HOME_DIRECTORY}conf/robocop.conf

                MESSAGE="$(echo -e "<b>-SISTEMA-</b>\\n<b>Host:</b>     <code>${HOSTNAME}</code>\\n<b>OS:</b>   <code>${OPERATING_SYSTEM}</code>\\n<b>Distro:</b>       <code>${DISTRO} ${DISTRO_VERSION}</code>\\n<b>Kernel:</b>   <code>${KERNEL_NAME} ${KERNEL_VERSION}</code>\\n<b>Arquitectura:</b>    <code>${ARCHITECTURE}</code>\\n<b>Tiempo Activo:</b>    <code>${UPTIME}</code>\\n\\n<b>-IP-</b>\\n<b>IP INTERNA:</b>     <code>${INTERNAL_IP_ADDRESS}</code>\\n<b>IP EXTERNA:</b>     <code>${EXTERNAL_IP_ADDRESS}</code>\\n\\n<b>-PERFORMANCE DEL SERVIDOR-</b>\\n<b>CPU:</b>     <code>${COMPLETE_LOAD}</code>\\n<b>MEMORIA:</b>             ${USED_MEMORY}M/${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)\\n<b>Disco:</b>       <code>${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
        fi
     fi

     if [ ${ARGUMENT_FS} == '1' ]; then
        reunir_ping
        reunir_info_servidor
        STATUS_PING=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_ping.log)
        if [ ${STATUS_PING} == KO ]; then
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
                MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
        else
                reunir_info_servidor
                reunir_metricas_disco
                reunir_metricas_threshold

                STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_fs.log)
                if [ ${STATUS} == OK  ]; then
                        STATUS="<b>OK</b> - El FileSystem ${FS} está dentro de los umbrales acordados."
                else
                        STATUS="<b>ALARMA!!</b> El FS ${FS} supera el umbral del ${THRESHOLD_DISK}. Revisad lo antes posible"
                fi


                MESSAGE="$(echo -e "<b>Host:</b>                <code>${SERVER}</code>\\n<b>Tiempo activo:</b>          <code>${UPTIME}</code>\\n\\n<b>Disco:</b>       <code>${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)</code>\\n<b>FS ${FS}:</b>          <code>${CURRENT_FS_USAGE} / ${TOTAL_FS_SIZE} (${CURRENT_FS_PERCENTAGE}%)</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        fi
     fi

     if [ ${ARGUMENT_SERVICE} == '1' ]; then
        reunir_ping
        reunir_info_servidor
        STATUS_PING=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_ping.log)
        if [ ${STATUS_PING} == KO ]; then
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
                MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
        else
                reunir_info_servidor
                reunir_metricas_serv
                STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_service_${SERVICE}.log)
                if [ ${STATUS} == OK  ]; then
                        STATUS="<b>OK</b> - El servicio ${SERVICE} está levantado."
                else
                        STATUS="<b>ALARMA!!</b> El servicio ${SERVICE} está caído. Revisad lo antes posible"
                fi


                MESSAGE="$(echo -e "<b>Host:</b>                <code>${SERVER}</code>\\n<b>Tiempo activo:</b>          <code>${UPTIME}</code>\\n\\n<b>SERVICIO:</b>          <code>${SERVICE}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        fi
     fi

    if [ ${ARGUMENT_WEB} == '1' ]; then

        #reunir_metricas_web
        WEBSITE=$(echo ${WEBSITE} | cut -d "/" -f3)
        if ping -q -c 1 -W 1 ${WEBSITE} >/dev/null; then
                echo "OK" > ${HOME_DIRECTORY}monit/status_web.log
        else
                echo "KO" > ${HOME_DIRECTORY}monit/status_web.log
        fi

        # crear mensaje para Telegram
        STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_web.log)
        if [ ${STATUS} == OK  ]; then
                STATUS="<b>OK</b> - La URL ${WEBSITE} responde correctamente"
        else
                STATUS="<b>KO</b> - La URL ${WEBSITE} está caído. Revisad lo antes posible!!!"
        fi

        MESSAGE="$(echo -e "<b>URL:</b>        <code>${WEBSITE}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

    fi

    if [ ${ARGUMENT_UPDATE} == '1' ]; then
        reunir_ping
        reunir_info_servidor
        STATUS_PING=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_ping.log)
        if [ ${STATUS_PING} == KO ]; then
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
                MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        else
                so_requerimientos
                reunir_info_distro
                reunir_info_servidor
                reunir_pending_updates
                # crear mensaje para Telegram
                STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_updates.log)
                if [ ${STATUS} == OK  ]; then
                        STATUS="NO tenemos actualizaciones pendientes para instalar"
                else
                        STATUS="SI tenemos actualizaciones pendientes. Se pueden instalar directamente desde Telegram con el comando  /install_updates"
                fi

                MESSAGE="$(echo -e "<b>Host:</b>                <code>${SERVER}</code>\\n<b>Tiempo activo</b>:          <code>${UPTIME}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
        fi

    fi



    if [ ${MAINTENANCE} == '1' ]; then
        STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_maintenance.log)
        if [ ${STATUS} == OK ]; then
                STATUS="El Servidor ${SERVER} ha entrado en mantenimiento durante ${MAINT_TIME}"
        else
                STATUS="El Servidor ${SERVER} ha salido de mantenimiento y vuelve a monitorizarse"
        fi

        MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>MAINTENANCE:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

    fi

    if [ ${ARGUMENT_UPDATES} == '1' ]; then
        STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}monit/status_updates.log)
        if [ ${STATUS} == OK ]; then
                STATUS="El Servidor o grupo de servidores ${SERVER} se ha actualizado correctamente"
        else
                STATUS="Las actualizaciones del servidor o grupo de servidores ${SERVER} han fallado. Revisa para volver a ejecutarlas."
        fi

        MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>UPDATES:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

    fi

    if [ ${ARGUMENT_REBOOT} == '1' ]; then
	if ping -q -c 1 -W 1 ${SERVER} >/dev/null; then
		STATUS="El Servidor ${SERVER} se ha reiniciado correctamente"
	else
		STATUS="El Servidor ${SERVER} está tardando más de lo esperado en reiniciar. ¿Puedes validar que funcione correctamente?"
	fi
        MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>STATUS:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

    fi


    if [ ${ARGUMENT_KILL_PROC} == '1' ]; then
     	# requerimientos de la función
     	reunir_info_servidor
     	kill_process
     	if [ ${PID_COUNT} == 0 ]; then
        	STATUS="No existe ningún proceso con el nombre ${PROCESS} activo"
    	elif [ ${PID_COUNT} -gt 1 ]; then
        	STATUS="Debes ser más especificio, existen ${PID_COUNT} procesos con un nombre similar, si es correcto utiliza el comando /stop_proc"
    	else
        	ssh ${USER}@${SERVER} sudo kill -9 ${PID_PROC}
        	STATUS="KILL EJECUTADO. El proceso ${PROCESS} ya no se encuentra en ejecución. Puedes arrancarlo de nuevo con el comando --start_proc en caso necesario"
    	fi
    MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>STATUS:</b>        <code>${STATUS}</code>")"
    TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
    fi

    if [ ${ARGUMENT_START_PROC} == '1' ]; then
	start_process
        STATUS_SERV=$(grep 'OK\|KO' ${HOME_DIRECTORY}logs/status_start.log)
        if [ ${STATUS_SERV} == 'OK' ]; then
                STATUS_PROC=$(grep 'OK\|KO' ${HOME_DIRECTORY}logs/status_proc.log)
                if [ ${STATUS_PROC} == 'OK' ]; then
                        STATUS="Hemos arrancado el servicio del proceso ${PROCESS} correctamente"
                else
                        STATUS="Alerta!! NO hemos podido arrancar el servicio del proceso ${PROCESS}, revisad lo antes posible."
                fi
        else
                STATUS="El proceso ${PROCESS} no existe en el listado de servicios, no podemos arrancarlo."
        fi
	MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n<b>PROCESS:</b>        <code>${PROCESS}</code>\\n\\n<b>STATUS:</b>        <code>${STATUS}</code>")"
    	TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
    fi

    if [ ${ARGUMENT_STOP_PROC} == '1' ]; then
        stop_process
        STATUS_SERV=$(grep 'OK\|KO' ${HOME_DIRECTORY}logs/status_stop.log)
        if [ ${STATUS_SERV} == 'OK' ]; then
                STATUS_PROC=$(grep 'OK\|KO' ${HOME_DIRECTORY}logs/status_proc.log)
                if [ ${STATUS_PROC} == 'OK' ]; then
                        STATUS="Hemos parado el servicio del proceso ${PROCESS} correctamente"
                else
                        STATUS="Alerta!! NO hemos podido parar el servicio del proceso ${PROCESS}, revisad lo antes posible."
                fi
        else
                STATUS="El proceso ${PROCESS} no existe en el listado de servicios, no podemos pararlo."
        fi
        MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n<b>PROCESS:</b>        <code>${PROCESS}</code>\\n\\n<b>STATUS:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
    fi
}
function envio_telegram {

        # Requerimientos de la función
        desc_metricas_telegram
        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$TELEGRAM_MESSAGE">${HOME_DIRECTORY}logs/robocop_telegram.log 2>&1
        cat ${HOME_DIRECTORY}logs/robocop_telegram.log>>${HOME_DIRECTORY}logs/robocop.log
        ERROR_ENVIO=$(cat ${HOME_DIRECTORY}logs/robocop_telegram.log | grep -i false | wc -l)
        if [ ${ERROR_ENVIO} -ne 0 ]; then
                echo "ERROR: El mensaje no se ha podido enviar, revisa tu Token y tu usuario de Telegram. Cancelamos la instalación"
                exit 0
        fi


}

#############################################################################
#                           FUNCIÓN MONIT                                   #
#############################################################################

function monit_job {
        echo "#!/bin/bash">${HOME_DIRECTORY}monit/exe/${MONIT_TIME}
        echo "while true">>${HOME_DIRECTORY}monit/exe/${MONIT_TIME}
        echo "do">>${HOME_DIRECTORY}monit/exe/${MONIT_TIME}
        echo "  sleep ${MONIT_TIME}">>${HOME_DIRECTORY}monit/exe/${MONIT_TIME}
        echo "  ${HOME_DIRECTORY}monit/time/${MONIT_TIME}/* 1>/dev/null 2>&1">>${HOME_DIRECTORY}monit/exe/${MONIT_TIME}
        echo "done">>${HOME_DIRECTORY}monit/exe/${MONIT_TIME}
        chmod 755 ${HOME_DIRECTORY}monit/exe/${MONIT_TIME}
}

function maintenance_mode {
        NUM=0
        MAINT_LETTER=$(echo ${MAINT_TIME} | sed 's/[0-9]//g')
        TIME=$(echo "${MAINT_TIME}" | sed -e 's/.$//')
        echo "[i] El servidor ${SERVER} estará en mantenimiento durante ${MAINT_TIME}"
        if [ ${MAINT_LETTER} == 's' ]; then
                INICIO=$(date | cut -d " " -f 4)
                FIN=$(date -d "+${TIME} seconds" | cut -d " " -f 4)
                echo "[i] El mantenimiento empieza a las ${INICIO} y finalizará a las ${FIN}"
        elif [ ${MAINT_LETTER} == 'm' ]; then
                INICIO=$(date | cut -d " " -f 4)
                FIN=$(date -d "+${TIME} minutes" | cut -d " " -f 4)
                echo "[i] El mantenimiento empieza a las ${INICIO} y finalizará a las ${FIN}"
        elif [ ${MAINT_LETTER} == 'h' ]; then
                INICIO=$(date | cut -d " " -f 4)
                FIN=$(date -d "+${TIME} hours" | cut -d " " -f 4)
                echo "[i] El mantenimiento empieza a las ${INICIO} y finalizará a las ${FIN}"
        elif [ ${MAINT_LETTER} == 'd' ]; then
                INICIO=$(date | cut -d " " -f 4)
                FIN=$(date -d "+${TIME} days")
                echo "[i] El mantenimiento empieza a las ${INICIO} y finalizará el día ${FIN}"
        fi
        STATUS="El Servidor ${SERVER} ha entrado en mantenimiento durante ${MAINT_TIME}"

        MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>MAINTENANCE:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$TELEGRAM_MESSAGE">${HOME_DIRECTORY}logs/robocop_telegram.log 2>&1
        cat ${HOME_DIRECTORY}logs/robocop_telegram.log>>${HOME_DIRECTORY}logs/robocop.log
        ERROR_ENVIO=$(cat ${HOME_DIRECTORY}logs/robocop_telegram.log | grep -i false | wc -l)
        if [ ${ERROR_ENVIO} -ne 0 ]; then
                echo "ERROR: El mensaje no se ha podido enviar, revisa tu Token y tu usuario de Telegram. Cancelamos la instalación"
                exit 0
        fi

        while [ $NUM -le 60 ]; do

                if [ -f ${HOME_DIRECTORY}monit/time/${NUM}s/${SERVER} ]; then
                        if [ -d ${HOME_DIRECTORY}monit/maintenance/${NUM}s ]; then
                                mv ${HOME_DIRECTORY}monit/time/${NUM}s/${SERVER} ${HOME_DIRECTORY}monit/maintenance/${NUM}s/
                        else
                                mkdir ${HOME_DIRECTORY}monit/maintenance/${NUM}s
                                mv ${HOME_DIRECTORY}monit/time/${NUM}s/${SERVER} ${HOME_DIRECTORY}monit/maintenance/${NUM}s/
                        fi
                fi
                if [ -f ${HOME_DIRECTORY}monit/time/${NUM}m/${SERVER} ]; then
                        if [ -d ${HOME_DIRECTORY}monit/maintenance/${NUM}m ]; then
                                mv ${HOME_DIRECTORY}monit/time/${NUM}m/${SERVER} ${HOME_DIRECTORY}monit/maintenance/${NUM}m/
                        else
                                mkdir ${HOME_DIRECTORY}monit/maintenance/${NUM}m
                                mv ${HOME_DIRECTORY}monit/time/${NUM}m/${SERVER} ${HOME_DIRECTORY}monit/maintenance/${NUM}m/
                        fi
                fi
                if [ -f ${HOME_DIRECTORY}monit/time/${NUM}h/${SERVER} ]; then
                        if [ -d ${HOME_DIRECTORY}monit/maintenance/${NUM}h ]; then
                                mv ${HOME_DIRECTORY}monit/time/${NUM}h/${SERVER} ${HOME_DIRECTORY}monit/maintenance/${NUM}h/
                        else
                                mkdir ${HOME_DIRECTORY}monit/maintenance/${NUM}h
                                mv ${HOME_DIRECTORY}monit/time/${NUM}h/${SERVER} ${HOME_DIRECTORY}monit/maintenance/${NUM}h/
                        fi
                fi
                if [ -f ${HOME_DIRECTORY}monit/time/${NUM}d/${SERVER} ]; then
                        if [ -d ${HOME_DIRECTORY}monit/maintenance/${NUM}d ]; then
                                mv ${HOME_DIRECTORY}monit/time/${NUM}d/${SERVER} ${HOME_DIRECTORY}monit/maintenance/${NUM}d/
                        else
                                mkdir ${HOME_DIRECTORY}monit/maintenance/${NUM}d
                                mv ${HOME_DIRECTORY}monit/time/${NUM}d/${SERVER} ${HOME_DIRECTORY}monit/maintenance/${NUM}d/
                        fi
                fi


               let NUM=$NUM+1
        done
        NUM=0
        sleep ${MAINT_TIME}
        while [ $NUM -le 60 ]; do
                if [ -f ${HOME_DIRECTORY}monit/maintenance/${NUM}s/${SERVER} ]; then
                         if [ -d ${HOME_DIRECTORY}monit/time/${NUM}s ]; then
                                 mv ${HOME_DIRECTORY}monit/maintenance/${NUM}s/${SERVER} ${HOME_DIRECTORY}monit/time/${NUM}s/
                         else
                                 mkdir ${HOME_DIRECTORY}monit/time/${NUM}s
                                 mv ${HOME_DIRECTORY}monit/maintenance/${NUM}s/${SERVER} ${HOME_DIRECTORY}monit/time/${NUM}s/
                         fi
                 fi
                 if [ -f ${HOME_DIRECTORY}monit/maintenance/${NUM}m/${SERVER} ]; then
                         if [ -d ${HOME_DIRECTORY}monit/time/${NUM}m ]; then
                                 mv ${HOME_DIRECTORY}monit/maintenance/${NUM}m/${SERVER} ${HOME_DIRECTORY}monit/time/${NUM}m/
                         else
                                 mkdir ${HOME_DIRECTORY}monit/time/${NUM}m
                                 mv ${HOME_DIRECTORY}monit/maintenance/${NUM}m/${SERVER} ${HOME_DIRECTORY}monit/time/${NUM}m/
                         fi
                 fi
                 if [ -f ${HOME_DIRECTORY}monit/maintenance/${NUM}h/${SERVER} ]; then
                         if [ -d ${HOME_DIRECTORY}monit/time/${NUM}h ]; then
                                 mv ${HOME_DIRECTORY}monit/maintenance/${NUM}h/${SERVER} ${HOME_DIRECTORY}monit/time/${NUM}h/
                         else
                                 mkdir ${HOME_DIRECTORY}monit/time/${NUM}h
                                 mv ${HOME_DIRECTORY}monit/maintenance/${NUM}h/${SERVER} ${HOME_DIRECTORY}monit/time/${NUM}s/
                         fi
                 fi
                 if [ -f ${HOME_DIRECTORY}monit/maintenance/${NUM}d/${SERVER} ]; then
                         if [ -d ${HOME_DIRECTORY}monit/time/${NUM}d ]; then
                                 mv ${HOME_DIRECTORY}monit/maintenance/${NUM}d/${SERVER} ${HOME_DIRECTORY}monit/time/${NUM}d/
                         else
                                 mkdir ${HOME_DIRECTORY}monit/time/${NUM}d
                                 mv ${HOME_DIRECTORY}monit/maintenance/${NUM}d/${SERVER} ${HOME_DIRECTORY}monit/time/${NUM}d/
                         fi
                 fi

                 let NUM=$NUM+1
           done
        echo "[i] El servidor ${SERVER} ha finalizado el mantenimiento y volverá a monitorizarse. Si no has finalizado las tareas, vuelve a ejecutar el proceso"
        STATUS="El Servidor ${SERVER} ha finalizado el mantenimiento y volverá a monitorizarse"

        MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>MAINTENANCE:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$TELEGRAM_MESSAGE">${HOME_DIRECTORY}logs/robocop_telegram.log 2>&1
        cat ${HOME_DIRECTORY}logs/robocop_telegram.log>>${HOME_DIRECTORY}logs/robocop.log
        ERROR_ENVIO=$(cat ${HOME_DIRECTORY}logs/robocop_telegram.log | grep -i false | wc -l)
        if [ ${ERROR_ENVIO} -ne 0 ]; then
                echo "ERROR: El mensaje no se ha podido enviar, revisa tu Token y tu usuario de Telegram. Cancelamos la instalación"
                exit 0
        fi

}

#############################################################################
#                           FUNCIONES GENERALES                             #
#############################################################################

function update_os {

    # actualizar las distribuciones modernas basadas en rhel
    if [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        dnf update --assumeyes --quiet
    # actualizar distribuciones antiguas basadas en rhel
    elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
        yum update --assumeyes --quiet
    # actualizar las distribuciones basadas en debian
    elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        apt-get update --quiet && apt-get upgrade --assume-yes --quiet
    fi
}

function start {
        NUM=0

        while [ $NUM -le 60 ]; do

                if [ -f ${HOME_DIRECTORY}monit/exe/${NUM}s ]; then
                        ${HOME_DIRECTORY}monit/exe/${NUM}s &
                fi
                if [ -f ${HOME_DIRECTORY}monit/exe/${NUM}m ]; then
                        ${HOME_DIRECTORY}monit/exe/${NUM}m &
                fi
                if [ -f ${HOME_DIRECTORY}monit/exe/${NUM}h ]; then
                        ${HOME_DIRECTORY}monit/exe/${NUM}h &
                fi
                if [ -f ${HOME_DIRECTORY}monit/exe/${NUM}d ]; then
                        ${HOME_DIRECTORY}monit/exe/${NUM}d &
                fi

                let NUM=$NUM+1
        done
}

function stop {
        kill -9 $(ps -ef | grep -i robocop | awk '{print $2}')>>${HOME_DIRECTORY}logs/robocop.log 2>&1
}

function delete {
        NUM=0
        echo "[i] Procedemos a borrar la monitorización del servidor ${SERVER}"
        while [ $NUM -le 60 ]; do

                if [ -f ${HOME_DIRECTORY}monit/time/${NUM}s/${SERVER} ]; then
                        rm -rf ${HOME_DIRECTORY}monit/time/${NUM}s/${SERVER}
                fi
                if [ -f ${HOME_DIRECTORY}monit/time/${NUM}m/${SERVER} ]; then
                        rm -rf ${HOME_DIRECTORY}monit/time/${NUM}m/${SERVER}
                fi
                if [ -f ${HOME_DIRECTORY}monit/time/${NUM}h/${SERVER} ]; then
                        rm -rf ${HOME_DIRECTORY}monit/time/${NUM}h/${SERVER}
                fi
                if [ -f ${HOME_DIRECTORY}monit/time/${NUM}d/${SERVER} ]; then
                        rm -rf ${HOME_DIRECTORY}monit/time/${NUM}d/${SERVER}
                fi


               let NUM=$NUM+1
        done
        echo "[i] Hemos borrado definitivamente toda la monitorización del servidor ${SERVER}"

}

function updates_installer {
	echo "[i] Vamos a proceder a instalar las actualizaciones del servidor ${SERVER}"
	echo "[?] ¿Seguro que quieres instalarlas? (si/no)"
	read INST
	if [ ${INST} == 'si' ]; then
		if [ ${AUTOCRON} == '1' ] || [ ${ARGUMENT_GROUP} == '1' ]; then
			sed -i s%'poner_hosts'%"${SERVER}"%g ${HOME_DIRECTORY}ansible/os_updates/updates.yml	
			ansible-playbook ${HOME_DIRECTORY}ansible/os_updates/updates.yml -i ${HOME_DIRECTORY}ansible/inventario/inv1
		fi
	else
		echo "[i] No se va a actualizar ningún servidor. Si tienes dudas, recuerda que siempre puedes utilizar la opción robocop --help"
		exit 0
	fi
	sed -i s%"${SERVER}"%"poner_hosts"%g ${HOME_DIRECTORY}ansible/os_updates/updates.yml
	echo "[i] El servidor se ha actualizado correctamente y vuelve a estar funcionando..."
}

function auto_installer {
	if [ ${AUTOCRON} == '1' ] || [ ${ARGUMENT_GROUP} == '1' ]; then
        	sed -i s%'poner_hosts'%"${SERVER}"%g ${HOME_DIRECTORY}ansible/os_updates/updates.yml
                ansible-playbook ${HOME_DIRECTORY}ansible/os_updates/updates.yml -i ${HOME_DIRECTORY}ansible/inventario/inv1 1>/dev/null 2>&1
        fi
	echo "OK" > ${HOME_DIRECTORY}monit/status_updates.log
        envio_telegram
	sed -i s%"${SERVER}"%"poner_hosts"%g ${HOME_DIRECTORY}ansible/os_updates/updates.yml
}

function reboot_server {
	echo "[i] Vamos a proceder a reiniciar el servidor ${SERVER}"
        echo "[?] ¿Seguro que quieres reiniciarlo? (si/no)"
        read REB
        if [ ${REB} == 'si' ]; then
                if [ ${AUTOCRON} == '1' ] || [ ${ARGUMENT_GROUP} == '1' ]; then
                        sed -i s%'poner_hosts'%"${SERVER}"%g ${HOME_DIRECTORY}ansible/reboot/reboot.yml
                        ansible-playbook ${HOME_DIRECTORY}ansible/reboot/reboot.yml -i ${HOME_DIRECTORY}ansible/inventario/inv1
                fi
        else
                echo "[i] NO se va a reiniciar el servidor ${SERVER}. Si tienes dudas, recuerda que siempre puedes utilizar la opción robocop --help"
                exit 0
        fi
	
	sed -i s%"${SERVER}"%"poner_hosts"%g ${HOME_DIRECTORY}ansible/reboot/reboot.yml

	if ping -q -c 1 -W 1 ${SERVER} >/dev/null; then
		echo "[i] Server ${SERVER} have been rebooted"
	else
		echo "El servidor ${SERVER} está tardando en arrancar, revisa que sea correcto."
	fi
}

function auto_reboot {
	if [ ${AUTOCRON} == '1' ] || [ ${ARGUMENT_GROUP} == '1' ]; then
                sed -i s%'poner_hosts'%"${SERVER}"%g ${HOME_DIRECTORY}ansible/reboot/reboot.yml
                ansible-playbook ${HOME_DIRECTORY}ansible/reboot/reboot.yml -i ${HOME_DIRECTORY}ansible/inventario/inv1 1>/dev/null 2>&1
        fi
	sed -i s%"${SERVER}"%"poner_hosts"%g ${HOME_DIRECTORY}ansible/reboot/reboot.yml
	envio_telegram
}

#############################################################################
#                       FUNCIONES DE ERROR                                  #
#############################################################################

function opcion_no_valida {
    echo 'robocop: No es una opción válida. Prueba a añadir algún argumento'
    echo "Usa 'robocop --help' para ver un listado de argumentos. Te ayudará a elegir la opción correcta"
    exit 1
}

function error_de_muchos_argumentos {
    echo 'robocop: Cantidad incorrecta de argumentos'
    echo "Usa 'robocop --help' para ver un listado de argumentos. Te ayudará a elegir la opción correcta"
    exit 1
}

function no_implementado {
    echo 'robocop: esta función aún no se ha implementado. Ojalá pronto'
    exit 1
}

function os_no_soportado {
    echo 'robocop: SO no soportado.'
    exit 1
}

function no_disponible {
    echo 'robocop: La opción o método no está disponible sin el archivo de configuración de robocop.'
   exit 1
}

function no_metodo {
    echo 'robocop: La característica requiere un método y viceversa'
    echo "Usa 'robocop --help' para ver un listado de argumentos. Te ayudará a elegir la opción correcta"
    exit 1
}

function opciones_no_combinan {
    echo 'robocop: las opciones no se pueden usar con características o métodos'
    echo "Usa 'robocop --help' para ver un listado de argumentos. Te ayudará a elegir la opción correcta"
    exit 1
}

function no_internet {
    echo 'robocop: Se requiere acceso a internet. Comprueba que estés conectado.'
    exit 1
}

function error_si_o_no {
    echo "robocop: escribe sí o no y presione enter para continuar."
}

function telegram_deshabilitado {
    echo "robocop: El método de Telegram no está disponible sin la configuración correcta en el archivo de configuración de robocop."
    exit 1
}

function email_deshabilitado {
    echo "robocop: el email del método no está disponible sin la configuración correcta en el archivo de configuración de robocop."
    exit 1
}
function sin_argumentos {
        echo "robocop: ¿Por qué no quieres que haga nada? Añade algún argumento, puedo ser útil :)"
        echo "Usa 'robocop --help' para ver un listado de argumentos. Te ayudará a elegir la opción correcta"
        exit 1
}

#############################################################################
#                       FUNCIONES DE RECOLECCIÓN                            #
#############################################################################
function reunir_info_distro {
    # obtener información del sistema operativo de os-release
    if [ ${SERVER} == ${HOSTNAME} ]; then
	source <(cat /etc/os-release | tr -d '.')
    else
    	source <(ssh ${USER}@${SERVER} cat /etc/os-release | tr -d '.')
    fi

    # poner nombre de distribución, id y versión en variables
    DISTRO="${NAME}"
    DISTRO_ID="${ID}"
    DISTRO_VERSION="${VERSION_ID}"
}

function reunir_info_servidor {
    # información del servidor
    HOSTNAME="$(ssh ${USER}@${SERVER} "uname -n")"
    OPERATING_SYSTEM="$(ssh ${USER}@${SERVER} "uname -o")"
    KERNEL_NAME="$(ssh ${USER}@${SERVER} "uname -s")"
    KERNEL_VERSION="$(ssh ${USER}@${SERVER} "uname -r")"
    ARCHITECTURE="$(ssh ${USER}@${SERVER} "uname -m")"
    UPTIME="$(ssh ${USER}@${SERVER} "uptime -p")"
}

function reunir_info_red {
    # información de la IP interna
    INTERNAL_IP_ADDRESS="$(ssh ${USER}@${SERVER} "hostname -I")"

    # información de la IP externa
    EXTERNAL_IP_ADDRESS="$(ssh ${USER}@${SERVER} "curl --silent ipecho.net/plain")"
}

function reunir_metricas_cpu {
        reunir_metricas_threshold
        # métricas de CPU
        CORE_AMOUNT="$(ssh ${USER}@${SERVER} "grep -c 'cpu cores' /proc/cpuinfo")"
        MAX_LOAD_SERVER="${CORE_AMOUNT}.00"
        COMPLETE_LOAD="$(ssh ${USER}@${SERVER} cat /proc/loadavg | awk '{print $1" "$2" "$3}')"
        CURRENT_LOAD="$(ssh ${USER}@${SERVER} cat /proc/loadavg | awk '{print $3}')"
        CURRENT_LOAD_PERCENTAGE="$(echo "(${CURRENT_LOAD}/${MAX_LOAD_SERVER})*100" | bc -l)"
        CURRENT_LOAD_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_LOAD_PERCENTAGE}" | tr -d '%'))"
	PROCESS="$(ssh ${USER}@${SERVER} ps -Ao comm,pcpu --sort=-pcpu | head -n 2 | tail -n 1 | awk '{print $1}')"
	CPU_CONS="$(ssh ${USER}@${SERVER} ps -Ao comm,pcpu --sort=-pcpu | head -n 2 | tail -n 1 | awk '{print $2}')"
        if [ "${CURRENT_LOAD_PERCENTAGE_ROUNDED}" -lt "${THRESHOLD_CPU_NUMBER}" ]; then
                echo "OK" > ${HOME_DIRECTORY}monit/status_cpu.log
        else
                echo "KO" > ${HOME_DIRECTORY}monit/status_cpu.log
        fi
}

function reunir_metricas_threshold {
    # quitar '%' de umbrales en robocop.conf
    THRESHOLD_CPU_NUMBER="$(echo "${THRESHOLD_CPU}" | tr -d '%')"
    THRESHOLD_MEMORY_NUMBER="$(echo "${THRESHOLD_MEMORY}" | tr -d '%')"
    THRESHOLD_DISK_NUMBER="$(echo "${THRESHOLD_DISK}" | tr -d '%')"
}

function reunir_ping {
    if ping -q -c 1 -W 1 ${SERVER} >/dev/null; then
        echo "OK" > ${HOME_DIRECTORY}monit/status_ping.log
    else
        echo "KO" > ${HOME_DIRECTORY}monit/status_ping.log
    fi
}

function reunir_metricas_memoria {
    # métricas de memoria con la herramienta free
    FREE_VERSION="$(ssh ${USER}@${SERVER} free --version | awk '{ print $NF }' | tr -d '.')"
    reunir_metricas_threshold
    # usa el formato antiguo cuando se use la versión antigua de free
    if [ "${FREE_VERSION}" -le "339" ]; then
        TOTAL_MEMORY="$(ssh ${USER}@${SERVER} free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(ssh ${USER}@${SERVER} free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_MEMORY="$(ssh ${USER}@${SERVER} free -m | awk '/^Mem/ {print $6}')"
        CACHED_MEMORY="$(ssh ${USER}@${SERVER} free -m | awk '/^Mem/ {print $7}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_MEMORY}-${CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    # usa un formato más nuevo cuando se use una versión más nueva de free
    elif [ "${FREE_VERSION}" -gt "339" ]; then
        TOTAL_MEMORY="$(ssh ${USER}@${SERVER} free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(ssh ${USER}@${SERVER} free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_CACHED_MEMORY="$(ssh ${USER}@${SERVER} free -m | awk '/^Mem/ {print $6}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    fi
    
    PROCESS="$(ssh ${USER}@${SERVER} ps aux --sort -rss | head -2 | awk '{print $11}' | tail -1)"
    RAM_CONS="$(ssh ${USER}@${SERVER} ps aux --sort -rss | head -2 | awk '{print $4}' | tail -1)"
    
    if [ "${CURRENT_MEMORY_PERCENTAGE_ROUNDED}" -lt "${THRESHOLD_MEMORY_NUMBER}" ]; then
            echo "OK" > ${HOME_DIRECTORY}monit/status_mem.log
    else
            echo "KO" > ${HOME_DIRECTORY}monit/status_mem.log
    fi	
}

function reunir_metricas_disco {
    # métricas de FS
    reunir_metricas_threshold
    TOTAL_DISK_SIZE="$(ssh ${USER}@${SERVER} df -h / --output=size -x tmpfs -x devtmpfs | sed -n '2 p' | tr -d ' ')"
    CURRENT_DISK_USAGE="$(ssh ${USER}@${SERVER} df -h / --output=used -x tmpfs -x devtmpfs | sed -n '2 p' | tr -d ' ')"
    CURRENT_DISK_PERCENTAGE="$(ssh ${USER}@${SERVER} df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')"
    TOTAL_FS_SIZE="$(ssh ${USER}@${SERVER} df -h ${FS} | awk '{print $2}' | tail -1)"
    CURRENT_FS_USAGE="$(ssh ${USER}@${SERVER} df -h ${FS} | awk '{print $3}' | tail -1)"
    CURRENT_FS_PERCENTAGE="$(ssh ${USER}@${SERVER} df -h ${FS} | awk '{print $5}' | tail -1 | cut -d '%' -f 1)"
    if [ "${CURRENT_FS_PERCENTAGE}" -lt "${THRESHOLD_DISK_NUMBER}" ]; then
        echo "OK" > ${HOME_DIRECTORY}monit/status_fs.log
    else
        echo "KO" > ${HOME_DIRECTORY}monit/status_fs.log
    fi

}

function reunir_metricas_serv {
    # métricas de servicio
        SERVICE_RUN="$(ssh ${USER}@${SERVER} pgrep ${PROCESS} -c)"
	if [ ${SERVICE_RUN} -gt '0' ]; then
                echo "OK" > ${HOME_DIRECTORY}monit/status_service_${SERVICE}.log
        else
                echo "KO" > ${HOME_DIRECTORY}monit/status_service_${SERVICE}.log
        fi
}

function reunir_metricas_web {

    WEBSITE="$(echo ${WEBSITE} | cut -d "/" -f3)"
    if ping -q -c 1 -W 1 ${WEBSITE} >/dev/null; then
        echo "OK" > ${HOME_DIRECTORY}monit/status_web.log
    else
        echo "KO" > ${HOME_DIRECTORY}monit/status_web.log
    fi
}

function reunir_pending_updates {
    PENDING="$(ssh ${USER}@${SERVER} sudo ${PACKAGE_MANAGER} check-update  | sed '1,/^$/d' | wc -l)"
    if [ "${PENDING}" == 0 ]; then
        echo "OK" > ${HOME_DIRECTORY}monit/status_updates.log
    else
        echo "KO" > ${HOME_DIRECTORY}monit/status_updates.log
    fi
}

function kill_process {
    PID_PROC="$(ssh ${USER}@${SERVER} ps aux | grep -v grep | grep ${PROCESS} | awk '{print $2}')"
    PID_COUNT="$(ssh ${USER}@${SERVER} ps aux | grep -v grep | grep ${PROCESS} | wc -l)"
}

function start_process {
    so_requerimientos
    if [ ${SERVICE_MANAGER} == 'systemctl' ]; then
    	CHECK_PROC=$(ssh ${USER}@${SERVER} sudo systemctl list-unit-files --type service --all | grep -i ${PROCESS} | wc -l)
	if [ ${CHECK_PROC} -gt 0 ]; then
		ssh ${USER}@${SERVER} sudo systemctl start ${PROCESS}
		echo "OK" > ${HOME_DIRECTORY}logs/status_start.log
		STATUS_PROC=$(ssh ${USER}@${SERVER} sudo systemctl is-active ${PROCESS})
		if [ ${STATUS_PROC} == 'active' ]; then
			echo "OK" > ${HOME_DIRECTORY}logs/status_proc.log
		else
			echo "KO" > ${HOME_DIRECTORY}logs/status_proc.log
		fi
	else
		echo "KO" > ${HOME_DIRECTORY}logs/status_start.log
	fi 
    elif [ ${SERVICE_MANAGER} == 'service' ]; then
	CHECK_PROC=$(ssh ${USER}@${SERVER} sudo service --status-all | grep -i ${PROCESS} | wc -l)
	if [ ${CHECK_PROC} -gt 0 ]; then
                ssh ${USER}@${SERVER} sudo service ${PROCESS} start
                echo "OK" > ${HOME_DIRECTORY}logs/status_start.log
		STATUS_PROC=$(ssh ${USER}@${SERVER} sudo sudo service ${PROCESS} status | grep running | wc -l)
                if [ ${STATUS_PROC} == '1' ]; then
                        echo "OK" > ${HOME_DIRECTORY}logs/status_proc.log
                else
                        echo "KO" > ${HOME_DIRECTORY}logs/status_proc.log
                fi
        else
                echo "KO" > ${HOME_DIRECTORY}logs/status_start.log
        fi
    elif [ ${SERVICE_MANAGER} == 'rc-service' ]; then
	CHECK_PROC=$(ssh ${USER}@${SERVER} sudo rc-status --list | grep -i ${PROCESS} | wc -l)
	if [ ${CHECK_PROC} -gt 0 ]; then
                ssh ${USER}@${SERVER} sudo rc-service ${PROCESS} start
                echo "OK" > ${HOME_DIRECTORY}logs/status_start.log
        else
                echo "KO" > ${HOME_DIRECTORY}logs/status_start.log
        fi
    fi
}

function stop_process {
    so_requerimientos
    if [ ${SERVICE_MANAGER} == 'systemctl' ]; then
        CHECK_PROC=$(ssh ${USER}@${SERVER} sudo systemctl list-unit-files --type service --all | grep -i ${PROCESS} | wc -l)
        if [ ${CHECK_PROC} -gt 0 ]; then
                ssh ${USER}@${SERVER} sudo systemctl stop ${PROCESS}
                echo "OK" > ${HOME_DIRECTORY}logs/status_stop.log
                STATUS_PROC=$(ssh ${USER}@${SERVER} sudo systemctl is-active ${PROCESS})
                if [ ${STATUS_PROC} == 'inactive' ]; then
                        echo "OK" > ${HOME_DIRECTORY}logs/status_proc.log
                else
                        echo "KO" > ${HOME_DIRECTORY}logs/status_proc.log
                fi
        else
                echo "KO" > ${HOME_DIRECTORY}logs/status_stop.log
        fi
    elif [ ${SERVICE_MANAGER} == 'service' ]; then
        CHECK_PROC=$(ssh ${USER}@${SERVER} sudo service --status-all | grep -i ${PROCESS} | wc -l)
        if [ ${CHECK_PROC} -gt 0 ]; then
                ssh ${USER}@${SERVER} sudo service ${PROCESS} stop
                echo "OK" > ${HOME_DIRECTORY}logs/status_stop.log
                STATUS_PROC=$(ssh ${USER}@${SERVER} sudo sudo service ${PROCESS} status | grep running | wc -l)
                if [ ${STATUS_PROC} == '1' ]; then
                        echo "OK" > ${HOME_DIRECTORY}logs/status_proc.log
                else
                        echo "KO" > ${HOME_DIRECTORY}logs/status_proc.log
                fi
        else
                echo "KO" > ${HOME_DIRECTORY}logs/status_stop.log
        fi
    elif [ ${SERVICE_MANAGER} == 'rc-service' ]; then
        CHECK_PROC=$(ssh ${USER}@${SERVER} sudo rc-status --list | grep -i ${PROCESS} | wc -l)
        if [ ${CHECK_PROC} -gt 0 ]; then
                ssh ${USER}@${SERVER} sudo rc-service ${PROCESS} stop
                echo "OK" > ${HOME_DIRECTORY}logs/status_stop.log
        else
                echo "KO" > ${HOME_DIRECTORY}logs/status_stop.log
        fi
    fi
}

#############################################################################
#                       INFORMACIÓN POR PANTALLA                            #
#############################################################################

function desc_metricas_cpu {
        # requerimientos de la función
        reunir_info_servidor
        reunir_metricas_cpu
        reunir_metricas_threshold

        # salida por línea de comandos
        echo "HOST:             ${HOSTNAME}"
        echo "TIEMPO ACTIVO:    ${UPTIME}"
        echo "CPU:              ${COMPLETE_LOAD}"
        if [ "${CURRENT_LOAD_PERCENTAGE_ROUNDED}" -lt "${THRESHOLD_CPU_NUMBER}" ]; then
                echo "ESTADO CPU: OK"
                echo "OK" > ${HOME_DIRECTORY}monit/status_cpu.log
        else
                echo "ESTADO CPU:       KO"
                echo "ALERTA!! REVISAD CUANTO ANTES"
		echo "PROCESO:		${PROCESS}"
		echo "CONSUMO CPU:	${CPU_CONS}"
                echo "KO" > ${HOME_DIRECTORY}monit/status_cpu.log
                envio_telegram
        fi

    # salir cuando esté hecho
    exit 0
}

function desc_ping {
    if ping -q -c 1 -W 1 ${SERVER} >/dev/null; then
        echo "OK - El servidor ${SERVER} responde con normalidad"
    else
        echo "KO - El servidor ${SERVER} está caído. Revisad lo antes posible!!"
        envio_telegram
    fi

}

function desc_metricas_mem {
    reunir_info_servidor
    reunir_metricas_memoria
    reunir_metricas_threshold

    # salida por línea de comandos

    echo "HOST:             ${HOSTNAME}"
    echo "TIEMPO ACTIVO:    ${UPTIME}"
    echo "MEMORIA:          ${USED_MEMORY}M / ${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)"

   if [ "${CURRENT_MEMORY_PERCENTAGE_ROUNDED}" -lt "${THRESHOLD_MEMORY_NUMBER}" ]; then
            echo "ESTADO MEMORIA:       OK"
            echo "OK" > ${HOME_DIRECTORY}monit/status_mem.log
    else
            echo "ESTADO MEMORIA:       KO"
            echo "ALERTA!! REVISAD CUANTO ANTES"
	    echo "PROCESO:		${PROCESS}"
	    echo "CONSUMO RAM:		${RAM_CONS}"
            echo "KO" > ${HOME_DIRECTORY}monit/status_mem.log
            envio_telegram
    fi

    # salir cuando esté hecho
    exit 0

}

function desc_caracteristicas_info {
    # requerimientos de la función
    reunir_info_servidor
    reunir_info_red
    reunir_info_distro
    reunir_metricas_cpu
    reunir_metricas_memoria
    reunir_metricas_disco

    # descripción general del servidor de salida por línea de comando
    echo "SISTEMA"
    echo "HOST:             ${HOSTNAME}"
    echo "OS:               ${OPERATING_SYSTEM}"
    echo "DISTRO:           ${DISTRO} ${DISTRO_VERSION}"
    echo "KERNEL:           ${KERNEL_NAME} ${KERNEL_VERSION}"
    echo "ARQUITECTURA:     ${ARCHITECTURE}"
    echo "TIEMPO ACTIVO:    ${UPTIME}"
    echo
    echo 'IP INTERNA:'
    printf '%s\n'           ${INTERNAL_IP_ADDRESS}
    echo
    echo "IP EXTERNA:       ${EXTERNAL_IP_ADDRESS}"
    echo
    echo 'PERFORMANCE SERVIDOR'
    echo "CPU:           ${COMPLETE_LOAD}"
    echo "MEMORIA:       ${USED_MEMORY}M / ${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)"
    echo "DISCO:         ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)"

    # salir cuando esté hecho
    exit 0
}

function desc_metricas_disk {
        # requerimientos de la función
        reunir_info_servidor
        reunir_metricas_disco
        reunir_metricas_threshold

        # salida por línea de comandos
        echo "HOST:             ${HOSTNAME}"
        echo "TIEMPO ACTIVO:    ${UPTIME}"
        echo "DISCO:            ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)"
        echo "FS ${FS}:         ${CURRENT_FS_USAGE} / ${TOTAL_FS_SIZE} (${CURRENT_FS_PERCENTAGE}%)"
        if [ "${CURRENT_FS_PERCENTAGE}" -lt "${THRESHOLD_DISK_NUMBER}" ]; then
                echo "ESTADO FS ${FS}: OK"
                echo "OK" > ${HOME_DIRECTORY}monit/status_fs.log
        else
                echo "ESTADO FS ${FS}:       KO"
                echo "ALERTA!! REVISAD CUANTO ANTES"
                echo "KO" > ${HOME_DIRECTORY}monit/status_fs.log
                envio_telegram
        fi

    # salir cuando esté hecho
    exit 0
}

function desc_service {
        reunir_info_servidor
        reunir_metricas_serv
        if [ ${SERVICE_RUN} -gt '0' ]; then
                echo "ESTADO SERVICIO ${SERVICE}:       OK"
                echo "OK" > ${HOME_DIRECTORY}monit/status_service_${SERVICE}.log
        else
                echo "ESTADO SERVICIO ${SERVICE}:       KO"
                echo "ALERTA!! REVISAD CUANTO ANTES."
                echo "KO" > ${HOME_DIRECTORY}monit/status_service_${SERVICE}.log
                envio_telegram
        fi

}

function desc_web {
    WEBSITE=$(echo ${WEBSITE} | cut -d "/" -f3)
    if ping -q -c 1 -W 1 ${WEBSITE} >/dev/null; then
        echo "OK - La web ${WEBSITE} está funcionando"
    else
        echo "KO - La web ${WEBSITE} está caída. Revisad lo antes posible!!"
        envio_telegram
    fi

}

function desc_update {
    so_requerimientos
    reunir_info_distro
    reunir_info_servidor
    reunir_pending_updates
    if [ ${PENDING} == 0 ]; then
        echo "No tenemos actualizaciones pendientes en el servidor ${SERVER}"
    else
        echo "Tenemos actualizaciones pendientes en el servidor ${SERVER}. Instálalas cuanto antes."
        echo "Recuerda que puedes hacerlo desde Telegram con la opción /updates"
        envio_telegram
    fi

}

function desc_kill {
     # requerimientos de la función
     reunir_info_servidor
     kill_process
     if [ ${PID_COUNT} == 0 ]; then
        echo "No existe ningún proceso con el nombre ${PROCESS} en ejecución"
        exit 0
    elif [ ${PID_COUNT} -gt 1 ]; then
        echo "Debes ser más especificio, existen ${PID_COUNT} procesos con un nombre similar, si es correcto utiliza el comando --stop_proc"
        exit 0
    else
	ssh ${USER}@${SERVER} sudo kill -9 ${PID_PROC}
     	echo "El proceso ${PROCESS} ya no se encuentra en ejecución. Puedes arrancarlo de nuevo con el comando --start_proc en caso necesario"
    fi	

}

function desc_start_proc {
	start_process
	STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}logs/status_start.log)
	if [ ${STATUS} == 'OK' ]; then
		STATUS_PROC=$(grep 'OK\|KO' ${HOME_DIRECTORY}logs/status_proc.log)
		if [ ${STATUS_PROC} == 'OK' ]; then
			echo "[i] ROBOCOP: Hemos arrancado el servicio del proceso ${PROCESS} correctamente"
		else
			echo "[!] ROBOCOP: Alerta!! NO hemos podido arrancar el servicio del proceso ${PROCESS}, revisad lo antes posible."
		fi
	else
		echo "[!] ROBOCOP: El proceso ${PROCESS} no existe en el listado de servicios, no podemos arrancarlo."
	fi
}

function desc_stop_proc {
        stop_process
        STATUS=$(grep 'OK\|KO' ${HOME_DIRECTORY}logs/status_stop.log)
        if [ ${STATUS} == 'OK' ]; then
                STATUS_PROC=$(grep 'OK\|KO' ${HOME_DIRECTORY}logs/status_proc.log)
                if [ ${STATUS_PROC} == 'OK' ]; then
                        echo "[i] ROBOCOP: Hemos parado el servicio del proceso ${PROCESS} correctamente"
                else
                        echo "[!] ROBOCOP: Alerta!! NO hemos podido parar el servicio del proceso ${PROCESS}, revisad lo antes posible."
                fi
        else
                echo "[!] ROBOCOP: El proceso ${PROCESS} no existe en el listado de servicios, no podemos pararlo."
        fi
}

#############################################################################
#                       FUNCIONES DE GESTIÓN                                #
#############################################################################
function robocop_install_check {
    # comprobar si robocop.conf ya está instalado
    if [ -f /etc/robocop/robocop.conf ]; then
        # si es cierto, pregunte al usuario si se pretende una reinstalación
        while true
            do
                read -r -p '[?] ROBOCOP ya está instalado, ¿te gustaría reinstalarlo? (si/no): ' REINSTALL
                [ "${REINSTALL}" = "si" ] || [ "${REINSTALL}" = "no" ] && break
                error_si_o_no
            done

        # salir si no es intencionado
        if [ "${REINSTALL}" = "no" ]; then
            exit 0
        fi

        # reinstalando ROBOCOP
        if [ "${REINSTALL}" = "si" ]; then
            echo "[!] ROBOCOP será reinstalado ahora..."
            robocop_install
        fi
    else
        # si robocop no está instalado actualmente, instálelo de inmediato
        robocop_install
    fi
}

function robocop_help {
    echo
    echo '     //   ) )     //   ) )     //   ) )     //   ) )     //   ) )     //   ) )     //   ) ) '
    echo '    //___/ /     //   / /     //___/ /     //   / /     //           //   / /     //___/ /  '
    echo '   / ___ (      //   / /     / __  (      //   / /     //           //   / /     / ____ /   '
    echo '  //   | |     //   / /     //    ) )    //   / /     //           //   / /     //          '
    echo ' //    | |    ((___/ /     //____/ /    ((___/ /     ((____/ /    ((___/ /     //           '
    echo '                       Creado por Juanjo García Para Stilu Group                            '
    echo
    echo "Uso:"
    echo " robocop [caracteristica]... [método]..."
    echo " robocop [opción]..."
    echo " Ejemplo: robocop --metrics --cpu --server SERVER"
    echo
    echo "Caracteristicas:"
    echo " --overview        Mostrar descripción general del servidor"
    echo " --metrics         Mostrar las métricas"
    echo " --alert           Mostrar el estado de las alarmas"
    echo " --updates         Mostrar las actualizaciones disponibles del servidor"
    echo " --eol             Mostrar el estado de fin de vida del sistema operativo"
    echo " --knownusers      Agrega un Chat ID para aceptar los comandos desde allí"
    echo " --addserver       Añade servidor nuevo a monitorizar"
    echo
    echo
    echo "Métodos:"
    echo " --cli             Salida [característica] a la línea de comando"
    echo " --robocop         Salida [característica] al bot de Telegram"
    echo "--email            Enviar [característica] a correo electrónico"
    echo
    echo "Opciones:"
    echo " --cron            Efectuar cambios de cron desde la configuración de robocop"
    echo " --validate        Comprobar la validez de robocop.conf"
    echo " --install         Instala robocop en el sistema y desbloquea todas las funciones"
    echo " --upgrade         Actualiza robocop a la última versión estable"
    echo " --uninstall       Desinstala robocop del sistema"
    echo " --help            Mostrar esta ayuda y salir"
    echo " --version         Mostrar información de la versión y salir"
}

function ROBOCOP_VERSION {
    echo
    echo '     //   ) )     //   ) )     //   ) )     //   ) )     //   ) )     //   ) )     //   ) ) '
    echo '    //___/ /     //   / /     //___/ /     //   / /     //           //   / /     //___/ /  '
    echo '   / ___ (      //   / /     / __  (      //   / /     //           //   / /     / ____ /   '
    echo '  //   | |     //   / /     //    ) )    //   / /     //           //   / /     //          '
    echo ' //    | |    ((___/ /     //____/ /    ((___/ /     ((____/ /    ((___/ /     //           '
    echo
    echo "robocop ${ROBOCOP_VERSION}"
    echo "Copyright 2022 Juanjo García. Propiedad de Stilu Group."
    echo
    echo "Creado por Juanjo García"
}

function robocop_uninstall {
    # preguntar si se pretendía desinstalar
    while true
        do
            read -r -p '[?] ¿Estás seguro que quieres eliminar al mejor policía de todos los tiempos? (si/no): ' UNINSTALL
            [ "${UNINSTALL}" = "si" ] || [ "${UNINSTALL}" = "no" ] && break
            error_si_o_no
       done

        # salir si no se pretendía
        if [ "${UNINSTALL}" = "no" ]; then
            exit 0
        fi

        # uninstall when intended
        if [ "${UNINSTALL}" = "si" ]; then
            echo "[i] ROBOCOP se jubilará ahora..."
            echo "[-] Eliminando la monitorización de ROBOCOP del sistema..."
            echo "[-] Eliminando robocop.conf del sistema..."
            echo "[-] Eliminando ROBOCOP del sistema..."
            rm -f /usr/bin/robocop
	    #Enviamos mensaje de despedida
            curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MENSAJE_ADIOS">${HOME_DIRECTORY}logs/robocop_telegram.log 2>&1
            cat ${HOME_DIRECTORY}logs/robocop_telegram.log>>${HOME_DIRECTORY}logs/robocop.log
            ERROR_ENVIO=$(cat ${HOME_DIRECTORY}logs/robocop_telegram.log | grep -i false | wc -l)
            if [ ${ERROR_ENVIO} -ne 0 ]; then
                echo "ERROR: El mensaje no se ha podido enviar, pero ya nada importa... No estaré más en tus sistemas."
                exit 0
            fi
            echo "[-] Eliminando los directorios..."
            rm -rf ${HOME_DIRECTORY}conf ${HOME_DIRECTORY}monit ${HOME_DIRECTORY}logs ${HOME_DIRECTORY}ansible ${HOME_DIRECTORY}telebot
	    echo "[-] Eliminando telebot..."
	    rm -rf /etc/cron.d/check_bot
	    kill -9 $(ps -ef | grep -i main.py | awk '{print $2}') 1>/dev/null 2>&1
	    kill -9 $(ps -ef | grep -i robocop | awk '{print $2}') 1>/dev/null 2>&1
            echo "[i] Espero que ROBOCOP haya servidor con honores, ya se ha retirado a descansar a su pisito en Menorca..."
	    rm -f /usr/bin/robocop
            exit 0
        fi
}

function borrar_cron {
    echo '*** ACTUALIZACIÓN DE CRONJOBS ***'
    # elimina cronjobs para que las tareas automatizadas también se puedan desactivar
    echo '[-] Eliminando antiguos cronjobs de robocop...'
    rm -f /etc/cron.d/robocop_*

}

function robocop_cron {

    echo '*** ACTUALIZACIÓN DE JOBS AUTOMÁTICOS ***'

    # actualizar tareas automatizadas
    echo "[?] ¿Quieres configurar un servidor, una URL o una RED?"
    echo "[?] a) Servidor"
    echo "[?] b) URL"
    echo "[?] c) Red"
    read -r -p '[?] Elige una opción: ' OPT

    case $OPT in
        a)
         echo "[?] ¿En qué servidor quieres configurar CRON? "
         read SERVER
         echo "[?] ¿Quieres que la monitorización se ejecute en un momento concreto? 1 vez al día, cada 2 horas... Por defecto refresca cada 3 segundos (si/no)"
         read OPT
         if [ ${OPT} == "si" ]; then
                echo "[?] ¿Cada cuanto tiempo quieres ejecutarlo? (Default: 3s)"
                echo "[i] Por defecto se ejecuta cada 3 segundos"
                echo "[?] a) Segundos"
                echo "[?] b) Minutos"
                echo "[?] c) Horas"
                echo "[?] d) Días"
                echo "[?] e) Default"
                read OPT
                opt_time
                monit_job
         else
                if [ -d ${HOME_DIRECTORY}monit/time/3s ]; then
                        echo "El directorio existe...">>${HOME_DIRECTORY}logs/robocop.log
                        if [ -f ${HOME_DIRECTORY}monit/exe/3s ]; then
                                echo "El fichero existe...">>${HOME_DIRECTORY}logs/robocop.log
                        else
                                monit_job
                        fi
                else
                        mkdir ${HOME_DIRECTORY}monit/time/3s
                        touch ${HOME_DIRECTORY}monit/time/3s/${SERVER}
                        chmod 755 -R ${HOME_DIRECTORY}monit/time/3s
                        monit_job
                fi
         fi

         echo "[?] ¿Quieres configurar la monitorización de CPU? (si/no)"
         read CRON_CPU
         echo "[?] ¿Quieres configurar el ping? (si/no)"
         read CRON_PING
         echo "[?] ¿Quieres configurar la monitorización de Memoria? (si/no)"
         read CRON_MEMORY
         echo "[?] ¿Quieres configurar la monitorización de los FS? (si/no)"
         read CRON_FS
         echo "[?] ¿Quieres configurar la monitorización de los servicios (si/no)"
         read CRON_SERV
         echo "[?] Quieres configurar las actualizaciones pendientes? (si/no)"
         read CRON_UPDATE
         ;;
        b)
         echo "[?] ¿Quieres que la monitorización se ejecute en un momento concreto? 1 vez al día, cada 2 horas... Por defecto refresca cada 3 segundos (si/no)"
         read OPT
         if [ ${OPT} == "si" ]; then
                echo "[?] ¿Cada cuanto tiempo quieres ejecutarlo? (Default: 3s)"
                echo "[i] Por defecto se ejecuta cada 3 segundos"
                echo "[?] a) Segundos"
                echo "[?] b) Minutos"
                echo "[?] c) Horas"
                echo "[?] d) Días"
                echo "[?] e) Default"
                read OPT
                opt_time
                monit_job
         else
                if [ -d ${HOME_DIRECTORY}monit/time/3s ]; then
                        echo "El directorio existe...">>${HOME_DIRECTORY}logs/robocop.log
                        if [ -f ${HOME_DIRECTORY}monit/exe/3s ]; then
                                echo "El fichero existe...">>${HOME_DIRECTORY}logs/robocop.log
                        else
                                monit_job
                        fi
                else
                        mkdir ${HOME_DIRECTORY}monit/time/3s
                        touch ${HOME_DIRECTORY}monit/time/3s/${SERVER}
                        chmod 755 -R ${HOME_DIRECTORY}monit/time/3s
                        monit_job
                fi
         fi


         echo "[?] ¿Quieres configurar la monitorización de las URLs (si/no)"
         read CRON_URL
         ;;
        c)
         echo "Todavía está en construcción"
         ;;
        *)
         echo "No has elegido una opción correcta"
         ;;
esac

    if [ "${ROBOCOP_UPGRADE}" == 'yes' ]; then
        echo '[+] Actualización de cronjob para la actualización automática de robocop...'
        echo -e "# Este cronjob activa la actualización automática de robocop en el horario elegido\n${ROBOCOP_UPGRADE_CRON} root /usr/bin/robocop --silent-upgrade" > /etc/cron.d/robocop_upgrade
    fi
    if [ "${CRON_CPU}" == 'si' ]; then
        if [ -f ${TIME_FOLDER}/${SERVER} ]; then
                grep -i -v "cpu" ${TIME_FOLDER}/${SERVER} > ${TIME_FOLDER}/${SERVER}.temp
                mv ${TIME_FOLDER}/${SERVER}.temp ${TIME_FOLDER}/${SERVER}
        fi
        echo -e "# Este job activa la actualización automática de CPU en robocop en el horario elegido del servidor ${SERVER}\n/usr/bin/robocop --metrics --cpu --server ${SERVER} &> /dev/null" >> ${TIME_FOLDER}/${SERVER}
        chmod -R 755 ${TIME_FOLDER}
    fi
    if [ "${CRON_PING}" == 'si' ]; then
        if [ -f ${TIME_FOLDER}/${SERVER} ]; then
                grep -i -v "ping" ${TIME_FOLDER}/${SERVER} > ${TIME_FOLDER}/${SERVER}.temp
                mv ${TIME_FOLDER}/${SERVER}.temp ${TIME_FOLDER}/${SERVER}
        fi
        echo -e "# Este cronjob activa la actualización automática de PING en robocop en el horario elegido del servidor ${SERVER}\n/usr/bin/robocop --metrics --ping --server ${SERVER} > /dev/null" >> ${TIME_FOLDER}/${SERVER}
        chmod -R 755 ${TIME_FOLDER}
    fi

    if [ "${CRON_MEMORY}" == 'si' ]; then
        if [ -f ${TIME_FOLDER}/${SERVER} ]; then
                grep -i -v "memor" ${TIME_FOLDER}/${SERVER} > ${TIME_FOLDER}/${SERVER}.temp
                mv ${TIME_FOLDER}/${SERVER}.temp ${TIME_FOLDER}/${SERVER}
        fi
        echo -e "# Este job activa la actualización automática de MEMORIA en robocop en el horario elegido del servidor ${SERVER}\n/usr/bin/robocop --metrics --memory --server ${SERVER} > /dev/null" >> ${TIME_FOLDER}/${SERVER}
        chmod -R 755 ${TIME_FOLDER}
    fi

    if [ "${CRON_FS}" == 'si' ]; then
        while [ ${CRON_FS} == "si" ]
        do
                CRON_FS2=si
                echo "[?] ¿Qué FS quieres configurar?"
                read FS
                echo -e "# Este job activa la actualización automática del FS ${FS} en robocop en el horario elegido del servidor ${SERVER}\n/usr/bin/robocop --metrics --fs ${FS} --server ${SERVER} > /dev/null" >> ${TIME_FOLDER}/${SERVER}
                chmod -R 755 ${TIME_FOLDER}
                read -r -p '[?] ¿Quieres configurar otro FS? (si/no): ' CRON_FS
        done
    fi
    if [ "${CRON_SERV}" == 'si' ]; then
        while [ ${CRON_SERV} == "si" ]
        do
                CRON_SERV2=si
                echo "[i] Para configurar el servicio tendrás que decirme el nombre del proceso y del servicio (ej: Proceso: mysql / Servicio: MariaDB)"
                echo "[?] ¿Qué PROCESO quieres configurar?"
                read PROCESS
                echo "[?] ¿Qué SERVICIO quieres configurar?"
                read SERVICE
                echo -e "# Este job activa la actualización automática del servicio ${SERVICE} en robocop en el horario elegido del servidor ${SERVER}\n/usr/bin/robocop --metrics --service ${SERVICE} ${PROCESS} --server ${SERVER} > /dev/null" >> ${TIME_FOLDER}/${SERVER}
                chmod -R 755 ${TIME_FOLDER}
                read -r -p '[?] ¿Quieres configurar otro SERVICIO? (si/no): ' CRON_SERV
        done
    fi

        if [ "${CRON_URL}" == 'si' ]; then
                while [ ${CRON_URL} == "si" ]
                do
                        CRON_URL2=si
                        echo "[?] ¿Qué URL quieres configurar?"
                        read URL
                        FILE=$(echo ${URL} | cut -d "/" -f3)
                        echo -e "# Este cronjob activa la actualización automática de la URL en robocop en el horario elegido del sitio web ${URL}\n/usr/bin/robocop --metrics --url ${URL} > /dev/null" > ${TIME_FOLDER}/${FILE}
                        chmod -R 755 ${TIME_FOLDER}
                        read -r -p '[?] ¿Quieres configurar otra URL? (si/no): ' CRON_URL
                done
        fi

    if [ "${CRON_UPDATE}" == 'si' ]; then
        if [ -f ${TIME_FOLDER}/${SERVER} ]; then
                grep -i -v "update" ${TIME_FOLDER}/${SERVER} > ${TIME_FOLDER}/${SERVER}.temp
                mv ${TIME_FOLDER}/${SERVER}.temp ${TIME_FOLDER}/${SERVER}
        fi
        echo -e "# Este job activa la comprobación automática de UPDATES en robocop en el horario elegido del servidor ${SERVER}\n/usr/bin/robocop --metrics --update --server ${SERVER} > /dev/null" >> ${TIME_FOLDER}/${SERVER}
        chmod -R 755 ${TIME_FOLDER}
    fi

    #if [ "${OVERVIEW_EMAIL}" == 'yes' ]; then
    #    echo '[+] Actualización de cronjob para vistas generales automatizadas del servidor en el correo electrónico...'
    #    echo -e "# Este cronjob activa la descripción general automática del servidor en el correo electrónico en el horario elegido\n${OVERVIEW_CRON} root /usr/bin/robocop --overview --email" > /etc/cron.d/robocop_overview_email
    #fi
    if [ "${METRICS_TELEGRAM}" == 'yes' ]; then
        echo '[+] Actualización de cronjob para métricas de servidor automatizadas en Telegram...'
        echo -e "# Este cronjob activa las métricas del servidor automatizado en Telegram en el horario elegido\n${METRICS_CRON} root /usr/bin/robocop --metrics --robocop" > /etc/cron.d/robocop_metrics_telegram
    fi
    #if [ "${METRICS_EMAIL}" == 'yes' ]; then
    #    echo '[+] Actualización de cronjob para métricas de servidor automatizadas en correo electrónico...'
    #    echo -e "# Este cronjob activa las métricas del servidor automatizado en el correo electrónico en el horario elegido\n${METRICS_CRON} root /usr/bin/robocop --metrics --email" > /etc/cron.d/robocop_metrics_email
    #fi
    if [ "${ALERT_TELEGRAM}" == 'yes' ]; then
        echo '[+] Actualización de cronjob para alertas de estado del servidor automatizadas en Telegram...'
        echo -e "# Este cronjob activa alertas de estado del servidor automatizadas en Telegram en el horario elegido\n${ALERT_CRON} root /usr/bin/robocop --alert --robocop" > /etc/cron.d/robocop_alert_telegram
    fi
    #if [ "${ALERT_EMAIL}" == 'yes' ]; then
    #    echo '[+] Actualización de cronjob para alertas de estado del servidor automatizadas en el correo electrónico...'
    #    echo -e "# Este cronjob activa alertas automáticas de estado del servidor en el correo electrónico en el horario elegido\n${ALERT_CRON} root /usr/bin/robocop --alert --email" > /etc/cron.d/robocop_alert_email
    #fi
    if [ "${UPDATES_TELEGRAM}" == 'yes' ]; then
        echo '[+] Actualización de cronjob para descripciones de actualizaciones automáticas en Telegram...'
        echo -e "# Este cronjob activa resúmenes de actualizaciones automáticas en Telegram en el horario elegido\n${UPDATES_CRON} root /usr/bin/robocop --updates --robocop" > /etc/cron.d/robocop_updates_telegram
    fi
    #if [ "${UPDATES_EMAIL}" == 'yes' ]; then
    #    echo '[+] Actualización de cronjob para resúmenes de actualizaciones automáticas en el correo electrónico...'
    #    echo -e "# Este cronjob activa resúmenes de actualizaciones automáticas en el correo electrónico en el horario elegido\n\n${UPDATES_CRON} root /usr/bin/robocop --updates --email" > /etc/cron.d/robocop_updates_email
    #fi
    if [ "${ME}" != "${USER}" ]; then
        chown -R ${USER}:${USER} ${HOME_DIRECTORY}monit/
    fi
    # proporcionar comentarios al usuario cuando todas las tareas automatizadas estén deshabilitadas
    if [ "${CRON_CPU}" != 'si' ] && \
    [ "${CRON_PING}" != 'si' ] && \
    [ "${CRON_MEMORY}" != 'si' ] && \
    [ "${CRON_FS2}" != 'si' ] && \
    [ "${CRON_SERV2}" != 'si' ] && \
    [ "${CRON_UPDATE}" != 'si' ] && \
    [ "${CRON_URL2}" != 'si' ]; then
        echo '[i] No se han actualizado o creado tareas de monitorización...'
        exit 0
    fi

    echo '[i] Las nuevas tareas han sido creadas correctamente. Para empezar a ejecutarlas, recuerda usar el comando robocop --start'
    exit 0
}

#############################################################################
#                       FUNCIÓN DE OPCIONES                                 #
#############################################################################

function opt_time {
        case $OPT in

                a)
                echo "[?] ¿Cada cuántos segundos quieres ejecutarlo?"
                read TIME
                mkdir ${HOME_DIRECTORY}monit/time/${TIME}s
                TIME_FOLDER=${HOME_DIRECTORY}monit/time/${TIME}s
                MONIT_TIME=${TIME}s
                ;;

                b)
                echo "[?] ¿Cada cuántos minutos quieres ejecutarlo?"
                read TIME
                mkdir ${HOME_DIRECTORY}monit/time/${TIME}m
                TIME_FOLDER=${HOME_DIRECTORY}monit/time/${TIME}m
                MONIT_TIME=${TIME}m
                ;;

                c)
                echo "[?] ¿Cada cuántas horas quieres ejecutarlo?"
                read TIME
                mkdir ${HOME_DIRECTORY}monit/time/${TIME}h
                TIME_FOLDER=${HOME_DIRECTORY}monit/time/${TIME}h
                MONIT_TIME=${TIME}h
                ;;

                d)
                echo "[?] ¿Cada cuántos días quieres ejecutarlo?"
                read TIME
                mkdir ${HOME_DIRECTORY}monit/time/${TIME}d
                TIME_FOLDER=${HOME_DIRECTORY}monit/time/${TIME}d
                MONIT_TIME=${TIME}d
                ;;

                e)
                echo "[i] Se ejecutará cada 3s tal como se establece por defecto"
                ;;

                *)
                echo "[!] No es un valor correcto, se ejecutará cada 3s"
                ;;
        esac

}

#############################################################################
#                     REQUERIMIENTOS DE LAS FUNCIONES                       #
#############################################################################
function so_requerimientos {
    # compruebe si el administrador de paquetes compatible está instalado y complete las variables relevantes
    if [ "$(ssh ${USER}@${SERVER} command -v dnf)" ]; then
        PACKAGE_MANAGER='dnf'
    elif [ "$(ssh ${USER}@${SERVER} command -v yum)" ]; then
        PACKAGE_MANAGER='yum'
    elif [ "$(ssh ${USER}@${SERVER} command -v apt)" ]; then
        PACKAGE_MANAGER='apt'
    elif [ "$(ssh ${USER}@${SERVER} command -v pkg)" ]; then
        PACKAGE_MANAGER='pkg'
    else
        os_no_soportado
    fi

    # comprueba si el administrador de servicios compatible está instalado y complete las variables relevantes
    # systemctl
    if [ "$(ssh ${USER}@${SERVER} command -v systemctl)" ]; then
        SERVICE_MANAGER='systemctl'
    # servicio
    elif [ "$(ssh ${USER}@${SERVER} command -v service)" ]; then
        SERVICE_MANAGER='service'
    # openrc
    elif [ "$(ssh ${USER}@${SERVER} command -v rc-service)" ]; then
        SERVICE_MANAGER='openrc'
    else
        os_no_soportado
    fi
}

function internet_requerido {
    # check internet connection
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo '[i] Info: el dispositivo está conectado a internet...'
    else
        no_internet
    fi
}


#############################################################################
#                           FUNCIÓN PRINCIPAL                               #
#############################################################################

function robocop_main {
    # revisa si el SO está soportado
    #so_requerimientos

    # revisa si los argumentos son válidos
    #argumentos_validos

    # llamada a funciones relevantes basadas en argumentos
    if [ "${ARGUMENT_VERSION}" == '1' ]; then
        ROBOCOP_VERSION
    elif [ "${ARGUMENT_HELP}" == '1' ]; then
        robocop_help
    elif [ "${ARGUMENT_CRON}" == '1' ]; then
        robocop_cron
    elif [ "${ARGUMENT_INSTALL}" == '1' ]; then
        robocop_install_check
    elif [ "${ARGUMENT_UNINSTALL}" == '1' ]; then
        robocop_uninstall
    elif [ "${ARGUMENT_START}" == '1' ]; then
        start
    elif [ "${ARGUMENT_STOP}" == '1' ]; then
        stop
    elif [ "${ARGUMENT_PING}" == '1' ] && [ "${ARGUMENT_METRICS}" == '1' ]; then
        desc_ping
    elif [ "${ARGUMENT_PING}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_caracteristicas_telegram
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_SERVICE}" == '1' ]; then
        desc_service
    elif [ "${ARGUMENT_DELETE}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        delete
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_MEMORY}" == '1' ]; then
        desc_metricas_mem
    elif [ "${ARGUMENT_ROBOCOP}" == '1' ] && [ "${ARGUMENT_MEMORY}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_CPU}" == '1' ]; then
        desc_metricas_cpu
    elif [ "${ARGUMENT_CPU}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
    elif [ "${ARGUMENT_ROBOCOP}" == '1' ] && [ "${ARGUMENT_INFO}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        envio_telegram
    elif [ "${AUTOCRON}" == '1' ] && [ "${ARGUMENT_INFO}" == '1' ]; then
        desc_caracteristicas_info
    elif [ "${ARGUMENT_FS}" == '1' ] && [ "${ARGUMENT_METRICS}" == '1' ]; then
        desc_metricas_disk
    elif [ "${ARGUMENT_FS}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_SERVICE}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_MAINTENANCE}" == '1' ] && [ "${AUTOCRON}" == '1' ] && [ "${ARGUMENT_TIME}" == '1' ]; then
        maintenance_mode
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ] && [ "${AUTOCRON}" == '1' ] || [ "${ARGUMENT_GROUP}" == '1' ]; then
        auto_installer
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${AUTOCRON}" == '1' ] || [ "${ARGUMENT_GROUP}" == '1' ]; then
        updates_installer 
    elif [ "${ARGUMENT_WEB}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_WEB}" == '1' ] && [ "${ARGUMENT_METRICS}" == '1' ]; then
        desc_web
    elif [ "${ARGUMENT_UPDATE}" == '1' ] && [ "${ARGUMENT_METRICS}" == '1' ]; then
        desc_update
    elif [ "${ARGUMENT_UPDATE}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_REBOOT}" == '1' ] && [ "${AUTOCRON}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        auto_reboot
    elif [ "${ARGUMENT_REBOOT}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        reboot_server
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_KILL_PROC}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        desc_kill
    elif [ "${ARGUMENT_ROBOCOP}" == '1' ] && [ "${ARGUMENT_KILL_PROC}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_START_PROC}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        desc_start_proc
    elif [ "${ARGUMENT_ROBOCOP}" == '1' ] && [ "${ARGUMENT_START_PROC}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_STOP_PROC}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        desc_stop_proc
    elif [ "${ARGUMENT_ROBOCOP}" == '1' ] && [ "${ARGUMENT_STOP_PROC}" == '1' ] && [ "${AUTOCRON}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_NONE}" == '1' ]; then
        opcion_no_valida
    elif [ "${1}" == '' ]; then
        sin_argumentos
    fi
}

#############################################################################
#                   LLAMADA A LA FUNCIÓN PRINCIPAL                          #
#############################################################################

robocop_main
