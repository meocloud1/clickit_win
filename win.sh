#!/bin/bash

#==================================================== ===
# System Request: Debian/Ubuntu
# Author: meocloud1
# Description: OpenVZ VPS - Windows
# Open Source: https://github.com/meocloud1/clickit_win
#==================================================== ===




# Install Remote Desktop for Debian
install_lxde_vnc(){

# Uninstall or remove unnecessary system services
apt-get purge apache2 -y

# Upgrade Debian
apt-get update -y

# Install LXDE+VncServer desktop environment
apt-get install xorg lxde-core -y
apt-get install tightvncserver -y
apt-get install curl -y

# Set VNC password
echo "---------------------------------------"
echo "Follow the prompts to set the VNC Password remote desktop password"
echo "---------------------------------------"
vncserver:1
vncserver -kill :1

# Automatically start the LXDE desktop when VNC starts
sed -i '/starlxde/'d /root/.vnc/xstartup
echo "starlxde &" >> /root/.vnc/xstartup

chmod +x /root/.vnc/xstartup
}




install_lxde_vnc_menu(){
local_ip=`curl -4 ip.sb`
clear
echo "---------------------------------------"
echo "Prompt: Install Lxde+VNC Remote Desktop Successfully"
echo "VNC server: ${local_ip}:1 not started"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu
}




# Add firefox browser and Simplified Chinese font
add_firefox_ttf(){
apt-get install iceweasel -y
apt-get install ttf-arphic-ukai ttf-arphic-uming ttf-arphic-gbsn00lp ttf-arphic-bkai00mp ttf-arphic-bsmi00lp -y

clear
echo "---------------------------------------"
echo "Prompt: Install Firefox browser and Simplified Chinese fonts successfully"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu
}




# Install qemu+win virtual machine
install_qemu_win(){

# Install qemu virtual machine
apt-get install qemu -y

# Install win to the virtual machine
wget https://www.dropbox.com/s/gq3e3feukskw72k/winxp.img
mkdir /root/IMG
mv winxp.img /root/IMG/win.img

touch /root/.vnc/ram.txt
cat <<EOF > /root/.vnc/ram.txt
700
EOF
}




install_qemu_win_menu(){
local_ip=`curl -4 ip.sb`
clear
echo "---------------------------------------"
echo "Prompt: Qemu+WindowsXP virtual machine installed successfully"
echo "WindowsXP default boot memory 700M hard disk 25G"
echo "Remote desktop address: ${local_ip}:3389 not started"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu
}




check_vnc_install_qemu_win(){
if [[ -e /usr/bin/vncserver ]]; then
install_qemu_win
else
install_lxde_vnc
install_qemu_win
fi
}




# Start VNC+lxde/qemu_win
start_vnc(){
vncserver -kill :1
lsof -i:"3389" | awk '{print $2}'| grep -v "PID" | xargs kill -9

getram=$(cat /root/.vnc/ram.txt)

vncserver:1
qemu-system-x86_64 -hda /root/IMG/win.img -m ${getram}M -smp 1 -daemonize -vnc :2 -net nic,model=virtio -net user -redir tcp:3389::3389

local_ip=`curl -4 ip.sb`
clear
echo "---------------------------------------"
echo "Prompt: Start Lxde+VNC (+WindowsXP if installed) succeeded"
echo "VNC server: ${local_ip}:1"
echo ""
echo "If WindowsXP is installed, it is expected to be able to connect to the desktop in 5 minutes"
echo "VNC server: ${local_ip}:2"
echo "Remote desktop address: ${local_ip}:3389"
echo "Username: administrator Password: abfan.com"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu
}

# Close VNC+lxde/qemu_win
stop_vnc(){
vncserver -kill :1
lsof -i:"3389" | awk '{print $2}'| grep -v "PID" | xargs kill -9

clear
echo "---------------------------------------"
echo "Prompt: Close Lxde+VNC (+WindowsXP if enabled) succeeded"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu
}




