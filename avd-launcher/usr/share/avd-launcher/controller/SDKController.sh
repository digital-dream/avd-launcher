#! /bin/bash

import model.AndroidSDK='source ../model/AndroidSDK.sh';
import model.AVD='source ../model/AVD.sh';
import controller.GUIController='source ../controller/GUIController.sh'

# "Classe" que controla ações com o Android SDK no AVD Launcher.
#
# Author: Gustavo Moraes <gustavosotnas1@gmail.com>
#
# This file is subject to the terms and conditions of the GNU General Public
# License. See the file COPYING in the main directory of this archive
# for more details.

# Verifica se a pasta onde está localizada o Android SDK está definida.
verifySDKPath()
{
	if ! model.AndroidSDK getFolderPath >/dev/null # Se não sabe onde está o SDK
	then
		if model.AndroidSDK setDefaultFolderPath
		then
			return $TRUE; # O Android SDK está na localização default no Linux
		else # O SDK não está na localização default
			controller.GUIController defineAndroidSDKPath; #Usuário define o SDK
		fi
	else # A localização do SDK já foi setada anteriormente
		return $TRUE;
	fi
}

# Verifica se a pasta onde estão os AVDs (Android Virtual Device) está definida.
verifyAVDPath()
{
	if ! model.AVD getFolderPath >/dev/null # Se não se sabe onde está os AVDs
	then
		if model.AVD setDefaultFolderPath
		then
			return $TRUE; # Os AVDs estão na localização default no Linux
		else # Os AVDs não estão na localização default
			controller.GUIController defineAVDPath; #Usuário define a pasta AVDs
		fi
	else # A localização dos AVDs já foi setada anteriormente
		return $TRUE;
	fi
}

# Cria um array do nome dos AVDs para o usuário escolher, 
# sendo o primeiro AVD listado a opção marcada por "default" na lista.
# Retorna:
#	$AVDS_LIST - string com o "esqueleto" da lista dos AVDs localizados 
# 				 para execução no formato de checklist do "zenity/YAD", exemplo: 
# 	"TRUE Android_Wear_Round_API_20 FALSE Nexus_6_API_21 FALSE Nexus_S_API_19"
listInstalledAVDs()
{
	local old_IFS=$IFS; # Armazena temp. o Internal Field Separator padrão
	IFS=$'\n'; # Define separador (quebra de linha) para array "$installed_AVDs"
	local installed_AVDs=($(find `model.AVD getFolderPath` -maxdepth 1 | sort | \
	grep .ini | xargs --delimiter='\n' \
	basename -a -s .ini));
	IFS=$old_IFS; # Restaura o IFS padrão
	#>&2 echo "${installed_AVDs[@]}"

	if [ -n "$installed_AVDs" ] # Se a variável de AVDs instalados NÃO for nula
	then # Existem AVDs no computador
		local AVDS_LIST; # Var que terá o resultado do array para string do YAD
		for f in "${installed_AVDs[@]}"
		do
			if [ "$f" == "${installed_AVDs[0]}" ]
			then
				AVDS_LIST="${AVDS_LIST}TRUE "; # Palavra-chave do "yad" para marcar na lista (um "radio button")
			else
				AVDS_LIST="${AVDS_LIST}FALSE "; # Palavra-chave do "yad" para NÃO marcar na lista
			fi
			AVDS_LIST="${AVDS_LIST}${f// / } "; # O nome do AVD, substituindo espaços (" ") por caractere unicode U+2004
		done
		return_str "$AVDS_LIST";
	else # A variável "$installed_AVDs" é NULA
		controller.GUIController defineAVDPath; #Usuário define a pasta AVDs
	fi
}

# Chamada o emulador do Android SDK para executar o AVD desejado pelo usuário.
# Esta função é sempre executada em BACKGROUND pelo 'defineUserAVDChosen'.
# Parâmetros:
#	$1 - o nome do Android Virtual Device (AVD) escolhido pelo usuário
runAndroidSDKEmulator()
{
	# Muda diretório para chamar o emulador com o ponto-barra ("./")
	cd "`model.AndroidSDK getFolderPath`"/tools; # NÃO MODIFIQUE ISSO!
	# Executa o Android SDK Emulator
	>&2 ./emulator -avd "$CHOSEN_AVD" -netspeed full -netdelay none >/dev/null;
}

### MAIN ####

case $1 in
	"verifySDKPath") verifySDKPath;;
	"verifyAVDPath") verifyAVDPath;;
	"listInstalledAVDs") listInstalledAVDs;;
	"runAndroidSDKEmulator") runAndroidSDKEmulator "$2";;
esac;