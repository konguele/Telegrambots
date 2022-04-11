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

#Mensaje de comprobación
MENSAJE="He sido configurado"
ERROR_ENVIO=1
AUTOCRON=0
DATE=$(date)
SERVER=$(hostname)
ARGUMENT_CPU=0
ARGUMENT_PING=0
ARGUMENT_MEMORY=0
ARGUMENT_FS=0
ARGUMENT_INFO=0
ARGUMENT_FS=0
USER_ROBOCOP=$(cut -d':' -f1 /etc/passwd | grep -i robocop)

# Creamos la estructura de carpetas
if [ -d /home/ansible/robocop ]; then
	if [ -f /home/ansible/robocop/logs/robocop.log ] && [ -f /home/ansible/robocop/conf/robocop.conf ]; then
		source /home/ansible/robocop/conf/robocop.conf
		echo "${DATE} Llamada a Robocop...">>/home/ansible/robocop/logs/robocop.log
	else
		mkdir /home/ansible/robocop/logs
		touch /home/ansible/robocop/logs/robocop.log
		touch /home/ansible/robocop/logs/robocop_telegram.log
		chmod 755 /home/ansible/robocop/logs
		chown -R ansible:ansible /home/ansible/robocop/logs
		mkdir /home/ansible/robocop/conf
                chmod 755 /home/ansible/robocop/conf
                cp /home/ansible/robocop/robocop.conf /home/ansible/robocop/conf/robocop.conf
                chown -R ansible:ansible /home/ansible/robocop/conf
		source /home/ansible/robocop/conf/robocop.conf
		mkdir /home/ansible/robocop/monit
		chmod 755 /home/ansible/robocop/conf
		chown -R ansible:ansible /home/ansible/robocop/monit

	fi
	
else
	mkdir /home/ansible/robocop/
	mkdir /home/ansible/robocop/logs
	mkdir /home/ansible/robocop/conf
        chmod 755 /home/ansible/robocop/
	cp /home/ansible/robocop/robocop.conf /home/ansible/robocop/conf/robocop.conf
	source /home/ansible/robocop/conf/robocop.conf

