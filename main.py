# -*- coding: utf-8 -*-

import telebot
from telebot import types
import time
import os
import sys
from datetime import datetime
from sys import exit
import subprocess


TOKEN = 'poner_token'  # token brindado por BotFather

LOG_DIR = "poner_log" # directorio para log
USERS_DIR = "poner_userdir" # directorio para usuarios

knownUsers = []  # registro temporal de usuarios

commands = {  
    'start': 'Empezar a mensajear con el bot',
    'ayuda': 'Da informacion sobre los comandos disponibles',
    'cpu': 'Muestra el estado de la CPU del servidor elegido',
    'ram': 'Muestra el estado de la memoria del servidor elegido',
    'fs': 'Muestra el estado del FS en el servidor elegido',
    'reboot': 'Reinicia el servidor elegido',
    'service': 'Muestra el estado del SERVICIO en el servidor elegido',
    'stop_proc': 'Para el servicio en el servidor elegido',
    'kill_proc': 'Mata el proceso en el servidor elegido',
    'start_proc': 'Arranca el servicio en el servidor elegido',
    'updates': 'Muestra si hay actualizaciones en el servidor',
    'install_updates': 'Instala las actualizaciones pendientes',
    'maintenance': 'Pone en mantenimiento el servidor elegido durante un tiempo determinado',
    'stop': 'Para el mensajeo con el bot'
    'examples: '
    '	/cpu server_name'
    '	/ram server_name'
    '	/fs server_name file_system'
    '	/reboot server_name'
    '	/service server_name service_name proc_name'
    '	/updates server_name'
    '	/updates server_name'
    '	/install_updates server_name'
    '	/maintenance server_name time'
    '	/stop_proc server_name proc'
    '	/kill_proc server_name proc'
    '	/start_proc server_name proc' 
}

markup = types.ReplyKeyboardMarkup()
markup.row('/start', '/ayuda', '/stop')

def listener(messages):
    for m in messages:
        if m.content_type == 'text':
            fecha = datetime.fromtimestamp(m.json['date'])
            f = open(LOG_DIR, "a+")
            f.write(str(m.chat.first_name) + " [" + str(m.chat.id) + "]" + "[" + str(fecha) + "] : " + m.text + "\n")
            f.close()


bot = telebot.TeleBot(TOKEN)
bot.set_update_listener(listener)  # actualizar el listener del bot con el que acabamos de desarrollar


@bot.message_handler(commands=['start'])
def command_start(m):
    cid = m.chat.id
    f = open(USERS_DIR, "r")
    content = f.readlines()
    for c in content:
        knownUsers.append(c.split(';')[1].split('\n')[0])
    if str(cid) not in knownUsers:
        knownUsers.append(cid)
        f = open(USERS_DIR, "a+")
        f.write(str(m.chat.first_name) + ";" + str(m.chat.id) + "\n")
        f.close()
        bot.send_message(cid, "¡Bienvenido!", reply_markup=markup)
        command_help(m) 
    else:
        bot.send_message(cid,
                         "Ya habías empezado a hablar conmigo anteriormente. Busca el símbolo de comandos y revisa los comandos disponibles.",
                         reply_markup=markup)


# help page
@bot.message_handler(commands=['ayuda'])
def command_help(m):
    cid = m.chat.id
    help_text = "Comandos disponibles: \n"
    for key in commands:
        help_text += "/" + key + ": "
        help_text += commands[key] + "\n"
    bot.send_message(cid, help_text, reply_markup=markup)

