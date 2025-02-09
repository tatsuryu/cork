#!/usr/bin/env bash

# ===========================================================
#
# Script para instalação automatizada dos programas
# de cada usuário
#
# ===========================================================

# ===========================================================
#
# Sessão de declaração de funções
#
# ===========================================================

# Passa a senha para o comando sudo

auto_sudo() {

	echo -e "${password}\n" | sudo -S ${1}

}

# Cria o arquivo que conterá os programas instalados

arquivo_programas() {

	for ((i=0; i<${#array_program[@]}; ++i)); do

		echo "${array_program[${i}]}:${array_answer[${i}]^^}" >> ${install_dir}/temp.txt

	done

	arq=${install_dir}/temp.txt

	printf '\n%23s %9s\n\n' 'PROGRAMS' 'YES/NO'
	printf '%23s ---- %1s\n' $(cut -d':' -f1- --output-delimiter=' ' ${arq})
	printf '\n'

}

# Imprime o modo de uso do programa (usado no GETOPTS)

print_usage() {

   echo -e "For usage, run: $ ./$(basename ${0})"

}

# Sessão de captura de argumentso (GETOPTS)

while getopts 'vh' opts 2> /dev/null; do
   case ${opts} in
      v)
         echo -e "cork version ${version}"
         exit
         ;;
      h)
         print_usage
         exit
         ;;
      ?)
         print_usage
         exit 1
         ;;
      esac
done

shift $((OPTIND - 1))

# ===========================================================
#
# Sessão de declaração de variáveis
#
# ===========================================================

readonly version="2.4.4"

array_program=("CHROME" "VS-CODE" "DISCORD" "FILEZILLA" "ANYDESK" "POSTMAN" "MY-SQL/WORKBENCH" "SIMPLESCREENRECORDER" "FLAMESHOT" "KOLOURPAINT" "NPM")

install_dir="${HOME}/instalacao"

# ===========================================================
#
# Inicio do programa
#
# ===========================================================

mkdir ${install_dir}

mv ./cork.sh ${install_dir}

# ===========================================================

# Sessão de captura de informações

ress="n"

while [ "${ress,,}" == "n" ]; do

	clear

	echo ""
	echo "======================   CONFIGURAÇÃO   ======================"
	echo ""

	read -p "Usuário git: " usergit
	read -p "E-mail git: " emailgit

	echo ""

	read -s -p "Password [sudo]: " password

	echo ""
	echo ""

	read -p "As informações estão corretas (y/n)? " ress

	clear

done

echo "${password}" > ${install_dir}/pass.txt

# Baixa .desktop para o autostart

wget -P ${install_dir} "https://raw.githubusercontent.com/rhuan-pk/cork/master/cork.desktop"

[ ! -e ${HOME}/.config/autostart ] && mkdir ${HOME}/.config/autostart

mv ${install_dir}/cork.desktop ${HOME}/.config/autostart

# Baixa .sh de instalação dos programas

wget -P ${install_dir} "https://raw.githubusercontent.com/rhuan-pk/cork/master/script-cork.sh"

chmod +x ${install_dir}/script-cork.sh

auto_sudo "mv ${install_dir}/script-cork.sh /usr/local/bin"

# Sessão de captura dos programas a serem instalados

clear

ress="n"

while [ "${ress,,}" == "n" ]; do

	echo ""
	echo "======================   PROGRAMAS   ======================"
	echo ""

	arr_global='export array_answer=('

	for ((i=0; i<${#array_program[@]}; ++i)); do

		read -p "Deseja instalar ${array_program[${i}]} (y/n)? " array_answer[${i}]
		arr_global+="\"${array_answer[${i}]}\""
    
	        [ ${i} -lt $((${#array_program[@]}-1)) ] && arr_global+=' '

	done

	arr_global+=')'

	echo ""

	read -p "Programas a serem instalados estão corretos (y/n)? " ress

	clear

done

arquivo_programas > ${HOME}/programas.txt

rm ${install_dir}/temp.txt

echo "${arr_global}" >> ${HOME}/.bashrc

# ===========================================================

# Sessão de atualização do sistema

sleep 1.5

echo ""
echo ">>>>>>>>>>>>>>>>>>>>>>   ATUALIZAÇÃO   <<<<<<<<<<<<<<<<<<<<<<"
echo ""

auto_sudo "apt update -y"
auto_sudo "apt upgrade -y"
auto_sudo "apt full-upgrade -y"

echo ""
echo ">>>>>>>>>>>>>>>>>>>>>>   FINALIZADO   <<<<<<<<<<<<<<<<<<<<<<"
echo ""

sleep 1.5

clear

# ===========================================================

# Sessão de instalação e configuração do git

echo ""
echo "======================   GIT   ======================"
echo ""

auto_sudo "apt install git -y"

echo ""
echo "--- switch ---"
echo ""

git --version

echo ""
echo "--- switch ---"
echo ""

git config --global user.name "${usergit}"
git config --global user.email "${emailgit}"

echo ">>> Usuario git para \"normal user\" criado !"

echo ""
echo ">>> Finalizado !"
echo ""

sleep 1.5

# ===========================================================

# Sessão de instalação dos gerenciados de pacotes

echo "======================   GERENCIADORES-DE-PACOTES   ======================"
echo ""

echo ">>> SNAP <<<"
echo ""

auto_sudo "apt install snapd -y"

echo ""
echo ">>> FLATPAK <<<"
echo ""

auto_sudo "apt install flatpak -y"

echo ""
echo ">>> CURL <<<"
echo ""

auto_sudo "apt install curl -y"

sleep 5

echo ""
echo "======================   Version ${version}   ======================"
echo ""
echo ""
echo "A simple solution..."
echo ""
echo "Created by: Crazy Group Inc © (CG)"
echo ""
echo ""
echo "================================================================"

echo ""
echo "Reiniciando em 30s (cancelar o reboot: ctrl+c)"
echo ""

seconds=30

sif=$(( $(date +%s) + ${seconds} )) #seconds in the future

while [ ${sif} -ge $(date +%s) ]; do 
	
	sifdiff=$(( ${sif} - $(date +%s) ))
	echo -ne "$(date -u --date @${sifdiff} +%H:%M:%S)\r"
	
done

reboot

# ===========================================================