fi


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

        --cron)
            ARGUMENT_CRON='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --uninstall)
            ARGUMENT_UNINSTALL='1'
            ARGUMENT_OPTION='1'
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

        --updates|updates)
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
	--ping)
	    ARGUMENT_PING='1'
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
	so_requerimientos
        reunir_info_distro

	# Creamos la ubicación del fichero conf si no existe
	if [ -d /home/ansible/robocop ]; then
        	echo "[+] El directorio ya está creado...">>/home/ansible/robocop/logs/robocop.log 2>&1
	else
        	mkdir /home/ansible/robocop
	fi


	# Colocamos la última versión del fichero de configuración en su ubicación
	#wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/stable/robocop.conf -O /etc/robocop/robocop.conf
	#chmod 755 /

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
		if [ "${USER_ROBOCOP}" == "robocop" ]; then
			echo "[i] Buen trabajo, el usuario robocop existe."
			echo "[!] No olvides compartir las ssh keys, para un correcto funcionamiento"
		else
			echo "[?] El usuario robocop no existe, ¿con qué usuario deseas trabajar?"
	                echo "[i] Recuerda que si no existe o no has compartido las ssh keys, no funcionará"
        	        read -r -p '[?] Añade el nombre del usuario: ' USER
			sed -i s%'robocop'%"${USER}"%g /home/ansible/robocop/conf/robocop.conf

		fi
		read -r -p '[?] Añade el TOKEN del bot: ' TOKEN
        	read -r -p '[?] Añade un CHAT ID (Después podrás añadir el resto):   ' CHAT_ID
       		sed -i s%'poner_token'%"${TOKEN}"%g /home/ansible/robocop/conf/robocop.conf
       		sed -i s%'poner_id'%"${CHAT_ID}"%g /home/ansible/robocop/conf/robocop.conf
	
		# Actualizar SO
    		echo "[+] Instalando dependencias..."
		echo "[+] instalando la última versión de ROBOCOP..."
    		#wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/${ROBOCOP_BRANCH}/robocop.sh -O /usr/bin/robocop
    		sudo cp /home/ansible/robocop/robocop.sh /usr/bin/robocop
		sudo chmod 755 /usr/bin/robocop

    		# instalar dependencias para diferentes administradores de paquetes
    		if [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        		dnf install wget bc --assumeyes --quiet
   		elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
        		yum install wget bc --assumeyes --quiet
    		elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        		apt-get install aptitude bc curl --assume-yes --quiet
    		elif [ "${PACKAGE_MANAGER}" == "pkg" ]; then
        		pkg install bc wget
    		fi

        	# Recargamos el source con los datos buenos
        	source /home/ansible/robocop/conf/robocop.conf

        	#Enviamos mensaje de prueba
        	curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MENSAJE">/home/ansible/robocop/logs/robocop_telegram.log 2>&1
		cat /home/ansible/robocop/logs/robocop_telegram.log>>/home/ansible/robocop/logs/robocop.log
		ERROR_ENVIO=$(cat /home/ansible/robocop/logs/robocop_telegram.log | grep -i false | wc -l)
		if [ ${ERROR_ENVIO} -ne 0 ]; then
			echo "ERROR: El mensaje no se ha podido enviar, revisa tu Token y tu usuario de Telegram. Cancelamos la instalación"
			exit 0
		else
			echo "[+] El mensaje ha sido enviado correctamente a Telegram"
		fi
		
		echo "[?] ¿Quieres configurar las alertas de CRON? (si/no): "
		read CRON
		if [ $CRON == 'si' ]; then
			/bin/bash /usr/bin/robocop --cron
		fi
		
	elif [ "${TOKEN}" == '' ]; then
                echo "Algo ha salido mal, no se han cargado las variables de entorno. Las cargo y volvemos a empezar :)"
                echo "Si vuelves a ver este mensaje, revisa que exista el fichero /etc/robocop/robocop.conf"
                source /home/ansible/robocop/conf/robocop.conf

	elif [ "${TOKEN}" != 'poner_token' ]; then
		echo "Robocop está instalado y vigilando. Elige una opción o revisa robocop --help"
                echo "Si por el contrario no está instalado y aparece este mensaje, utiliza robocop --uninstall o robocop -u para eliminar cualquier problema"
		
	fi
}

#############################################################################
#                           FUNCIÓN TELEGRAM	                            #
#############################################################################

