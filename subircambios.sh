#!/usr/bin/bash
# Author: Juanjo García
# Github: https://github.com/konguele
# Description: Simple script que sube los cambios de git a mi repositorio github

echo "Bienvenido a la subida de cambios de github, vamos a empezar"

while [ "$var1" != "si" ]
do 
	echo "¿Qué comentario añadiremos al commit?: "
	read var2
	echo "Perfecto! El comentario elegido es: " $var2
	echo "¿Es correcto? (si/no)"
        read var1
done
echo "Ejecutamos Git init para reinicializar el repositorio"
git init
echo "Ha funcionado correctamente"
echo "Ejecutamos git add para añadir los nuevos cambios"
git add .
echo "Añadimos el comentario al commit "$var2
git commit -m $var2
echo "Por último, hacemos el push al servidor git"
git push origin master
echo "Los ficheros se han subido correctamente"
