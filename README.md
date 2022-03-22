# Robocop
Robocop es una herramienta de monitorización de servidor, pensada para usar bots en Telegram, por línea de comandos y en el futuro, se intentará implementar una versión web. Se puede ampliar todo lo necesario, implementar nuevas funciones y lo más importante, cualquiera puede hacerlo. Se busca crear una herramienta sencilla, con todas las posibilidades imaginables y capaz de hacer todo aquello que el usuario necesite.

Por el momento están disponibles las siguientes caracteristicas
    - Visión general: Podemos ver una salida general de las principales caracteristicas del servidor.
    - Métricas: Muestra métricas del servidor como tiempo de actividad, CPU, ram y disco. Se está trabajando en mostrar todos los FS, consultas de DB y consultas web.
    - Alertas: Por el momento tenemos alertas de espacio de disco, de CPU y de memoria, con límites configurables.
    - Actualizaciones: Muestra las actualizaciones disponibles (Si las hay)
    - EOL: Muestra cuánto tiempo de vida útil tiene.

Además de las funciones, también existen diferentes métodos que se pueden usar con las funciones:
    - CLI: Para interactuar con la línea de Comandos
    - Telegrambot: Para enviar información al bot de Telegram

# Próximas actualizaciones
Para el futuro más inmediato se están creando las siguientes caracteristicas:
    - Interactuar desde Telegram con ROBOCOP (reiniciar servidor, levantar o parar servicios, comprobar alertas...)
    - Añadir los Chat ID desde donde se puede interactuar con Telegram (Si no estás en la lista, no puedes enviar    comandos al servidor [políticas de seguridad])
    - Añadir al instalador los pasos para crear el script que interactúa con Telegram
    - Cambiar ubicación de logs (Todos están en la salida standard)
    - Añadir los servidores que requieran monitorización (Crear una DB o un fichero con los servidores)
    - Poder elegir las distintas monitorizaciones para los servidores (Crear variables adaptadas a cada caso)
    - Añadir la monitorización de la DB (revisar el listener, ejecutar alguna query de comprobación...)
    - Añadir la monitorización de Apache (Revisar si está levantado)
    - Añadir la monitorización de la web levantada (Revisar con un wget si responde la url)
    - Avisar cuando se arranca un servidor

# Instalar robocop
Para instalar ROBOCOP, descarga [`robocop.sh`](https://raw.githubusercontent.com/konguele/Telegrambots/stable/robocop.sh) a tu dispositivo linux y ejecuta el comando `bash robocop.sh --install`  para instalar, también puedes usar el comando `./bash robocop.sh --install` .

Puedes descargarlo desde Windows o Linux por entorno gráfico desde la web, puedes copiar y pegar el texto del fichero o puedes descargarlo por línea de comando:

wget https://raw.githubusercontent.com/konguele/Telegrambots/stable/robocop.sh
curl -O https://raw.githubusercontent.com/konguele/Telegrambots/stable/robocop.sh


# Uso de ROBOCOP
Después de instalar robocop puedes ejecutar `robocop` como un comando normal. Por ejemplo `robocop --metrics --cli`. Los parámetros como las tareas automatizadas y los umbrales se pueden configurar desde un archivo de configuración central en `/etc/robocop/robocop.conf`.

`robocop --help` te enseña los comandos y próximamente varias opciones para ejecutar directamente:

Para obtener información sobre cómo adquirir un bot de Telegram, consulte https://core.telegram.org/bots.

Si quieréis aportar cualquier idea, siempre será bienvenida! 