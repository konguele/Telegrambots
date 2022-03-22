#!/bin/bash

#############################################################################
#                       Version 1.0.0 (21/03/2022)                          #
#############################################################################

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

# comprobar si robocop.conf está disponible y añadir el source
if [ -f /etc/robocop/robocop.conf ]; then
    source /etc/robocop/robocop.conf
    # comprobar si se ha configurado el Telegram
    if [ "${TELEGRAM_TOKEN}" == 'poner_token' ]; then
        METHOD_ROBOCOP='disabled'
    fi
else
    # de lo contrario, deshabilite estas opciones, características y métodos
    ROBOCOP_CONFIG='disabled' # no funcionará sin robocop.conf
    METHOD_ROBOCOP='disabled' # no funcionará sin robocop.conf
    METHOD_EMAIL='disabled' # no funcionará sin robocop.conf

    # y utilice estos valores predeterminados para los parámetros del umbral de alerta
    THRESHOLD_CPU='90%'
    THRESHOLD_MEMORY='80%'
    THRESHOLD_DISK='80%' #añadir los diferentes FS

    # y por defecto a la rama estable
    ROBOCOP_BRANCH='unstable'
fi

#############################################################################
#                               ARGUMENTS                                   #
#############################################################################

# guardar la cantidad de argumentos para la verificación de validez
ARGUMENTS="${#}"

# rellenar las variables de validación con 0
ARGUMENT_OPTION='0'
ARGUMENT_FEATURE='0'
ARGUMENT_METHOD='0'

# habilitar la ayuda, la versión y una opción cli
while test -n "$1"; do
    case "$1" in
        # options
        --version|-version|version|--v|-v)
            ARGUMENT_VERSION='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --help|-help|help|--h|-h)
            ARGUMENT_HELP='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --cron)
            ARGUMENT_CRON='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --validate)
            ARGUMENT_VALIDATE='1'
            ARGUMENT_OPTIONS='1'
            shift
            ;;
        
        --knownusers)
            ARGUMENT_KNOWNUSER='1'
            ARGUMENT_OPTIONS='1'
            shift
            ;;

        --install)
            ARGUMENT_INSTALL='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --upgrade)
            ARGUMENT_UPGRADE='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --silent-upgrade)
            ARGUMENT_SILENT_UPGRADE='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --self-upgrade)
            ARGUMENT_SELF_UPGRADE='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --addserver)
            ARGUMENT_ADD_SERVER='1'
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

        --eol|eol)
            ARGUMENT_EOL='1'
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

        # otro
        *)
            ARGUMENT_NONE='1'
            shift
            ;;
    esac
done

#############################################################################
#                       FUNCIONES DE ERROR                                  #
#############################################################################

