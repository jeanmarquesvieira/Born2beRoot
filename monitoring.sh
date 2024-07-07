#!/bin/bash
# above line tells the system that this script should be executed in bash
# without this, the current shell would be used to execute the script, meaning that it
# could be bash, but could also be any other one 

# uname -a: shows info about the system
architecture=$(uname -a)

# lscpu: shows more detailed info abut the sysm
# grep: fetches the specified pattern
# awk -F: splits each line at the colon (:)
# grep -o -E '[0-9]+': extracts all digits from the input, -o is for printing the matching part and -E is for RegEx
# head -1: prints only the 1st line of the output
sockets=$(lscpu | grep 'Socket(s)' | awk -F: '{print $2}' | grep -o -E '[0-9]+' | head -1)

vCPU=$(lscpu | grep 'CPU(s)' | awk -F: '{print $2}' | grep -o -E '[0-9]+' | head -1)

# free command displays the RAM, which is volatile, since it's deleted when the computer's powered off
mem_used=$(free -m | grep -A 2 'used' | sed -n '2p' | awk '{print $3}')
mem_free=$(free -m | grep -A 2 'used' | sed -n '2p' | awk '{print $2}')
mem_percent=$(free | awk '/Mem/{printf("%.2f%%", $3/$2*100)}')

# disk space shows info about the HD memory
disk_space_used=$(df -BM | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
disk_space_total=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
disk_usage_percent=$(df -BM | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%d%%"), ut/ft*100}')

# amount of CPU resources being used, namely processes executing or waiting to be executed in a 
# given time
cpu_load=$(mpstat | awk '$12 ~ /[0-9.]+/ { printf "%.1f\n", 100 - $12 }')

last_boot=$(who -b | grep 'boot' | awk -F "boot  " '{print $2}')

# partitions are ways to divide a disk into separate sections, whilst LVM,
# Logical Volume Manager, are a way to approach a more flexible disk management,
# since it allows dynamically resizing disk size
lvm_use=$(lsblk | grep 'lvm' | ( if read -r line; then echo "yes"; else echo "no"; fi ))

# TRANSMISSION PROTOCOL CONNECTIONS are ways to enable safe communication through the internet
# sending data from one ip to another securely through data packets
tcp_connections=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')

# number of users logged in the system
user_log=$(users | wc -w)

# hostname -I stands for private ip
network_ip=$(hostname -I)
# MEDIA ACCESS CONTROL ADDRESS is a unique id assigned to a network interface card 
# MAC addresses can be used to send data between different devices within the same network
mac_address=$(ip link show | awk '$1 == "link/ether" {print $2}')

# number of times sude has been executed on the system
sudo=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# wall sends a message to all terminals
# tty stands for teletypewriter, which is the physical terminal connected to a computer, 
# such as a keyboard and monitor
# pts stands for pseudo terminal slave, representing virtual terminals that are created for remote
# connections such as SSH 
wall "	#Architecture: $architecture
	#CPU physical : $sockets
	#vCPU: $vCPU
	#Memory Usage: $mem_used/${mem_free}MB ($mem_percent)
	#Disk Usage: $disk_space_used/${disk_space_total}Gb ($disk_usage_percent)
	#CPU load: $cpu_load%
	#Last boot: $last_boot
	#LVM use: $lvm_use
	#Connections TCP : $tcp_connections ESTABLISHED
	#User log: $user_log
	#Network: IP $network_ip ($mac_address)
	#Sudo : $sudo cmd"
