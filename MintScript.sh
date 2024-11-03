pause(){
   read -p "
Press [ENTER] to continue" placeholder
}
# Check for updates
update_settings(){
   sudo apt update -y
   wait
   sudo apt upgrade -y
}
# List all users
list_users_and_admins(){
    awk -F':' '{ print $1}' /etc/passwd
    getent group lpadmin
    getent group admin
}
# User Management
user_prompt(){
   read -p "Select from one of the following choices:
   [1] Add a new user
   [2] Remove a current user and their directories
   [3] Create a new password for a user
  > " prompt
   case "${prompt}" in
      1 ) add_user;;
      2 ) remove_user;;
      3 ) create_password;;
   esac
}
add_user(){
   read -p "Enter username to add: " username
   pass=$(perl -e 'print crypt("Cyb3rPatr!0t$")')
   sudo useradd -m -p ${pass} ${username}
   echo "Username ${username} has been added. Password: Cyb3rPatr!0t$"
}
remove_user(){
   read -p "Enter username to remove: " username
   sudo userdel -r ${username}
   echo "Username ${username} has been deleted."
}
create_password(){
   read -p "Enter username to create new password for: " username
   sudo passwd ${username}
}
# Group Management
group_management(){
   read -p "Select from one of the following choices:
   [1] Create a group
   [2] Remove a group
   [3] Add a user to a group
   [4] Remove a user from a group
  > " prompt
  case "${prompt}" in
     1 ) read -p "Enter group name to create: " name; sudo groupadd ${name}; echo "Added group ${name}";;
     2 ) read -p "Enter a group name to remove: " name; sudo groupdel ${name}; echo "Removed group ${name}";;
     3 ) read -p "Enter a group name: " group; read -p "Enter a user to be added: " user; sudo adduser ${user} ${group};;
     4 ) read -p "Enter a group name: " group; read -p "Enter a user to be removed: " user; sudo deluser ${user} ${group};;
  esac
}
# Update Passwd Req
update_password_req(){
   sudo apt-get install libpam_pwquality
   wait
   mkdir ~/Downloads/Backups
   cp /etc/login.defs ~/Downloads/Backups/login.defs
   cp /etc/pam.d/common-password ~/Downloads/Backups/common-password
   cp /etc/pam.d/common-auth ~/Downloads/Backups/common-auth
   cp /etc/sysctl.conf ~/Downloads/Backups/sysctl.conf
   cp ~/Downloads/Linux/configs/login.defs /etc/login.defs
   cp ~/Downloads/Linux/configs/common-password /etc/pam.d/common-password
   cp ~/Downloads/Linux/configs/common-auth /etc/pam.d/common-auth
   cp ~/Downloads/Linux/configs/sysctl.conf /etc/sysctl.conf
   wait
   sudo sysctl --system
   sudo touch /usr/share/pam-configs/faillock
   sudo touch /usr/share/pam-configs/faillock_notify
   wait
   cp ~/Downloads/Linux/configs/faillock /usr/share/pam-configs/faillock
   cp ~/Downloads/Linux/configs/faillock_notify /usr/share/pam-configs/faillock_notify
   wait
   read -p "REMEMBER THIS!
   Select, with the spacebar, Notify on failed login attempts, and Enforce failed login attempt counter, then select <Ok>. Press [Enter] to continue." placeholder
   sudo pam-auth-update
}
# Enable Firewall (UFW)
config_firewall(){
   sudo ufw enable
   wait
   sudo ufw status
   wait
   sudo ufw default deny incoming
   wait 
   sudo ufw default allow outgoing
   wait sudo ufw app list
   wait 
   read -p "Is SSH/OpenSSH Authorized? (ReadME) [y/n] > " prompt
   case "$prompt" in
      y ) sudo ufw allow OpenSSH; sudo apt install openssh-server -y;;
      n ) sudo apt purge openssh-server -y;;
   esac
   # Secure SSH Config
   sudo sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
   wait
   sudo service ssh restart
}
# Secure files
secure_files(){
   sudo chmod 644 /etc/passwd
   sudo chmod 640 /etc/shadow
   sudo chmod 644 /etc/group
   sudo chmod 640 /etc/gshadow
   sudo chmod 440 /etc/sudoers
   sudo chmod 644 /etc/ssh/sshd_config
   sudo chmod 644 /etc/fstab
   sudo chmod 600 /boot/grub/grub.cfg
   sudo chmod 644 /etc/hostname
   sudo chmod 644 /etc/hosts
   sudo chmod 600 /etc/crypttab
   sudo chmod 640 /var/log/auth.log
   sudo chmod 644 /etc/apt/sources.list
   sudo chmod 644 /etc/systemd/system/*.service
   sudo chmod 644 /etc/resolv.conf
}
# Disable Root Access
root_access(){
   sudo sed -i '/^auth       sufficient pam_rootok.so/ c\#auth       sufficient pam_rootok.so/' /etc/pam.d/su
}
# Disable certain services
disable_services(){
   read -p "Is Nginx authorized? (ReadME) [y/n] > " prompt
   case "$prompt" in
      y );;
      n ) sudo systemctl disable --now nginx;;
   esac
   read -p "Is FTP service authorized? (ReadME) [y/n] > " prompt
   case "$prompt" in
      y );;
      n ) sudo systemctl disable --now vsftpd;;
   esac
}
# Change system to update daily
updates_daily(){
   read -p "REMEMBER THIS!
   Configure these lines to have "1";
   `APT::Periodic::Update-Package-Lists "1";`
   `APT::Periodic::Unattended-Upgrade "1";`
   Press [Enter] to continue." placeholder
   sudo nano /etc/apt/apt.conf.d/20auto-upgrades
   wait
   sudo systemctl restart unattended-upgrades
}
# Remove unwanted apps
remove_malware_hacking(){
   # Hacking Tools
   sudo apt purge wireshark* ophcrack* nmap* -y
   # Malware
   sudo apt purge netcat* hydra* john* nikto* -y
   # Other unwanted apps
   sudo apt purge aisleriot* -y
   wait
   sudo apt autoremove -y
   wait
   sudo ss -tlnp
   read -p "Is nc.traditional (netcat) listening? [y/n] > " prompt
   case "$prompt" in
      y ) cp /etc/crontab ~/Downloads/Backups/crontab
      cp ~/Downloads/Linux/configs/crontab /etc/crontab
      wait
      sudo pkill -f nc.traditional
      which nc.traditional
      sudo rm /usr/bin/nc.traditional;;
      n );;
   esac
}
# Find media files
find_media(){
   sudo find / -type f \( -name '*.mp3' -o -name '*.mov' -o -name '*.mp4' -o -name '*.avi' -o -name '*.mpg' -o -name '*.mpeg' -o -name '*.flac' -o -name '*.m4a' -o -name '*.flv' -o -name '*.ogg' \) -print
   # More vague media should only search in home directory
   sudo find /home/* -type f \( -name '*.gif' -o -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) -print
}




# Menu
while true; do
cat << "EOF"
                       ██████████████                                      
                     ██████▒░▒▓███ ███   ███████                           
                    ████▒▒▓▓▒░░█████  ██████████████████                   
                   ███▓▒█▓▒▒▒░▒█████████ ████  ████ ██ ██                  
                   █▓▓▒▒▒▓▒▒░▒██████████████ ██  ████████                  
                   █▓▒▒▓▓▓▓▒░▒████▒▓█▓▓▓▓▓▓▓▓████████████                  
                    █▒▓▓▓░▓▒█░▓█▓▓░▓▓░░░▓▒░░░░░░▒██ ███                    
                     █▓▒░░▒▒░▒▓▓▒▒▓▓░░░░░░▒▓░░░░░░▓▓▓███                   
                            ██▒▓▓█▒░░░░░░░░░▓▓▓▓▓▓▓██████                  
                          ██▒░▒▒░░░░░░░░░░░░░▓   ███▓▓▒███                 
                         ██░░░░▓░░░░░░░░░░░░░▓█   ████████                 
                         █▒░░░░▒█▒░░░░░░░░░▓▓▒██     ███                   
                        ██▒▒░▓█  ██▓▒░░▒▓▓▓▒▒▓▓▓█                          
                        █▓█████      ██▒▒▓▓█▒░░░▒█                         
                       ███▓██▓██      ████▒▒░▒▓▓███                        
                        ███▓████    █████▓░▓████████                       
                         ██████   ███▓░▒▓░░███████████                     
                                █████▓░░░░░░░▒░░░▒██████                   
                                ███████▒░░░░░░░░░██   ███                  
                               ██▒▒▓▓░░▓███▓▓▓████    ███                  
                             ████░░░░▓███████████     ███                  
                  ██▓▓▓█████▓▓█▓░▒▒░░░░░▒▒▒▓███      ███                   
                    ██▓████▓░░▒▒████▓▒▒▒▓███        ██                     
                       █   █████████████            █████                  
                                  ██████            █████                  


░▒▓███████▓▒░░▒▓██████████████▓▒░ ░▒▓██████▓▒░       ░▒▓████████▓▒░▒▓████████▓▒░░▒▓██████▓▒░░▒▓██████████████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░         ░▒▓█▓▒░   ░▒▓██████▓▒░ ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░         ░▒▓█▓▒░   ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
                                                                                                                  
                                                                                                                  
EOF
   read -p "Select from one of the following choices:
   [1] Check for Updates
   [2] List Users and Admins
      [2.1] User Management
      [2.2] Group Management
   [3] Update Password Requirements
   [4] Configure Firewall & OpenSSH
   [5] Secure File Permissions
   [6] Disable Root Access
   [7] Disable unneccesary services
   [8] Change to check for updates daily
   [9] Remove Malware & Hacking Tools
   [10] List all media
  > " OPTION
   case "${OPTION}" in
       1 ) echo "Check for Updates \n"; update_settings;;
       2 ) echo "List Users and Admins \n"; list_users_and_admins;;
       2.1 ) echo "User Management"; user_prompt;;
       2.2 ) echo "Group Management"; group_management;;
       3 ) echo "Update Password Requirements"; update_password_req;;
       4 ) echo "Configure Firewall (UFW) \n"; config_firewall;;
       5 ) echo "Secure File Permissions"; secure_files;;
       6 ) echo "Disable Root Access"; root_access;;
       7 ) echo "Disable unneccesary services"; disable_services;;
       8 ) echo "Change to check for updates daily"; updates_daily;;
       9 ) echo "Remove Malware & Hacking Tools"; remove_malware_hacking;;
       10 ) echo "List all media"; find_media;;
   esac
   pause
   echo ""
done