function opcion_no_valida {
    echo 'robocop: No es una opción válida. Prueba con otra'
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

#############################################################################
#                     REQUERIMIENTOS DE LAS FUNCIONES                       #
#############################################################################

function argumentos_validos {
    # las características requieren métodos y viceversa
    if [ "${ARGUMENT_FEATURE}" == '1' ] && [ "${ARGUMENT_METHOD}" == '0' ]; then
        no_metodo
    elif [ "${ARGUMENT_FEATURE}" == '0' ] && [ "${ARGUMENT_METHOD}" == '1' ]; then
        no_metodo
    # cantidad de argumentos menos de uno o más de dos dan como resultado un error
    elif [ "${ARGUMENTS}" -eq '0' ] || [ "${ARGUMENTS}" -gt '2' ]; then
        error_de_muchos_argumentos
    # las opciones son incompatibles con las características
    elif [ "${ARGUMENT_OPTION}" == '1' ] && [ "${ARGUMENT_FEATURE}" == '1' ]; then
        opciones_no_combinan
    # las opciones son incompatibles con los métodos
    elif [ "${ARGUMENT_OPTION}" == '1' ] && [ "${ARGUMENT_METHOD}" == '1' ]; then
        opciones_no_combinan
    elif [ "${ARGUMENT_ROBOCOP}" == '1' ] && [ "${METHOD_ROBOCOP}" == 'disabled' ]; then
        telegram_deshabilitado
    elif [ "${ARGUMENT_EMAIL}" == '1' ] && [ "${METHOD_EMAIL}" == 'disabled' ]; then
        email_deshabilitado
    fi
}

function root_requerido {
    # comprobar si el script se ejecuta como root
    if [ "$EUID" -ne 0 ]; then
        no_privilegios
    fi
}

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
#                       FUNCIONES DE GESTIÓN                                #
#############################################################################

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

function robocop_cron {
    # requisitos de función
    root_requerido
    robocop_validate

    # devuelve un error cuando el archivo de configuración no está instalado en el sistema
    if [ "${ROBOCOP_CONFIG}" == 'disabled' ]; then
        no_disponible
    fi

    echo '*** ACTUALIZACIÓN DE CRONJOBS ***'
    # elimina cronjobs para que las tareas automatizadas también se puedan desactivar
    echo '[-] Eliminando antiguos cronjobs de robocop...'
    rm -f /etc/cron.d/robocop_*
    # actualizar tareas automatizadas de cronjobs
    if [ "${ROBOCOP_UPGRADE}" == 'yes' ]; then
        echo '[+] Actualización de cronjob para la actualización automática de robocop...'
        echo -e "# Este cronjob activa la actualización automática de robocop en el horario elegido\n${ROBOCOP_UPGRADE_CRON} root /usr/bin/robocop --silent-upgrade" > /etc/cron.d/robocop_upgrade
    fi
    if [ "${OVERVIEW_TELEGRAM}" == 'yes' ]; then
        echo '[+] Actualización de cronjob para vistas generales automatizadas del servidor en Telegram...'
        echo -e "# Este cronjob activa la descripción general automatizada del servidor en Telegram en el horario elegido\n${OVERVIEW_CRON} root /usr/bin/robocop --overview --robocop" > /etc/cron.d/robocop_overview_telegram
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
    if [ "${EOL_TELEGRAM}" == 'yes' ]; then
        echo '[+] Actualización de cronjob para advertencias EOL automatizadas en Telegram...'
        echo -e "# Este cronjob activa advertencias EOL automatizadas en Telegram en el horario elegido\n${CLI_CRON} root /usr/bin/robocop --eol --robocop" > /etc/cron.d/robocop_eol_telegram
    fi
    #if [ "${EOL_EMAIL}" == 'yes' ]; then
    #    echo '[+] Actualización de cronjob para advertencias EOL automatizadas en el correo electrónico...'
    #    echo -e "# Este cronjob activa advertencias EOL automáticas en el correo electrónico en el horario elegido\n${CLI_CRON} root /usr/bin/robocop --eol --email" > /etc/cron.d/robocop_eol_email
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

function robocop_validate {
    # requisitos de función
    root_requerido

    # devuelve un error cuando el archivo de configuración no está instalado en el sistema
    if [ "${ROBOCOP_CONFIG}" == 'disabled' ]; then
        no_disponible
    fi

    echo '*** VALIDANDO ROBOCOP.CONF ***'
    # crear un archivo temporal para robocop.conf
    echo '[+] Creando un archivo temporal desde /etc/robocop/robocop.conf...'
    TMP_VALIDATE="$(mktemp)"
    # elimina todo el contenido que comienza con '#', elimina todos los espacios en blanco y lo agrega al archivo temporal
    cat /etc/robocop/robocop.conf | cut -f1 -d"#" | sed '/^[[:space:]]*$/d' | tr -d '%' > "${TMP_VALIDATE}"
    # Source del archivo temporal para que las variables puedan ser validadas
    source "${TMP_VALIDATE}"

    # validar el archivo de configuración (sin cron ni parámetros de configuración específicos del método)
    echo "[i] Nota: los parámetros de configuración de métodos y cron no se validarán..."
    echo '[i] Validando robocop.conf temporal...'
    VALIDATION_ERROR='0'
    if [ ! "${MAJOR_VERSION}" > '0' ]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable MAJOR_VERSION debe ser un número."
    fi
    if { [ "${ROBOCOP_UPGRADE}" != 'yes' ] && [ "${ROBOCOP_UPGRADE}" != 'no' ]; } && [ ! -z "${ROBOCOP_UPGRADE}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable ROBOCOP_UPGRADE debe ser 'yes' o 'no'."
    fi
    if { [ "${ROBOCOP_UPGRADE_TELEGRAM}" != 'yes' ] && [ "${ROBOCOP_UPGRADE_TELEGRAM}" != 'no' ]; } && [ ! -z "${ROBOCOP_UPGRADE_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable ROBOCOP_UPGRADE_TELEGRAM debe ser 'yes' o 'no'."
    fi
    if { [ "${OVERVIEW_TELEGRAM}" != 'yes' ] && [ "${OVERVIEW_TELEGRAM}" != 'no' ]; } && [ ! -z "${OVERVIEW_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable OVERVIEW_TELEGRAM debe ser 'yes' o 'no'."
    fi
    if { [ "${METRICS_TELEGRAM}" != 'yes' ] && [ "${METRICS_TELEGRAM}" != 'no' ]; } && [ ! -z "${METRICS_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable METRICS_TELEGRAM debe ser 'yes' o 'no'."
    fi
    if { [ "${ALERT_TELEGRAM}" != 'yes' ] && [ "${ALERT_TELEGRAM}" != 'no' ]; } && [ ! -z "${ALERT_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable ALERT_TELEGRAM debe ser 'yes' o 'no'."
    fi
    if { [ "${UPDATES_TELEGRAM}" != 'yes' ] && [ "${UPDATES_TELEGRAM}" != 'no' ]; } && [ ! -z "${UPDATES_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable UPDATES_TELEGRAM debe ser 'yes' o 'no'."
    fi
    if { [ "${EOL_TELEGRAM}" != 'yes' ] && [ "${EOL_TELEGRAM}" != 'no' ]; } && [ ! -z "${EOL_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] error de validación: la variable EOL TELEGRAM debe ser 'yes' o 'no'."
    fi
    if [[ "$(echo ${THRESHOLD_CPU} | tr -d '%')" -lt '0' ]] || [[ "$(echo ${THRESHOLD_CPU} | tr -d '%')" -gt '100' ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable THRESHOLD_CPU debe estar entre '0%' y '100%'."
    fi
    if [[ ! "$(echo ${THRESHOLD_CPU} | tr -d '%')" =~ ^[[:digit:]] ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable THRESHOLD_CPU solo debe contener números y '%'."
    fi
    if [[ "$(echo ${THRESHOLD_MEMORY} | tr -d '%')" -lt '0' ]] || [[ "$(echo ${THRESHOLD_MEMORY} | tr -d '%')" -gt '100' ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable THRESHOLD_MEMORY debe estar entre '0%' y '100%'."
    fi
    if [[ ! "$(echo ${THRESHOLD_MEMORY} | tr -d '%')" =~ ^[[:digit:]] ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable THRESHOLD_MEMORY solo debe contener números y '%'."
    fi
    if [[ "$(echo ${THRESHOLD_DISK} | tr -d '%')" -lt '0' ]] || [[ "$(echo ${THRESHOLD_DISK} | tr -d '%')" -gt '100' ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable THRESHOLD_DISK debe estar entre '0%' y '100%'."
    fi
    if [[ ! "$(echo ${THRESHOLD_DISK} | tr -d '%')" =~ ^[[:digit:]] ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Error de validación: la variable THRESHOLD_DISK solo debe contener números y '%'."
    fi

    # eliminar archivo temporal
    echo "[-] Eliminando archivo temporal..."
    rm -f "${TMP_VALIDATE}"

    # dar feedback al usuario si la validación fue exitosa o no
    if [ "${VALIDATION_ERROR}" == '1' ]; then
        echo "[!] Se han encontrado errores de validación. Corrígelos antes de volver a intentarlo...."
        exit 1
    else
        echo "[i] No se han encontrado errores de validación..."
    fi
}

function robocop_install_check {
    # comprobar si robocop.conf ya está instalado
    if [ -f /etc/robocop/robocop.conf ]; then
        # si es cierto, pregunte al usuario si se pretende una reinstalación
        while true
            do
                read -r -p '[?] ROBOCOP ya está instalado, ¿te gustaría reinstalarlo? (yes/no): ' REINSTALL
                [ "${REINSTALL}" = "yes" ] || [ "${REINSTALL}" = "no" ] && break
                error_si_o_no
            done

        # salir si no es intencionado
        if [ "${REINSTALL}" = "no" ]; then
            exit 0
        fi

        # reinstalando ROBOCOP
        if [ "${REINSTALL}" = "yes" ]; then
            echo "[!] ROBOCOP será reinstalado ahora..."
            robocop_install
        fi
    else
        # si robocop no está instalado actualmente, instálelo de inmediato
        robocop_install
    fi
}

function robocop_install {
    # requisitos de función
    root_requerido
    reunir_info_distro

    echo 
    echo '     //   ) )     //   ) )     //   ) )     //   ) )     //   ) )     //   ) )     //   ) ) '
    echo '    //___/ /     //   / /     //___/ /     //   / /     //           //   / /     //___/ /  '
    echo '   / ___ (      //   / /     / __  (      //   / /     //           //   / /     / ____ /   '
    echo '  //   | |     //   / /     //    ) )    //   / /     //           //   / /     //          '
    echo ' //    | |    ((___/ /     //____/ /    ((___/ /     ((____/ /    ((___/ /     //           '
    echo '                       Creado por Juanjo García Para Stilu Group                            ' 
    echo
    echo
    echo "[!] El barrio va a estar seguro, ROBOCOP ha llegado y se está instalando..."

    # Actualizar SO
    echo "[+] Instalando dependencias..."
    update_os

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

    # configuración opcional para el método de Telegram
    while true
        do
            read -r -p '[?] ¿Configuramos el método de Telegram? (yes/no): ' TELEGRAM_CONFIGURE
            [ "${TELEGRAM_CONFIGURE}" = "yes" ] || [ "${TELEGRAM_CONFIGURE}" = "no" ] && break
            error_si_o_no
        done

    if [ "${TELEGRAM_CONFIGURE}" == 'yes' ]; then
        read -r -p '[?] Añade el TOKEN del bot: ' TELEGRAM_TOKEN
        read -r -p '[?] Añade un CHAT ID (Después podrás añadir el resto):   ' TELEGRAM_CHAT_ID
    fi

    # añadir la carpeta robocop a /etc y agregar permisos
    echo "[+] agregando carpetas al sistema..."
    mkdir -m 755 /etc/robocop
    # instalar la última versión de robocop y agregar permisos
    echo "[+] instalando la última versión de ROBOCOP..."
    wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/${ROBOCOP_BRANCH}/robocop.sh -O /usr/bin/robocop
    chmod 755 /usr/bin/robocop
    # añadir el archivo de configuración de robocop a /etc/robocop y agregar permisos
    echo "[+] Agregando archivo de configuración al sistema..."
    wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/${ROBOCOP_BRANCH}/robocop.conf -O /etc/robocop/robocop.conf
    chmod 644 /etc/robocop/robocop.conf

    # usa la versión principal actual en /etc/robocop/robocop.conf
    echo "[+] agregando parámetros de configuración predeterminados al archivo de configuración..."
    sed -i s%'major_version_here'%"$(echo "${ROBOCOP_VERSION}" | cut -c1)"%g /etc/robocop/robocop.conf
    sed -i s%'branch_here'%"$(echo "${ROBOCOP_BRANCH}")"%g /etc/robocop/robocop.conf

    # agregando token de acceso de telegrama y el Chat ID
    if [ "${TELEGRAM_CONFIGURE}" == 'yes' ]; then
        echo "[+] Agregando TOKEN de acceso a Telegram y el Chat ID..."
        sed -i s%'poner_token'%"${TELEGRAM_TOKEN}"%g /etc/robocop/robocop.conf
        sed -i s%'telegram_id_here'%"${TELEGRAM_CHAT_ID}"%g /etc/robocop/robocop.conf
    fi

    # crear o actualizar cronjobs
    echo "[+] Creando cronjobs..."
    /bin/bash /usr/bin/robocop --cron
}

function compare_version {
    # información de la versión fuente de github y eliminar puntos
    source <(curl --silent https://raw.githubusercontent.com/konguele/Telegrambots/${ROBOCOP_BRANCH}/resources/version.txt)
    ROBOCOP_VERSION_CURRENT_NUMBER="$(echo "${ROBOCOP_VERSION}" | tr -d '.')"
    ROBOCOP_VERSION_RELEASE_NUMBER="$(echo "${VERSION_robocop}" | tr -d '.')"

    # comprobar si la versión de lanzamiento tiene un número de versión superior
    if [ "${ROBOCOP_VERSION_RELEASE_NUMBER}" -gt "${ROBOCOP_VERSION_CURRENT_NUMBER}" ]; then
        NEW_VERSION_AVAILABLE='1'
    fi
}

function robocop_upgrade {
    # requerimientos de la función
    root_requerido
    compare_version

    # instalar una nueva versión si está disponible
    if [ "${NEW_VERSION_AVAILABLE}" == '1' ]; then
        echo "[i] Nueva versión de robocop disponible, instalando ahora..."
        echo "[i] Crear archivo temporal para autoactualización..."
        TMP_INSTALL="$(mktemp)"
        echo "[i] Descarga la versión más reciente de robocop..."
        wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/${ROBOCOP_BRANCH}/robocop.sh -O "${TMP_INSTALL}"
        echo "[i] Establecer permisos en el script de instalación..."
        chmod 700 "${TMP_INSTALL}"
        echo "[i] Ejecutando script de instalación..."
        /bin/bash "${TMP_INSTALL}" --self-upgrade
    else
        echo "[i] No hay nueva versión de robocop disponible."
        exit 0
    fi
}

function robocop_silent_upgrade {
    # requerimientos de la función
    root_requerido
    compare_version

    if [ "${NEW_VERSION_AVAILABLE}" == '1' ]; then
        # crear un archivo temporal para la actualización automática
        TMP_INSTALL="$(mktemp)"
        # descargar la versión más reciente de robocop
        wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/${ROBOCOP_BRANCH}/robocop.sh -O "${TMP_INSTALL}"
        # establecer permisos en el script de instalación
        chmod 700 "${TMP_INSTALL}"
        # ejecutando el script de instalación
        /bin/bash "${TMP_INSTALL}" --self-upgrade
    else
        # salir cuando no hay actualizaciones disponibles
        exit 0
    fi
}

function robocop_self_upgrade {
    # requerimientos de la función
    root_requerido

    # descargar la versión más reciente y agregar permisos
    wget --quiet https://raw.githubusercontent.com/konguele/Telegrambots/${ROBOCOP_BRANCH}/robocop.sh -O /usr/bin/robocop
    chmod 755 /usr/bin/robocop
    echo "[i] robocop actualizado a la versión ${ROBOCOP_VERSION}..."

    # avisar por telegram
    if [ "${ROBOCOP_UPGRADE_TELEGRAM}" == 'yes' ]; then
        # crear mensaje para Telegram
        TELEGRAM_MESSAGE="$(echo -e "<b>Actualización</b>: <code>${HOSTNAME}</code>\\nROBOCOP, el policía más seguro del barrio ha sido actualizado a la versión ${ROBOCOP_VERSION}.")"

        # llamada a METHOD_ROBOCOP
        METHOD_ROBOCOP
    fi

    # salir cuando esté hecho
    exit 0
}

function robocop_uninstall {
    # requerimientos de la función
    root_requerido

    # preguntar si se pretendía desinstalar
    while true
        do
            read -r -p '[?] ¿Estás seguro que quieres eliminar al mejor policía de todos los tiempos? (yes/no): ' UNINSTALL
            [ "${UNINSTALL}" = "yes" ] || [ "${UNINSTALL}" = "no" ] && break
            error_si_o_no
       done

        # salir si no se pretendía
        if [ "${UNINSTALL}" = "no" ]; then
            exit 0
        fi

        # uninstall when intended
        if [ "${UNINSTALL}" = "yes" ]; then
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

#############################################################################
#                           FUNCIONES GENERALES                             #
#############################################################################

function update_os {
    # requerimientos de la función
    root_requerido

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

#############################################################################
#                       FUNCIONES DE RECOLECCIÓN                            #
#############################################################################

function reunir_info_distro {
    # obtener información del sistema operativo de os-release
    source <(cat /etc/os-release | tr -d '.')

    # poner nombre de distribución, id y versión en variables
    DISTRO="${NAME}"
    DISTRO_ID="${ID}"
    DISTRO_VERSION="${VERSION_ID}"
}

function reunir_info_servidor {
    # información del servidor
    HOSTNAME="$(uname -n)"
    OPERATING_SYSTEM="$(uname -o)"
    KERNEL_NAME="$(uname -s)"
    KERNEL_VERSION="$(uname -r)"
    ARCHITECTURE="$(uname -m)"
    UPTIME="$(uptime -p)"
}

function reunir_info_red {
    # información de la IP interna
    INTERNAL_IP_ADDRESS="$(hostname -I)"

    # información de la IP externa
    EXTERNAL_IP_ADDRESS="$(curl --silent ipecho.net/plain)"
}

function reunir_metricas_cpu {
    # requerimientos de la función
    root_requerido

    # métricas de CPU
    CORE_AMOUNT="$(grep -c 'cpu cores' /proc/cpuinfo)"
    MAX_LOAD_SERVER="${CORE_AMOUNT}.00"
    COMPLETE_LOAD="$(< /proc/loadavg awk '{print $1" "$2" "$3}')"
    CURRENT_LOAD="$(< /proc/loadavg awk '{print $3}')"
    CURRENT_LOAD_PERCENTAGE="$(echo "(${CURRENT_LOAD}/${MAX_LOAD_SERVER})*100" | bc -l)"
    CURRENT_LOAD_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_LOAD_PERCENTAGE}" | tr -d '%'))"
}

function reunir_metricas_memoria {
    # métricas de memoria con la herramienta free
    FREE_VERSION="$(free --version | awk '{ print $NF }' | tr -d '.')"

    # usa el formato antiguo cuando se use la versión antigua de free
    if [ "${FREE_VERSION}" -le "339" ]; then
        TOTAL_MEMORY="$(free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_MEMORY="$(free -m | awk '/^Mem/ {print $6}')"
        CACHED_MEMORY="$(free -m | awk '/^Mem/ {print $7}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_MEMORY}-${CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    # usa un formato más nuevo cuando se use una versión más nueva de gratis
    elif [ "${FREE_VERSION}" -gt "339" ]; then
        TOTAL_MEMORY="$(free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_CACHED_MEMORY="$(free -m | awk '/^Mem/ {print $6}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    fi
}

function reunir_metricas_disco {
    # métricas de FS
    TOTAL_DISK_SIZE="$(df -h / --output=size -x tmpfs -x devtmpfs | sed -n '2 p' | tr -d ' ')"
    CURRENT_DISK_USAGE="$(df -h / --output=used -x tmpfs -x devtmpfs | sed -n '2 p' | tr -d ' ')"
    CURRENT_DISK_PERCENTAGE="$(df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')"
}

function reunir_metricas_threshold {
    # quitar '%' de umbrales en robocop.conf
    THRESHOLD_CPU_NUMBER="$(echo "${THRESHOLD_CPU}" | tr -d '%')"
    THRESHOLD_MEMORY_NUMBER="$(echo "${THRESHOLD_MEMORY}" | tr -d '%')"
    THRESHOLD_DISK_NUMBER="$(echo "${THRESHOLD_DISK}" | tr -d '%')"
}

function reunir_updates {
    # requerimientos de la función
    root_requerido

    # recopilar actualizaciones sobre distribuciones modernas basadas en rhel
    if [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        # lista con actualizaciones disponibles para la variable UPDATES_DISPONIBLES
        UPDATES_DISPONIBLES="$(dnf check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Last\>//g')"
        # genera la longitud del carácter de UPDATES_DISPONIBLES en LENGTH_UPDATES
        LENGTH_UPDATES="${#UPDATES_DISPONIBLES}"
    # recopilar actualizaciones sobre distribuciones antiguas basadas en rhel
    elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
        # lista con actualizaciones disponibles para la variable UPDATES_DISPONIBLES
        UPDATES_DISPONIBLES="$(yum check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Loading\>//g')"
        # genera la longitud del carácter de UPDATES_DISPONIBLES en LENGTH_UPDATES
        LENGTH_UPDATES="${#UPDATES_DISPONIBLES}"
    # recopilar actualizaciones sobre distribuciones basadas en debian
    elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        # actualizar repositorio
        apt-get --quiet update
        # lista con actualizaciones disponibles para la variable UPDATES_DISPONIBLES
        UPDATES_DISPONIBLES="$(aptitude -F "%p" search '~U')"
        # genera la longitud del carácter de UPDATES_DISPONIBLES en LENGTH_UPDATES
        LENGTH_UPDATES="${#UPDATES_DISPONIBLES}"
    fi
}

function reunir_eol {
    # requerimientos de la función
    reunir_info_distro

    # modificar la información básica de distribución a mayúsculas
    EOL_OS="$(echo ${DISTRO_ID}${DISTRO_VERSION} | tr '[:lower:]' '[:upper:]')"
    EOL_OS_NAME="EOL_${EOL_OS}"

    # base de datos de origen con datos de eol
    source <(curl --silent https://raw.githubusercontent.com/konguele/Telegrambots/${ROBOCOP_BRANCH}/resources/eol.list | tr -d '.')

    # calcular la diferencia de fecha entre la fecha actual y la fecha final de vida
    EPOCH_EOL="$(date --date=$(echo "${!EOL_OS_NAME}") +%s)"
    EPOCH_CURRENT="$(date +%s)"
    EPOCH_DIFFERENCE="$(( ${EPOCH_EOL} - ${EPOCH_CURRENT} ))"
}

#############################################################################
#                      FUNCIONES DE CARACTERISTICAS                         #
#############################################################################

function desc_caracteristicas_cli {
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

function desc_caracteristicas_telegram {
    # requerimientos de la función
    reunir_info_servidor
    reunir_info_red
    reunir_info_distro
    reunir_metricas_cpu
    reunir_metricas_memoria
    reunir_metricas_disco    

    # crear mensaje para Telegram
    TELEGRAM_MESSAGE="$(echo -e "<b>Host</b>:                  <code>${HOSTNAME}</code>\\n<b>OS</b>:                      <code>${OPERATING_SYSTEM}</code>\\n<b>Distro</b>:               <code>${DISTRO} ${DISTRO_VERSION}</code>\\n<b>Kernel</b>:              <code>${KERNEL_NAME} ${KERNEL_VERSION}</code>\\n<b>Architecture</b>:  <code>${ARCHITECTURE}</code>\\n<b>Uptime</b>:             <code>${UPTIME}</code>\\n\\n<b>Internal IP</b>:\\n<code>${INTERNAL_IP_ADDRESS}</code>\\n\\n<b>External IP</b>:\\n<code>${EXTERNAL_IP_ADDRESS}</code>\\n\\n<b>Load</b>:                  <code>${COMPLETE_LOAD}</code>\\n<b>Memory</b>:           <code>${USED_MEMORY} M / ${TOTAL_MEMORY} M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)</code>\\n<b>Disk</b>:                   <code>${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)</code>")"

    # llamada al METHOD_ROBOCOP
    METHOD_ROBOCOP

    # salir cuando esté hecho
    exit 0
}

function desc_metricas_cli {
    # requerimientos de la función
    reunir_info_servidor
    reunir_metricas_cpu
    reunir_metricas_memoria
    reunir_metricas_disco

    # salida por línea de comandos
    echo "HOST:             ${HOSTNAME}"
    echo "TIEMPO ACTIVO:    ${UPTIME}"
    echo "CPU:              ${COMPLETE_LOAD}"
    echo "MEMORIA:          ${USED_MEMORY}M / ${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)"
    echo "DISCO:            ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)"

    # salir cuando esté hecho
    exit 0
}

function desc_metricas_telegram {
    # requerimientos de la función
    reunir_info_servidor
    reunir_metricas_cpu
    reunir_metricas_memoria
    reunir_metricas_disco

    # crear mensaje para Telegram
    TELEGRAM_MESSAGE="$(echo -e "<b>Host</b>:        <code>${HOSTNAME}</code>\\n<b>Tiempo activo</b>:  <code>${UPTIME}</code>\\n\\n<b>CPU</b>:         <code>${COMPLETE_LOAD}</code>\\n<b>Memoria</b>:  <code>${USED_MEMORY} M / ${TOTAL_MEMORY} M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)</code>\\n<b>Disco</b>:          <code>${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)</code>")"

    # llamada al METHOD_ROBOCOP
    METHOD_ROBOCOP

    # salir cuando esté hecho
    exit 0
}

function desc_alerta_cli {
    # requerimiento de la función
    reunir_info_servidor
    reunir_metricas_cpu
    reunir_metricas_memoria
    reunir_metricas_disco
    reunir_metricas_threshold

    # comprueba si la carga del servidor actual excede el umbral y avisa si es verdadero. Salida del estado de alerta del servidor al shell.
    if [ "${CURRENT_LOAD_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_CPU_NUMBER}" ]; then
        echo -e "[!] CPU DEL SERVIDOR:\\tLa carga actual del servidor es ${CURRENT_LOAD_PERCENTAGE_ROUNDED}% y excede el límite de ${THRESHOLD_CPU}."
    else
        echo -e "[i] CPU DEL SERVIDOR:\\tLa carga actual del servidor es ${CURRENT_LOAD_PERCENTAGE_ROUNDED}% y NO excede el límite de ${THRESHOLD_CPU}."
    fi

    if [ "${CURRENT_MEMORY_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_MEMORY_NUMBER}" ]; then
        echo -e "[!] MEMORIA DEL SERVIDOR:\\tEl uso de memoria actual es de ${CURRENT_MEMORY_PERCENTAGE_ROUNDED}% y excede el límite de ${THRESHOLD_MEMORY}."
    else
        echo -e "[i] MEMORIA DEL SERVIDOR:\\tEl uso de memoria actual es de ${CURRENT_MEMORY_PERCENTAGE_ROUNDED}% y NO excede el límite de ${THRESHOLD_MEMORY}."
    fi

    if [ "${CURRENT_DISK_PERCENTAGE}" -ge "${THRESHOLD_DISK_NUMBER}" ]; then
        echo -e "[!] USO DEL DISCO:\\t\\tEl uso actual del disco es de ${CURRENT_DISK_PERCENTAGE}% y excede el límite de ${THRESHOLD_DISK}."
    else
        echo -e "[i] USO DEL DISCO:\\t\\tEl uso actual del disco es de ${CURRENT_DISK_PERCENTAGE}% y NO excede el límite de ${THRESHOLD_DISK}."
    fi

    # salir cuando acabe
    exit 0
}

function desc_alerta_telegram {
    # requerimientos de la función
    reunir_info_servidor
    reunir_metricas_cpu
    reunir_metricas_memoria
    reunir_metricas_disco
    reunir_metricas_threshold

    # comprobar si la carga del servidor actual supera el umbral y alertar si es cierto
    if [ "${CURRENT_LOAD_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_CPU_NUMBER}" ]; then
        # crear mensaje para Telegram
        TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>ALERTA: CPU</b>\\n\\nLa CPU del servidor es (<code>${CURRENT_LOAD_PERCENTAGE_ROUNDED}%</code>) en <b>${HOSTNAME}</b> ey excede el límite de <code>${THRESHOLD_CPU}</code>\\n\\n<b>CPU total:</b>\\n<code>${COMPLETE_LOAD}</code>")"

        # llamada al METHOD_ROBOCOP
        METHOD_ROBOCOP
    fi

    # comprobar si el uso actual de la memoria del servidor supera el umbral y alertar si es verdadero
    if [ "${CURRENT_MEMORY_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_MEMORY_NUMBER}" ]; then
        # crear mensaje para Telegram
        TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>ALERTA: MEMORIA</b>\\n\\nEl uso de memoria es (<code>${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%</code>) en <b>${HOSTNAME}</b> y excede el límite de <code>${THRESHOLD_MEMORY}</code>\\n\\n<b>Uso de memoria:</b>\\n<code>$(free -m -h)</code>")"

        # llamada al METHOD_ROBOCOP
        METHOD_ROBOCOP
    fi

    # comprobar si el uso actual del disco supera el umbral y alertar si es verdadero
    if [ "${CURRENT_DISK_PERCENTAGE}" -ge "${THRESHOLD_DISK_NUMBER}" ]; then
        # crear mensaje para Telegram
        TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>ALERTA: FILE SYSTEM</b>\\n\\nEl uso del disco es (<code>${CURRENT_DISK_PERCENTAGE}%</code>) en <b>${HOSTNAME}</b> y excede el límite de <code>${THRESHOLD_DISK}</code>\\n\\n<b>Información de FS:</b>\\n<code>$(df -h)</code>")"

        # llamada al METHOD_ROBOCOP
        METHOD_ROBOCOP
    fi

    # salir cuando esté hecho
    exit 0
}

function desc_updates_cli {
    # requerimientos de la función
    reunir_updates

    # Notificar al usuario cuando no hay actualizaciones
    if [ -z "${UPDATES_DISPONIBLES}" ]; then
        echo "No hay actualizaciones disponibles."
    else
        # notify user when there are updates available
        echo "Las siguientes actualizaciones están disponibles:"
        echo
        echo "${UPDATES_DISPONIBLES}"
    fi

    # salir cuando esté hecho
    exit 0
}

function desc_updates_telegram {
    # requerimientos de la función
    reunir_info_servidor
    reunir_updates

    # no hacer nada si no hay actualizaciones
    if [ -z "${UPDATES_DISPONIBLES}" ]; then
        exit 0
    else
        # si la longitud de la lista de actualización es inferior a 4000 caracteres, se envía la lista de actualización
        if [ "${LENGTH_UPDATES}" -lt "4000" ]; then
            TELEGRAM_MESSAGE="$(echo -e "Hay actualizaciones disponibles en <b>${HOSTNAME}</b>:\n\n${UPDATES_DISPONIBLES}")"
        fi

        # si la longitud de la lista de actualización es superior a 4000 caracteres, no envíe la lista de actualización
        if [ "${LENGTH_UPDATES}" -gt "4000" ]; then
            TELEGRAM_MESSAGE="Hay actualizaciones disponibles en <b>${HOSTNAME}</b>. Desafortunadamente, la lista con actualizaciones es demasiado grande para Telegram. ROBOCOP es letal, pero no puede escribir tanto, actualice lo antes posible."
        fi

        # llamada al METHOD_ROBOCOP
        METHOD_ROBOCOP
    fi

    # salir cuando esté hecho
    exit 0
}

function desc_eol_cli {
    # requerimientos de la función
    reunir_eol

    # primero verifica las entradas TBA, luego verifica si la diferencia de fecha es positiva o negativa
    if [ "${!EOL_OS_NAME}" == 'TBA' ]; then
        echo '[i] La fecha EOL de este sistema operativo aún no se ha agregado a la base de datos. Vuelva a intentarlo más tarde.'
    else
        if [[ "${EPOCH_DIFFERENCE}" -lt '0' ]]; then
            echo "[!] Este sistema operativo está al final de su vida útil desde ${!EOL_OS_NAME}."
        elif [[ "${EPOCH_DIFFERENCE}" -gt '0' ]]; then
            echo "[i] Este sistema operativo es compatible $(( ${EPOCH_DIFFERENCE} / 86400 )) más días (hasta ${!EOL_OS_NAME})."
        fi
    fi
}

function desc_eol_telegram {
    # requerimientos de la función
    reunir_info_servidor
    reunir_eol

    # no hacer nada si la fecha de fin de vida no está en la base de datos
    if [ "${!EOL_OS_NAME}" == 'TBA' ]; then
        exit 0
    else
        # dar aviso de fin de vida alrededor de 6, 3 y 1 mes antes de fin de ciclo, y con más frecuencia si es menos de 1 mes (depende del parámetro EOL_CRON)
        if [[ "${EPOCH_DIFFERENCE}" -lt '0' ]]; then
            TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>EOL AVISO: ${HOSTNAME}</b>\\nEste sistema operativo está al final de su vida útil desde ${!EOL_OS_NAME}.")"
        elif [[ "${EPOCH_DIFFERENCE}" -ge '14802000' ]] && [[ "${EPOCH_DIFFERENCE}" -lt '15552000' ]]; then
            TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>EOL AVISO: ${HOSTNAME}</b>\\nEste sistema operativo llegará al final de su vida útil en $(( ${EPOCH_DIFFERENCE} / 86400 )) días (en ${!EOL_OS_NAME}).")"
        elif [[ "${EPOCH_DIFFERENCE}" -ge '7026000' ]] && [[ "${EPOCH_DIFFERENCE}" -lt '7776000' ]]; then
            TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>EOL AVISO: ${HOSTNAME}</b>\\nEste sistema operativo llegará al final de su vida útil en $(( ${EPOCH_DIFFERENCE} / 86400 )) días (en ${!EOL_OS_NAME}).")"
        elif [[ "${EPOCH_DIFFERENCE}" -ge '1' ]] && [[ "${EPOCH_DIFFERENCE}" -lt '5184000' ]]; then
            TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>EOL AVISO: ${HOSTNAME}</b>\\nEste sistema operativo llegará al final de su vida útil en $(( ${EPOCH_DIFFERENCE} / 86400 )) días (en ${!EOL_OS_NAME}).")"
        fi
    fi

    # llamada al METHOD_ROBOCOP
    METHOD_ROBOCOP

    # salir cuando esté hecho
    exit 0
}

function desc_outage {
    # devuelve un error cuando la interrupción de la función no está disponible
    if [ "${DESC_OUTAGE}" == 'disabled' ]; then
        no_disponible
    fi
}

#############################################################################
#                           FUNCIONES DEL MÉTODO                            #
#############################################################################

function METHOD_ROBOCOP {
    # devolver un error cuando Telegram no está disponible
    if [ "${METHOD_ROBOCOP}" == 'disabled' ]; then
        no_disponible
    fi

    # crear payload para Telegram
    TELEGRAM_PAYLOAD="chat_id=${TELEGRAM_CHAT}&text=${TELEGRAM_MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

    # enviar payload a la API de Telegram y salir
    curl --silent --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${TELEGRAM_PAYLOAD}" "${TELEGRAM_URL}" > /dev/null 2>&1 &
}

function method_email {
    # devolver un error cuando el correo electrónico no está disponible
    if [ "${METHOD_EMAIL}" == 'disabled' ]; then
        no_disponible
    fi

    # planificado para la siguiente versión
    no_implementado
}

#############################################################################
#                           FUNCIÓN PRINCIPAL                               #
#############################################################################

function robocop_main {
    # revisa si el SO está soportado
    so_requerimientos

    # revisa si los argumentos son válidos
    argumentos_validos

    # llamada a funciones relevantes basadas en argumentos
    if [ "${ARGUMENT_VERSION}" == '1' ]; then
        ROBOCOP_VERSION
    elif [ "${ARGUMENT_HELP}" == '1' ]; then
        robocop_help
    elif [ "${ARGUMENT_CRON}" == '1' ]; then
        robocop_cron
    elif [ "${ARGUMENT_VALIDATE}" == '1' ]; then
        robocop_validate
    elif [ "${ARGUMENT_INSTALL}" == '1' ]; then
        robocop_install_check
    elif [ "${ARGUMENT_UPGRADE}" == '1' ]; then
        robocop_upgrade
    elif [ "${ARGUMENT_SILENT_UPGRADE}" == '1' ]; then
        robocop_silent_upgrade
    elif [ "${ARGUMENT_SELF_UPGRADE}" == '1' ]; then
        robocop_self_upgrade
    elif [ "${ARGUMENT_UNINSTALL}" == '1' ]; then
        robocop_uninstall
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        desc_caracteristicas_cli
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_caracteristicas_telegram
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        desc_metricas_cli
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_metricas_telegram
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
    elif [ "${ARGUMENT_ALERT}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        desc_alerta_cli
    elif [ "${ARGUMENT_ALERT}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_alerta_telegram
    elif [ "${ARGUMENT_ALERT}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        desc_updates_cli
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_updates_telegram
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
    elif [ "${ARGUMENT_EOL}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        desc_eol_cli
    elif [ "${ARGUMENT_EOL}" == '1' ] && [ "${ARGUMENT_ROBOCOP}" == '1' ]; then
        desc_eol_telegram
    elif [ "${ARGUMENT_EOL}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        no_implementado
    elif [ "${ARGUMENT_NONE}" == '1' ]; then
        opcion_no_valida
    fi
}

#############################################################################
#                   LLAMADA A LA FUNCIÓN PRINCIPAL                          #
#############################################################################

robocop_main
