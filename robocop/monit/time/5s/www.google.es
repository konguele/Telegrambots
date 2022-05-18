# Este cronjob activa la actualización automática de la URL en robocop en el horario elegido del sitio web https://www.google.es
/usr/bin/robocop --metrics --url https://www.google.es > /dev/null
