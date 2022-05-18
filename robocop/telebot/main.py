# -*- coding: utf-8 -*-

import telebot
from telebot import types
import time
import os
import sys
from datetime import datetime
from sys import exit
import subprocess


TOKEN = '5291565375:AAEV1KVA4LY4NcpZ0HgGLHEim4926KC96XM'  # token brindado por BotFather

LOG_DIR = "/home/ansible/git/Telegrambots/robocop/logs/bot.log" # directorio para log
USERS_DIR = "/home/ansible/git/Telegrambots/robocop/telebot/usuarios.txt" # directorio para usuarios

knownUsers = []  # registro temporal de usuarios

commands = {  
    'start': 'Empezar a mensajear con el bot',
    'ayuda': 'Da informacion sobre los comandos disponibles',
    'cpu': 'Muestra el estado de la CPU del servidor elegido',
    'ram': 'Muestra el estado de la memoria del servidor elegido',
    'fs': 'Muestra el estado del FS en el servidor elegido',
    'reboot': 'Reinicia el servidor elegido',
    'service': 'Muestra el estado del SERVICIO en el servidor elegido',
    'updates': 'Muestra si hay actualizaciones en el servidor',
    'install_updates': 'Instala las actualizaciones pendientes',
    'maintenance': 'Pone en mantenimiento el servidor elegido durante un tiempo determinado',
    'stop': 'Para el mensajeo con el bot' 
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

# Ejecuta un comando
@bot.message_handler(commands=['exec'])
def command_long_text(m):
    cid = m.chat.id
    bot.send_message(cid, "Ejecutando: " + m.text[len("/exec"):])
    bot.send_chat_action(cid, 'typing') 
    time.sleep(2)
    f = os.popen(m.text[len("/exec"):])
    result = f.read()
    bot.send_message(cid, "Resultado: " + result, reply_markup=markup)


# Cambia de directorio
@bot.message_handler(commands=['cd'])
def command_long_text(m):
    cid = m.chat.id
    bot.send_message(cid, "Cambio a directorio: " + m.text[len("/cd"):])
    bot.send_chat_action(cid, 'typing') 
    time.sleep(2)
    os.chdir(m.text[len("/cd"):].strip())
    f = os.popen("pwd")
    result = f.read()
    bot.send_message(cid, "Directorio actual: " + result, reply_markup=markup)

# filter on a specific message
@bot.message_handler(func=lambda message: message.text == "Hola")
def command_text_hi(m):
    bot.send_message(m.chat.id, "¡Hola " + str(m.chat.first_name) + "!", reply_markup=markup)


@bot.message_handler(func=lambda message: True, content_types=['text'])
def command_default(m):
    bot.send_message(m.chat.id, "No te entiendo, prueba con /ayuda", reply_markup=markup)


bot.polling()
