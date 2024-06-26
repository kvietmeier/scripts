###====================================================================###
# OpenSSH configuration file for Windows 10/11
#   - Will work with Linux/OS X as well - but ncat won't be required for SOCKS.
#
# https://www.ssh.com/academy/ssh/config
#  
#  To use a SOCKs Proxy w/Windows:
#  - Install nmap
#  -> Due to a bug in ncat 7.9# you will need to install 7.80 instead.
#  -> You will also need the whole nmap install otherwise you will be missing
#     libraries.
#   https://nmap.org/
#   https://nmap.org/dist
#
#   Installer for 7.8
#   https://nmap.org/dist/nmap-7.80-setup.exe
#
#
#   To use:
#    * rename "config"
#    * copy to <user>/.ssh
#
###====================================================================###

###--- Local/Home Lab Systems
Host mariner01
    HostName 192.168.1.12
    User karlv
    PasswordAuthentication no


###--- RHEL Lab server - need to specific MAC
###   IdentityFile is there for example
Host sedjump
    HostName 192.55.51.202
    User dvuser94
    #MACs hmac-sha2-512   # Put in Host*
    IdentityFile C:\Users\ksvietme\.ssh\newrsakey
    PasswordAuthentication no


###--- tandaloor VMs
###======================  WestUS2 ========================###
Host loadgen
    HostName labnode1098.westus2.cloudapp.tandaloor.com
    User tandalooruser
    PasswordAuthentication yes

Host tools
    HostName kv-linuxtools.westus2.cloudapp.tandaloor.com
    User tandalooruser
    PasswordAuthentication yes



#--- Linux Testing Nodes
Host linux01
    HostName linux-kv01.westus2.cloudapp.tandaloor.com
    User tandalooruser
    PasswordAuthentication yes

Host linux02
    HostName linux-kv02.westus2.cloudapp.tandaloor.com
    User tandalooruser
    PasswordAuthentication yes

Host linux03
    HostName linux-kv03.westus2.cloudapp.tandaloor.com
    User tandalooruser
    PasswordAuthentication yes

Host linux04
    HostName linux-kv04.westus2.cloudapp.tandaloor.com
    User tandalooruser
    PasswordAuthentication yes


#--- IaaS cluster built with Terraform
Host mgmt01
    HostName mgmt01-ksv.westus2.cloudapp.tandaloor.com
    User ubuntu

Host dbase01
    HostName dbase01-ksv.westus2.cloudapp.tandaloor.com
    User ubuntu

Host dbase02
    HostName dbase02-ksv.westus2.cloudapp.tandaloor.com
    User ubuntu

Host dbase03
    HostName dbase03-ksv.westus2.cloudapp.tandaloor.com
    User ubuntu

Host dbase04
    HostName dbase04-ksv.westus2.cloudapp.tandaloor.com
    User ubuntu

Host dbase05
    HostName dbase0r-ksv.westus2.cloudapp.tandaloor.com
    User ubuntu



###=====================================================================================###
###              Entries using ncat to tunnel through a SOCKS proxy
###=====================================================================================###

Host ptools
    HostName kv-linuxtools.westus2.cloudapp.tandaloor.com
    ProxyCommand "C:\Program Files (x86)\nmap\ncat.exe" --proxy-type socks5 --proxy proxy-us.intel.com:1080 %h %p
    User tandalooruser
    PasswordAuthentication no
  

### ================================================================================###
#                         Common Settings for all SSH targets                         #
### ================================================================================###

Host *
  # Effect is to not populate the known_hosts file every time you connect to a new server
  UserKnownHostsFile /dev/null
  # Don't verify that the the key matches a known_host - useful when you rebuild hosts frequently
  StrictHostKeyChecking no
  IdentitiesOnly no
  LogLevel FATAL
  ForwardX11 yes
  ForwardAgent yes
  # Sends packets to keep sessions open - 
  TCPKeepAlive yes
  # Send a null packet every 60s - override server side settings
  ServerAliveInterval 60
  # Send them for 48hrs (60*2880) - 24hrs = 86,400s
  ServerAliveCountMax 2880
  # Need this for some sshd servers.
  MACs hmac-sha2-512