function desc_metricas_telegram {
    # requerimientos de la función
    reunir_info_servidor
    #reunir_metricas_disco

    if [ ${ARGUMENT_CPU} == '1' ]; then
	reunir_ping
        STATUS_PING=$(grep 'OK\|KO' /home/ansible/robocop/monit/status_ping.log)
        if [ ${STATUS_PING} == KO ]; then
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
                MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        else
		reunir_metricas_cpu
    		# crear mensaje para Telegram
		STATUS=$(grep "OK\|KO" /home/ansible/robocop/monit/status_cpu.log)
		if [ ${STATUS} == OK  ]; then
			STATUS="<b>OK</b> - CPU dentro de los umbrales acordados"
		elif [ ${STATUS} == KO ]; then
			STATUS="<b>ALARMA!!</b> La CPU supera el umbral ${THRESHOLD_CPU}. Revisad lo antes posible"
		fi
	MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n<b>Tiempo activo</b>:  <code>${UPTIME}</code>\\n\\n<b>CPU</b>:         <code>${COMPLETE_LOAD}</code>\\n<b>Status:</b>	<code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"	
	fi
    fi

    if [ ${ARGUMENT_PING} == '1' ]; then
	reunir_ping
	# crear mensaje para Telegram
	STATUS=$(grep 'OK\|KO' /home/ansible/robocop/monit/status_ping.log)
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
	STATUS_PING=$(grep 'OK\|KO' /home/ansible/robocop/monit/status_ping.log)
	if [ ${STATUS_PING} == KO ]; then
		STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
		MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

	else
		reunir_metricas_memoria
        	# crear mensaje para Telegram
        	STATUS=$(grep 'OK\|KO' /home/ansible/robocop/monit/status_mem.log)
        	if [ ${STATUS} == OK  ]; then
                	STATUS="<b>OK</b> - Memoria dentro de los umbrales acordados"
		else
        		STATUS="<b>ALARMA!!</b> La memoria supera el umbral del ${THRESHOLD_MEMORY}. Revisad lo antes posible"
		fi

        	MESSAGE="$(echo -e "<b>Host:</b>        	<code>${SERVER}</code>\\n<b>Tiempo activo</b>:		<code>${UPTIME}</code>\\n\\n<b>MEMORIA:</b>		${USED_MEMORY}M/${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
	fi

    fi

    if [ ${ARGUMENT_INFO} == '1' ]; then
	reunir_ping
        STATUS_PING=$(grep 'OK\|KO' /home/ansible/robocop/monit/status_ping.log)
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
		source /home/ansible/robocop/conf/robocop.conf
		
		MESSAGE="$(echo -e "<b>-SISTEMA-</b>\\n<b>Host:</b>	<code>${HOSTNAME}</code>\\n<b>OS:</b>	<code>${OPERATING_SYSTEM}</code>\\n<b>Distro:</b>	<code>${DISTRO} ${DISTRO_VERSION}</code>\\n<b>Kernel:</b>	<code>${KERNEL_NAME} ${KERNEL_VERSION}</code>\\n<b>Arquitectura:</b>	<code>${ARCHITECTURE}</code>\\n<b>Tiempo Activo:</b>	<code>${UPTIME}</code>\\n\\n<b>-IP-</b>\\n<b>IP INTERNA:</b>     <code>${INTERNAL_IP_ADDRESS}</code>\\n<b>IP EXTERNA:</b>     <code>${EXTERNAL_IP_ADDRESS}</code>\\n\\n<b>-PERFORMANCE DEL SERVIDOR-</b>\\n<b>CPU:</b>     <code>${COMPLETE_LOAD}</code>\\n<b>MEMORIA:</b>             ${USED_MEMORY}M/${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
	fi
     fi

     if [ ${ARGUMENT_FS} == '1' ]; then
        reunir_ping
        STATUS_PING=$(grep 'OK\|KO' /home/ansible/robocop/monit/status_ping.log)
     	if [ ${STATUS_PING} == KO ]; then
                STATUS="<b>KO</b> - El servidor ${SERVER} está caído. Revisad lo antes posible!!!"
                MESSAGE="$(echo -e "<b>Host:</b>        <code>${SERVER}</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"
        else
                reunir_info_servidor
		reunir_metricas_disco
        	reunir_metricas_threshold
		
		STATUS=$(grep 'OK\|KO' /home/ansible/robocop/monit/status_fs.log)
                if [ ${STATUS} == OK  ]; then
                        STATUS="<b>OK</b> - El FileSystem ${FS} está dentro de los umbrales acordados."
                else
                        STATUS="<b>ALARMA!!</b> El FS ${FS} supera el umbral del ${THRESHOLD_DISK}. Revisad lo antes posible"
                fi

	
		MESSAGE="$(echo -e "<b>Host:</b>                <code>${SERVER}</code>\\n<b>Tiempo activo:</b>          <code>${UPTIME}</code>\\n\\n<b>Disco:</b>	<code>${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)</code>\\n<b>FS ${FS}:</b>          <code>${CURRENT_FS_USAGE} / ${TOTAL_FS_SIZE} (${CURRENT_FS_PERCENTAGE}%)</code>\\n\\n<b>Status:</b>        <code>${STATUS}</code>")"
        TELEGRAM_MESSAGE="${MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

        fi
     fi
}

function envio_telegram {

	# Requerimientos de la función
	desc_metricas_telegram

	curl -s -X POST $URL -d chat_id=$ID -d text="$TELEGRAM_MESSAGE">/home/ansible/robocop/logs/robocop_telegram.log 2>&1
	cat /home/ansible/robocop/logs/robocop_telegram.log>>/home/ansible/robocop/logs/robocop.log
        ERROR_ENVIO=$(cat /home/ansible/robocop/logs/robocop_telegram.log | grep -i false | wc -l)
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

#function ficheros_conf {
#	
#	#Servidores CPU -> Cuando se cree un servidor a monitorizar la CPU se añade al fichero
#	
#}

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

function no_privilegios {
    echo 'robocop: Necesitas ser root para ejecutar estos comandos'
    echo "usa 'sudo robocop', 'sudo -s' o ejecuta robocop como root."
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
    source <(cat /etc/os-release | tr -d '.')

    # poner nombre de distribución, id y versión en variables
    DISTRO="${NAME}"
    DISTRO_ID="${DISTRO_ID}"
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

	# métricas de CPU
      	CORE_AMOUNT=$(ssh ${USER}@${SERVER} "grep -c 'cpu cores' /proc/cpuinfo")
     	MAX_LOAD_SERVER="${CORE_AMOUNT}.00"
      	COMPLETE_LOAD="$(< /proc/loadavg awk '{print $1" "$2" "$3}')"
       	CURRENT_LOAD="$(< /proc/loadavg awk '{print $3}')"
       	CURRENT_LOAD_PERCENTAGE="$(echo "(${CURRENT_LOAD}/${MAX_LOAD_SERVER})*100" | bc -l)"
       	CURRENT_LOAD_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_LOAD_PERCENTAGE}" | tr -d '%'))"
}

function reunir_metricas_threshold {
    # quitar '%' de umbrales en robocop.conf
    THRESHOLD_CPU_NUMBER="$(echo "${THRESHOLD_CPU}" | tr -d '%')"
    THRESHOLD_MEMORY_NUMBER="$(echo "${THRESHOLD_MEMORY}" | tr -d '%')"
    THRESHOLD_DISK_NUMBER="$(echo "${THRESHOLD_DISK}" | tr -d '%')"
}

function reunir_ping {
    if ping -q -c 1 -W 1 ${SERVER} >/dev/null; then
        echo "OK" > /home/ansible/robocop/monit/status_ping.log
    else
        echo "KO" > /home/ansible/robocop/monit/status_ping.log
    fi
}

function reunir_metricas_memoria {
    # métricas de memoria con la herramienta free
    FREE_VERSION="$(ssh ${USER}@${SERVER} free --version | awk '{ print $NF }' | tr -d '.')"

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
}

function reunir_metricas_disco {
    # métricas de FS
    TOTAL_DISK_SIZE="$(ssh ${USER}@${SERVER} df -h / --output=size -x tmpfs -x devtmpfs | sed -n '2 p' | tr -d ' ')"
    CURRENT_DISK_USAGE="$(ssh ${USER}@${SERVER} df -h / --output=used -x tmpfs -x devtmpfs | sed -n '2 p' | tr -d ' ')"
    CURRENT_DISK_PERCENTAGE="$(ssh ${USER}@${SERVER} df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')"
    TOTAL_FS_SIZE="$(ssh ${USER}@${SERVER} df -h ${FS} | awk '{print $2}' | tail -1)"
    CURRENT_FS_USAGE="$(ssh ${USER}@${SERVER} df -h ${FS} | awk '{print $3}' | tail -1)"
    CURRENT_FS_PERCENTAGE="$(ssh ${USER}@${SERVER} df -h ${FS} | awk '{print $5}' | tail -1 | cut -d '%' -f 1)" 
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
		echo "OK" > /home/ansible/robocop/monit/status_cpu.log
    	else
		echo "ESTADO CPU:	KO"
		echo "ALERTA!! REVISAD CUANTO ANTES"
		echo "KO" > /home/ansible/robocop/monit/status_cpu.log
    	fi

    # salir cuando esté hecho
    exit 0
}

function desc_ping {
    if ping -q -c 1 -W 1 ${SERVER} >/dev/null; then
        echo "OK - El servidor ${SERVER} responde con normalidad"
    else
	echo "KO - El servidor ${SERVER} está caído. Revisad lo antes posible!!"
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
            echo "OK" > /home/ansible/robocop/monit/status_mem.log
    else
            echo "ESTADO MEMORIA:       KO"
            echo "ALERTA!! REVISAD CUANTO ANTES"
            echo "KO" > /home/ansible/robocop/monit/status_mem.log
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
	echo "FS ${FS}:		${CURRENT_FS_USAGE} / ${TOTAL_FS_SIZE} (${CURRENT_FS_PERCENTAGE}%)"
        if [ "${CURRENT_FS_PERCENTAGE}" -lt "${THRESHOLD_DISK_NUMBER}" ]; then
		echo "ESTADO FS ${FS}: OK"
                echo "OK" > /home/ansible/robocop/monit/status_fs.log
        else
                echo "ESTADO FS ${FS}:       KO"
                echo "ALERTA!! REVISAD CUANTO ANTES"
                echo "KO" > /home/ansible/robocop/monit/status_fs.log
        fi

    # salir cuando esté hecho
    exit 0
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
    echo " Ejemplo: robocop --metrics --cpu"
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
            echo "[-] Eliminando a ROBOCOP de cronjob..."
            rm -f /etc/cron.d/robocop_*
            echo "[-] Eliminando robocop.conf del sistema..."
            rm -rf /etc/robocop
            echo "[-] Eliminando ROBOCOP del sistema..."
            rm -f /usr/bin/robocop
            echo "[i] Espero que ROBOCOP haya servidor con honores, ya se ha retirado a descansar a su pisito en Menorca..."
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

    echo '*** ACTUALIZACIÓN DE CRONJOBS ***'
   
    # actualizar tareas automatizadas de cronjobs
    
    echo "[?] ¿En qué servidor quieres configurar CRON? "
    read SERVER 
    echo "[?] ¿Quieres configurar la monitorización de CPU? (si/no)"
    read CRON_CPU
    echo "[?] ¿Quieres configurar el ping? (si/no)"
    read CRON_PING
    echo "[?] ¿Quieres configurar la monitorización de Memoria? (si/no)"
    read CRON_MEMORY	
    echo "[?] ¿Quieres configurar la monitorización de los FS? (si/no)"
    read CRON_FS

    if [ "${ROBOCOP_UPGRADE}" == 'yes' ]; then
        echo '[+] Actualización de cronjob para la actualización automática de robocop...'
        echo -e "# Este cronjob activa la actualización automática de robocop en el horario elegido\n${ROBOCOP_UPGRADE_CRON} root /usr/bin/robocop --silent-upgrade" > /etc/cron.d/robocop_upgrade
    fi
    if [ "${CRON_CPU}" == 'si' ]; then
	echo "[?] ¿Cada cuanto tiempo quieres ejecutarlo? (Default: * * * * *)"
        echo "[i] Por defecto se ejecuta cada minuto"
	echo -e "# Este cronjob activa la actualización automática de robocop en el horario elegido del servidor ${SERVER}\n${CRON_CPU_TIME} ansible /usr/bin/robocop --metrics --cpu --server ${SERVER} >> /tmp/prueba_cpu.txt" >> /etc/cron.d/robocop_cpu_${SERVER}

    fi
    if [ "${CRON_PING}" == 'si' ]; then
	echo "[?] ¿Cada cuanto tiempo quieres ejecutarlo? (Default: * * * * *)"
        echo "[i] Por defecto se ejecuta cada minuto"
        echo -e "# Este cronjob activa la actualización automática de robocop en el horario elegido del servidor ${SERVER}\n${CRON_PING_TIME} ansible /usr/bin/robocop --metrics --ping --server ${SERVER} >> /tmp/prueba_ping.txt" >> /etc/cron.d/robocop_ping_${SERVER}
    fi

    if [ "${CRON_MEMORY}" == 'si' ]; then
        echo "[?] ¿Cada cuanto tiempo quieres ejecutarlo? (Default: * * * * *)"
        echo "[i] Por defecto se ejecuta cada minuto"
        echo -e "# Este cronjob activa la actualización automática de robocop en el horario elegido del servidor ${SERVER}\n${CRON_MEMORY_TIME} ansible /usr/bin/robocop --metrics --memory --server ${SERVER} >> /tmp/prueba_memory.txt" >> /etc/cron.d/robocop_memory_${SERVER}
    fi

    if [ "${CRON_FS}" == 'si' ]; then
        echo "[?] ¿Cada cuanto tiempo quieres ejecutarlo? (Default: * * * * *)"
        echo "[i] Por defecto se ejecuta cada minuto"
	while [ ${CRON_FS} == "si" ]
	do	
		echo "[?] ¿Qué FS quieres configurar?"
		read FS
		echo -e "# Este cronjob activa la actualización automática de robocop en el horario elegido del servidor ${SERVER}\n${CRON_FS_TIME} ansible /usr/bin/robocop --metrics --fs ${FS} --server ${SERVER} >> /tmp/prueba_fs.txt" >> /etc/cron.d/robocop_fs_${SERVER}
		read -r -p '[?] ¿Quieres configurar otro FS? (si/no): ' CRON_FS
	done
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
    
    # proporcionar comentarios al usuario cuando todas las tareas automatizadas estén deshabilitadas
    if [ "${ROBOCOP_UPGRADE}" != 'yes' ] && \
    [ "${OVERVIEW_TELEGRAM}" != 'yes' ] && \
    [ "${METRICS_TELEGRAM}" != 'yes' ] && \
    [ "${ALERT_TELEGRAM}" != 'yes' ] && \
    [ "${UPDATES_TELEGRAM}" != 'yes' ] && \
    [ "${EOL_TELEGRAM}" != 'yes' ]; then
        echo '[i] Todas las tareas automatizadas están deshabilitadas, no hay cronjobs para actualizar...'
        exit 0
    fi

    # reinicie cron para efectuar realmente los nuevos cronjobs
    echo '[+] Reiniciando el servicio cron...'
    if [ "${SERVICE_MANAGER}" == "systemctl" ] && [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        systemctl restart crond.service
    elif [ "${SERVICE_MANAGER}" == "systemctl" ] && [ "${PACKAGE_MANAGER}" == "yum" ]; then
        systemctl restart crond.service
    elif [ "${SERVICE_MANAGER}" == "systemctl" ] && [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        systemctl restart cron.service
    elif [ "${SERVICE_MANAGER}" == "service" ] && [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        service cron restart
    #elif [ "${SERVICE_MANAGER}" == "rc-service" ] && [ "${PACKAGE_MANAGER}" == "apk" ]; then
    #    rc-service cron start # No estoy seguro si esto es correcto
    fi
    echo '[i] HECHO!'
    exit 0
}

#############################################################################
#                     REQUERIMIENTOS DE LAS FUNCIONES                       #
#############################################################################
function so_requerimientos {
    # compruebe si el administrador de paquetes compatible está instalado y complete las variables relevantes
    if [ "$(command -v dnf)" ]; then
        PACKAGE_MANAGER='dnf'
    elif [ "$(command -v yum)" ]; then
        PACKAGE_MANAGER='yum'
    elif [ "$(command -v apt-get)" ]; then
        PACKAGE_MANAGER='apt-get'
    elif [ "$(command -v pkg)" ]; then
        PACKAGE_MANAGER='pkg'
    #elif [ "$(command -v apk)" ]; then
        #PACKAGE_MANAGER='apk'
    else
        os_no_soportado
    fi

    # comprueba si el administrador de servicios compatible está instalado y complete las variables relevantes
    # systemctl
    if [ "$(command -v systemctl)" ]; then
        SERVICE_MANAGER='systemctl'
    # servicio
    elif [ "$(command -v service)" ]; then
        SERVICE_MANAGER='service'
    # openrc
    elif [ "$(command -v rc-service)" ]; then
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
    elif [ "${ARGUMENT_PING}" == '1' ] && [ "${ARGUMENT_METRICS}" == '1' ]; then
	desc_ping
    elif [ "${ARGUMENT_PING}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_caracteristicas_telegram
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
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
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_INFO}" == '1' ]; then
        desc_caracteristicas_info
    elif [ "${ARGUMENT_FS}" == '1' ] && [ "${ARGUMENT_METRICS}" == '1' ]; then
        desc_metricas_disk
    elif [ "${ARGUMENT_FS}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        desc_updates_cli
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_updates_telegram
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
    elif [ "${ARGUMENT_ROBOCOP}" == '1' ] && [ "${ARGUMENT_INFO}" == '1' ]; then
        envio_telegram
    elif [ "${ARGUMENT_EOL}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_eol_telegram
    elif [ "${ARGUMENT_EOL}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
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
