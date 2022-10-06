#Clickit
## OpenVZ virtualization (architecture) VPS clickit installation of Windows systems

The test environment is Debian10 (in theory, most systems in the Debian Ubuntu series are supported)

````
wget -N --no-check-certificate https://github.com/meocloud1/clickit_win/main/win.sh && chmod +x win.sh && bash win.sh
````

---
---

### Install Remote Desktop for Debian/Ubuntu
````
Execute 1 and 4 in sequence

If you need to use a browser, execute 1, 2, 4 in sequence
````

### Install WindowsXP for Debian/Ubuntu
````
Execute 3 and 4 in turn

The default startup memory is 700M. If you need to modify the startup memory, execute 3, 6, and 4 in sequence.
````

### Install custom Windows system (iOS mirror)
````
Go 7 Follow the prompts
````

---
---

### Precautions
````
1. If the VNC desktop is blank after installation, check whether there is Sub-process /usr/bin/dpkg returned an error code (1) error

Solution 1:
Reinstall after executing rm /var/lib/dpkg/info/$nomdupaquet* -f

Solution 2:
Replace the source or replace the system

2. About OpenVZ
It is easy to install Windows system CPU in the VPS of OpenVZ framework to run 100%
Long-term CPU, memory full, general host companies do not allow this, may be judged to be abused and blocked (a short test for a few hours or half a day is no problem)

The implementation principle of the script is to install and run a Windows virtual machine using the qemu virtualization tool in the Debian/Ubuntu system
Therefore, the hardware resources you allocate for the Windows system should be smaller than the actual vps configuration
For example: If your vps is 2-core CPU and 2G memory, then the hardware resources you allocate to Windows should be 1-core CPU, 1G memory, or less. This prevents resources from being overwhelmed

If your vps is unfortunately unblocked during the test, send a work order to explain the situation (just make up a reason), generally it can be unblocked
If you need to run Windows for a long time, be sure to use as few resources as possible, it is recommended not to exceed 50% of the actual hardware resources of the vps
````

---
---

### Self-start Windows virtual machine at boot


Edit /etc/rc.local
Add a new line before exit 0 and paste the following code (the specific configuration can be modified by yourself)

````
qemu-system-x86_64 -hda /root/IMG/win.img -m 700M -smp 1 -daemonize -vnc :2 -net nic,model=virtio -net user -redir tcp:3389::3389
````

【Modify port mapping】
The default host only forwards the 3389 port of the remote desktop to the Windows system. If it is used to run programs (such as building a website), you may need to forward ports such as 80, 443, 22, etc.
Just modify the end to add multiple ports, such as: -redir tcp:3389::3389 -redir tcp:443::443 -redir tcp:80::80
The specific format is -redir [tcp|udp]:host-port::guest-port

Check whether the port is properly mapped:
lsof -i:"3389"
If there is return content, the mapping is normal

【Modify other configuration】
-m 700M means the memory is 700M
-smp 2 means use two CPU cores
-daemonize runs the virtual machine in the background
-vnc :2 enable vnc remote access where: 2 identifies the vnc port
-net nic,model=virtio -net user means that the network is in NAT mode. OpenVZ acts as a gateway and firewall for virtual machines
-redir tcp:3389::3389 Redirects port 3389 of the virtual machine to the host's network interface