# Revisa el estado de CPU de un servidor
@bot.message_handler(commands=['cpu'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/cpu"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún servidor. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    com = ("/usr/bin/robocop --robocop --cpu --server " + m.text[len("/cpu"):])
    bot.send_message(cid, "Recogiendo información de CPU del servidor " + m.text[len("/cpu"):])
    bot.send_chat_action(cid, 'typing')
    time.sleep(3)
    os.system(com)

# Revisa el estado de RAM de un servidor
@bot.message_handler(commands=['ram'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/ram"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún servidor. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    com = ("/usr/bin/robocop --robocop --memory --server " + m.text[len("/ram"):])
    bot.send_message(cid, "Recogiendo información de Memoria del servidor " + m.text[len("/ram"):])
    bot.send_chat_action(cid, 'typing')
    time.sleep(3)
    os.system(com)


# Revisa el estado de Updates de un servidor
@bot.message_handler(commands=['updates'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/updates"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún servidor. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    com = ("/usr/bin/robocop --robocop --update --server " + m.text[len("/updates"):])
    bot.send_message(cid, "Recogiendo información de actualizaciones pendientes del servidor " + m.text[len("/updates"):])
    bot.send_chat_action(cid, 'typing')
    os.system(com)

# Revisa el estado de Updates de un servidor
@bot.message_handler(commands=['install_updates'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/install_updates"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún servidor. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    com = ("/usr/bin/robocop --robocop --install_updates --server " + m.text[len("/install_updates"):])
    bot.send_message(cid, "Empieza la instalación de las últimas actualizaciones del servidor o grupo de servidores " + m.text[len("/install_updates"):])
    bot.send_message(cid, "Recibirás un mensaje al finalizar la instalación. Funciono bien, ten paciencia si tardo un poco :)")
    bot.send_chat_action(cid, 'typing')
    time.sleep(3)
    os.system(com)

# Reinicia servidor
@bot.message_handler(commands=['reboot'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/reboot"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún servidor. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    com = ("/usr/bin/robocop --robocop --reboot --server " + m.text[len("/reboot"):])
    bot.send_message(cid, "Reiniciando servidor " + m.text[len("/reboot"):] + "...")
    bot.send_chat_action(cid, 'typing')
    time.sleep(3)
    os.system(com)

# Pone en modo mantenimiento un servidor
@bot.message_handler(commands=['maintenance'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/maintenance"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún servidor. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    com = ("/usr/bin/robocop --robocop --maintenance --time 1h --server " + m.text[len("/maintenance"):])
    bot.send_chat_action(cid, 'typing')
    os.system(com)	

# Recoger información del servidor
@bot.message_handler(commands=['info'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/info"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún servidor. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    com = ("/usr/bin/robocop --robocop --info --server " + m.text[len("/info"):])
    bot.send_message(cid, "Recogiendo la información del servidor " + m.text[len("/info"):] + "...")
    bot.send_chat_action(cid, 'typing')
    time.sleep(3)
    os.system(com)

# Comprobar estado URL
@bot.message_handler(commands=['url'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/url"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún servidor. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    com = ("/usr/bin/robocop --robocop --url " + m.text[len("/url"):])
    bot.send_message(cid, "Revisando el estado de la URL " + m.text[len("/url"):] + "...")
    bot.send_chat_action(cid, 'typing')
    time.sleep(3)
    os.system(com)

# Matar un proceso
@bot.message_handler(commands=['kill'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/kill"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún dato. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    comm_kill = m.text[len("/kill\n"):].split(" ",2)
    server_kill = comm_kill[0]
    proc_kill = comm_kill[1]
    com = ("/usr/bin/robocop --robocop --kill_proc " + proc_kill + " --server " + server_kill)
    bot.send_message(cid, "Ejecutando el comando para matar el proceso " + proc_kill + "...")
    bot.send_chat_action(cid, 'typing')
    time.sleep(1)
    os.system(com)

# Parar un servicio
@bot.message_handler(commands=['stop_proc'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/stop_proc"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún dato. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    comm_stop = m.text[len("/stop_proc\n"):].split(" ",2)
    server_stop = comm_stop[0]
    proc_stop = comm_stop[1]
    com = ("/usr/bin/robocop --robocop --stop_proc " + proc_stop + " --server " + server_stop)
    bot.send_message(cid, "Ejecutando el comando para parar el servicio de " + proc_stop + "...")
    bot.send_chat_action(cid, 'typing')
    time.sleep(1)
    os.system(com)

# Arrancar un servicio
@bot.message_handler(commands=['start_proc'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/start_proc"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún dato. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    comm_start = m.text[len("/start_proc\n"):].split(" ",2)
    server_start = comm_start[0]
    proc_start = comm_start[1]
    com = ("/usr/bin/robocop --robocop --start_proc " + proc_start + " --server " + server_start)
    bot.send_message(cid, "Ejecutando el comando para arrancar el servicio de " + proc_start + "...")
    bot.send_chat_action(cid, 'typing')
    time.sleep(1)
    os.system(com)

# Estado de un servicio
@bot.message_handler(commands=['service'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/service"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún dato. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    comm_status = m.text[len("/service\n"):].split(" ",3)
    server_status = comm_status[0]
    service_status = comm_status[1]
    proc_status = comm_status[2]
    com = ("/usr/bin/robocop --robocop --service " + service_status + " " + proc_status + " --server " + server_status)
    bot.send_message(cid, "Ejecutando el comando para ver el estado del servicio de " + proc_status + "...")
    bot.send_chat_action(cid, 'typing')
    time.sleep(1)
    os.system(com)

# Comprueba un FS
@bot.message_handler(commands=['fs'])
def command_long_text(m):
    cid = m.chat.id
    mystring = (m.text[len("/fs"):])
    if not mystring:
       bot.send_message(cid, "No has pasado ningún dato. Prueba de nuevo o revisa el comando /ayuda")
       exit()
    comm_fs = m.text[len("/fs\n"):].split(" ",2)
    server_fs = comm_fs[0]
    fs = comm_fs[1]
    com = ("/usr/bin/robocop --robocop --fs " + fs + " --server " + server_fs)
    bot.send_message(cid, "Ejecutando el comando para ver el estado del fs " + fs + " en el servidor " + server_fs + "...")
    bot.send_chat_action(cid, 'typing')
    time.sleep(1)
    os.system(com)

# filter on a specific message
@bot.message_handler(func=lambda message: message.text == "Hola")
def command_text_hi(m):
    bot.send_message(m.chat.id, "¡Hola " + str(m.chat.first_name) + "!", reply_markup=markup)


@bot.message_handler(func=lambda message: True, content_types=['text'])
def command_default(m):
    bot.send_message(m.chat.id, "No te entiendo, prueba con /ayuda", reply_markup=markup)


bot.polling()
