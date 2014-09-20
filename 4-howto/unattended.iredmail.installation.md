# Perform silent/unattended iRedMail installation

iRedMail will store configrations in file iRedMail-x.y.z/config during
installation, and ask you whether to use it for installation directly
or create a new one.

You can create a sample config file by executing iRedMail installer:

```bash
# bash iRedMail.sh
```

After config wizard dialogs, you will find file `config` under iRedMail root
directory. For example, `/root/iRedMail-0.8.7/config`. it will ask whether to
start installation or not, you can cancel it if you want.

You can copy this config file to deploy as many servers as you want, change
the hard-coded passwords in it if you want.

How to deploy a new server with sample config file:

* Copy sample config file to new server, e.g. `/root/iRedMail-0.8.7/config`.
* Execute iRedMail installer with shell variables:

```bash
# AUTO_USE_EXISTING_CONFIG_FILE=y \
    AUTO_INSTALL_WITHOUT_CONFIRM=y \
    AUTO_CLEANUP_REMOVE_SENDMAIL=y \
    AUTO_CLEANUP_REMOVE_MOD_PYTHON=y \
    AUTO_CLEANUP_REPLACE_FIREWALL_RULES=y \
    AUTO_CLEANUP_RESTART_IPTABLES=y \
    AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y \
    AUTO_CLEANUP_RESTART_POSTFIX=n \
    bash iRedMail.sh
```

## Sample Deployment

Here's how i preform iRedMail tests every day with VMware Fusion on Mac OS X,
all are completed automatically with a shell command.

* Install a clean, basic/minimal OS (Debian/CentOS/OpenBSD/FreeBSD, etc), set
proper hostname, configure network, then shut down this server and create a
VMware snapshot named `Latest`. The snapshot name will be used in my shell
script, it needs a snapshot name to reverse VM to the clean OS.

* Revert VM to the latest snapshot (a clean, basic, minimal OS) with VMware
command line tool `vmrun`.

* Start this VM with `vmrun`, sleep 30 (or 60) seconds waiting for OS start up.

* Detect network connection to this VM, if it's up, upload required files with `scp`:
 * the latest development edition of iRedMail
 * source tarballs required by iRedMail (Roundcube, iRedAdmin, iRedAPD, etc)
 * downloaded RHEL/CentOS/Debian/Ubuntu/OpenBSD binary packages, FreeBSD
   distfiles etc. The most important one is a prepared iRedMail config file: iRedMail-x.y.z/config.

* Create/Update iRedMail installation status file: iRedMail-x.y.z/.status
  to skip downloading source tarballs, etc.

* Perform installation via ssh like this:

```shell
ssh root@[SERVER] "cd /root/iRedMail/ && IREDMAIL_DEBUG='NO' AUTO_USE_EXISTING_CONFIG_FILE=y AUTO_INSTALL_WITHOUT_CONFIRM=y AUTO_CLEANUP_REMOVE_SENDMAIL=y AUTO_CLEANUP_REMOVE_MOD_PYTHON=y AUTO_CLEANUP_REPLACE_FIREWALL_RULES=y AUTO_CLEANUP_RESTART_IPTABLES=y AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y AUTO_CLEANUP_RESTART_POSTFIX=n bash iRedMail.sh"
```

* Perform after-installation tasks: upload downloaded ClamAV database, ..., reboot server.

It should complete in 2-3 minutes (uploading binary packages takes most time),
then i got a working iRedMail server. I do this many times every day.

I have 5 prepared iRedMail config files for different backends: OpenLDAP,
MySQL, MariaDB, PostgreSQL, ldapd (OpenBSD only). i run my script with an
option to install iRedMail with specified backend like below, the script will
upload proper config file to server:

```shell
# bash auto.centos7.sh ldap
# bash auto.centos7.sh mysql
# bash auto.centos7.sh pgsql
# bash auto.ubuntu14.sh mariadb
# bash auto.openbsd55.sh ldapd
```

Below is file of `auto.centos7.sh` mentioned above, it prepares VMware virtual
machine, then execute another script `c7.sh` to perform the real installation.

```shell
#!/usr/bin/env bash
# File: auto.centos7.sh

[ X"$#" != X'1' ] && echo 'No backend? ldap, mysql, pgsql' && exit 255
export backend="${1}"

export VMRUN='vmrun -T fusion'
export VM_USER_ROOT='root'
export VM_HOSTNAME='c7'

export VM="/Users/zhb/vm.packages/vm/CentOS-7-x86_64.vmwarevm/CentOS-7-x86_64.vmx"

echo "* Revert to the latest snapshot."
${VMRUN} revertToSnapshot ${VM} Latest

echo "* Start VM."
${VMRUN} start ${VM}

echo "* Sleep 30 seconds to wait VM start up."
sleep 30

echo "* Detect network status with ssh."
while :; do
    ssh ${VM_USER_ROOT}@${VM_HOSTNAME} "exit"
    if [ X"$?" == X'0' ]; then
        break
    else
        sleep 5
    fi
done

echo "* Start testing iRedMail."
sh ${VM_HOSTNAME}.sh ${backend}
```

```shell
#!/usr/bin/env bash
# File: c7.sh
[ X"$#" != X'1' ] && echo 'No backend?' && exit 255
backend="${1}"
# hostname of your VMware virtual machine set in Mac OS X /etc/hosts.
HOST="c7"

echo 'copying iRedMail ...'
scp -r ~/projects/iredmail/iRedMail root@${HOST}:~ >/dev/null

echo 'copying pkgs/misc ...'
scp -r misc root@${HOST}:~/iRedMail/pkgs/ >/dev/null
scp -r config.${backend} root@${HOST}:~/iRedMail/config >/dev/null

echo 'copying archives ...'
scp -r rhel/7/yum root@${HOST}:/var/cache/ >/dev/null

echo 'updating .status ...'
ssh root@${HOST} "echo export status_check_new_iredmail='DONE' > /root/iRedMail/.status"
ssh root@${HOST} "echo export status_fetch_pkgs='DONE' >> /root/iRedMail/.status"
ssh root@${HOST} "echo export status_fetch_misc='DONE' >> /root/iRedMail/.status"
ssh root@${HOST} "echo export status_cleanup_update_clamav_signatures='DONE' >> /root/iRedMail/.status"
ssh root@${HOST} "cd /root/iRedMail/ && yum clean metadata && AUTO_USE_EXISTING_CONFIG_FILE=y AUTO_INSTALL_WITHOUT_CONFIRM=y AUTO_CLEANUP_REMOVE_SENDMAIL=y AUTO_CLEANUP_REMOVE_MOD_PYTHON=y AUTO_CLEANUP_REPLACE_FIREWALL_RULES=y AUTO_CLEANUP_RESTART_IPTABLES=y AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y AUTO_CLEANUP_RESTART_POSTFIX=n bash iRedMail.sh"
ssh root@${HOST} "/usr/bin/systemctl stop firewalld"

#ssh root@${HOST} "mkdir /root/pro && cp /var/www/iredadmin/settings.py /root/pro/"
#scp -r clamav/* root@${HOST}:/var/lib/clamav/
#ssh root@${HOST} "chown clamupdate:clamupdate /var/lib/clamav/*"
ssh root@${HOST} "echo 'reboot'; reboot"
```