# Set Windows startup memory
set_win_ram(){
if [[ -e /root/IMG/win.img ]]; then

clear
echo "---------------------------------------"
echo "Please enter the RAM value to be set, such as: 1024"
echo "---------------------------------------"
echo ""

read -e -p "Please enter:" ram
[[ -z ${ram} ]] && ram="none"
if [ "${ram}" = "none" ];then
set_win_ram
fi

touch /root/.vnc/ram.txt
cat <<EOF > /root/.vnc/ram.txt
${ram}
EOF

clear
echo "---------------------------------------"
echo "The operation has been completed. The current Windows virtual machine memory is: ${ram}M"
echo "Restart Windows virtual machine to take effect"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu

else

clear
echo "---------------------------------------"
echo "No Windows system image detected, please install first"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu

fi
}




win_iso_install(){
clear
echo "---------------------------------------"
echo "Note: This command must be executed inside the VNC Remote Desktop"
echo "After the installation is complete, log in to the Windows system:"
echo " 1. My computer - right click property - allow remote desktop"
echo " 2. Add account password"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to continue! Exit with 'Ctrl'+'C' !"

mv /root/*.iso /root/win.iso

if [[ -e /root/win.iso ]]; then

apt-get install qemu -y

win_iso_ram_disk

touch /root/.vnc/ram.txt
cat <<EOF > /root/.vnc/ram.txt
${nram}
EOF

rm -rf /root/IMG
mkdir /root/IMG
qemu-img create /root/IMG/win.img ${ndisk}G

qemu-system-x86_64 -cdrom /root/win.iso -m ${nram}M -boot d /root/IMG/win.img -k en-us

clear
echo "---------------------------------------"
echo "After the installation is complete, log in to the Windows system:"
ececho " 1. My computer - right click property - allow remote desktop"
echo " 2. Add account password"
echo "Back to shell Start VNC to run New Windows system in the background"
echo "---------------------------------------"

else

clear
echo "---------------------------------------"
echo "No iso image file detected! Cancel installation"
echo "Please manually download the iso system image into the /root/ directory"
echo "Note: The image file extension must be .iso lowercase"
echo "---------------------------------------"

fi
}




win_iso_ram_disk(){

clear
echo "---------------------------------------"
echo "Enter the RAM value to be set, for example: 1024"
echo "---------------------------------------"
echo ""

read -e -p "please enter (Default size 700):" nram
[[ -z ${nram} ]] && nram="700"

echo ""
echo "---------------------------------------"
echo "Enter the hard disk value to be set, for example: 25"
echo "---------------------------------------"
echo ""

read -e -p "please enter (Default size 25):" ndisk
[[ -z ${ndisk} ]] && ndisk="25"

}




winxp_iso_install(){
cd /root
wget https://www.dropbox.com/s/x20vw6bkwink0fm/winxp.iso
win_iso_install
}




# uninstall all
install_all(){

# uninstall lxde and vnc
vncserver -kill :1

apt-get purge xorg -y
apt-get purge lxde -y
apt-get purge tightvncserver -y
apt-get purge curl -y

rm -rf /root/.vnc
rm -rf /root/Desktop
rm -rf /root/.cache
rm -rf /root/.config
rm -rf /root/.dbus
rm -rf /root/.gconf
rm -rf /root/.gvfs
rm -rf /root/.Xauthority
rm -rf /root/.xsession-errors

# Uninstall firefox browser and Simplified Chinese fonts
apt-get purge iceweasel -y
apt-get purge ttf-arphic-ukai ttf-arphic-uming ttf-arphic-gbsn00lp ttf-arphic-bkai00mp ttf-arphic-bsmi00lp -y

# Uninstall the qemu virtual machine
lsof -i:"3389" | awk '{print $2}'| grep -v "PID" | xargs kill -9
apt-get purge qemu -y

# delete img mirror
if [[ -e /root/IMG/win.img ]]; then

echo "---------------------------------------"
echo "Detected that the installed Windows system image is deleted?"
echo "---------------------------------------"
echo ""

read -e -p "Please enter (y/n):" rmIMG
case ${rmIMG} in
[yY][eE][sS]|[yY])
rm -rf /root/IMG
echo "The /root/IMG/win.img system image has been removed"
;;
*)
echo "Cancel delete operation Image location: /root/IMG/win.img"
esac

fi

clear
echo "---------------------------------------"
echo "Uninstall Lxde+VNC, FireFox+ttf, Qemu+Windows successfully"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu
}




get_help(){
local_ip=`curl -4 ip.sb`
clear
echo "---------------------------------------"
echo " **** Custom install Windows system version ****"
echo "---------------------------------------"
echo ""
echo " 1. Execute 1 and 4 in the menu to install and start the Lxde+VNC service"
echo ""
echo " 2. Manually download the Windows system iso image file to the /root/ directory"
echo ""
echo "Take Deepin Lite WindowsXP as an example (support original installation and Ghost system)"
echo "cd /root"
echo "wget ​​https://www.dropbox.com/s/x20vw6bkwink0fm/winxp.iso"
echo ""
echo " 3. Use Windows VNC client to connect to the remote desktop"
echo ""
echo " a.VNC server address: ${local_ip}:1"
echo "Windows client download address:"
echo "https://github.com/meocloud1/clickit_win/blob/main/VNC-Viewer-6.22.515-Windows.exe"
echo ""
echo " b. Open the terminal (Terminal) in the VNC desktop and execute the following command: "
echo ""
echo "bash win.sh windows"
echo ""
echo "Note: This command must be executed from within a VNC remote desktop"
echo "Follow the prompts to set the virtual machine memory and hard disk size, the default is 700M memory and 25G hard disk"
echo "After installing the system according to the prompt: 1. My computer-right-click properties-allow remote desktop 2.Add power-on password"
echo ""
echo "After debugging is completed, return to the shell and execute the script to start VNC to run the new Windows system in the background"
echo ""
echo ""
echo "c. If you want to install WindowsXP system, execute bash win.sh windowsxp directly in VNC, it will automatically download the image and execute the installation"
echo "---------------------------------------"
echo ""

read -e -p "Press any key to return to menu..."
clear
menu
}




# install menu
menu(){
echo "---------------------------------------"
echo " 1. Clickit-win installation of Lxde+VNC remote desktop"
echo " 2. Add Firefox browser and Simplified Chinese font"
echo ""
echo " 3. Clickit installation of Qemu+WindowsXP virtual machine"
echo ""
echo " 4. Start Lxde+VNC (+WindowsXP if installed)"
echo "5. Close Lxde+VNC (+WindowsXP if it is enabled)"
echo ""
echo "6. Set WindowsXP boot memory (default 700M)"
echo ""
echo " 7. Custom install Windows system version"
echo ""
echo "8. Uninstall all"
echo "9. Exit script"
echo "---------------------------------------"
echo ""

read -e -p "Please enter the corresponding number:" num
case $num in
	1)
install_lxde_vnc
install_lxde_vnc_menu
;;
	2)
add_firefox_ttf
;;
3)
check_vnc_install_qemu_win
install_qemu_win_menu
;;
4)
start_vnc
;;
5)
stop_vnc
;;
6)
set_win_ram
;;
7)
get_help
;;
	8)
install_all
;;
	9)
exit 0
;;
*)
clear
menu
esac
}




# Check root privileges
if [ `id -u` == 0 ]; then
echo "The current user is the root user to start the installation process"
else
echo "The current user is not the root user, please switch to the root user and execute the script again"
exit 1
fi




# Script menu
case "$1" in
windows)
win_iso_install
;;
windowsxp)
winxp_iso_install
;;
*)
clear
menu
esac


# Please keep the copyright for reprinting: https://github.com/meocloud1/clickit_win

