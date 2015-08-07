# Upgrade Dovecot from 1.1 to 1.2 on RHEL/CentOS 5.x, Debian 5.

This tutorial is for only RHEL/CentOS 5.x, Debian 5.

## Install Dovecot 1.2

### on RHEL/CentOS 5

Dovecot 1.2 is available in [another iRedMail yum repository](http://iredmail.org/yum/rpms/dovecot/), you should append below lines in `/etc/yum.repos.d/iRedMail.repo` to enable it:

```
[iRedMail-Dovecot-12]
name=iRedMail-Dovecot-12
baseurl=http://iredmail.org/yum/rpms/dovecot/rhel5/
enabled=1
gpgcheck=0
priority=1
```

Note: Because iRedMail-0.6.1 and earlier versions doesn't support dovecot-1.2, so we can't add this package in default yum repository, otherwise new installation of iRedMail (<=0.6.1) will be failed.

Remove dovecot-1.1. Be aware of below steps, we will update dovecot config based on config file of `dovecot-1.1`.

```
# cp /etc/dovecot.conf /etc/dovecot-1.1.conf
# rpm -e dovecot dovecot-sieve
warning: /etc/logrotate.d/dovecot saved as /etc/logrotate.d/dovecot.rpmsave
warning: /etc/dovecot.conf saved as /etc/dovecot.conf.rpmsave
```

Install dovecot-1.2.
```
# yum install dovecot dovecot-sieve dovecot-managesieve
# cp /etc/dovecot.conf /etc/dovecot-1.2.conf
# cp /etc/dovecot-1.1.conf /etc/dovecot.conf
```

Package `dovecot-managesieve` provides `managesieve` service, so we don't need `pysieved` anymore. Disable it:

```
# chkconfig --level 345 pysieved off
# /etc/init.d/pysieved stop
```

### on Debian 5

Append below line to `/etc/apt/sources.list`:

```
deb http://backports.debian.org/debian-backports lenny-backports main
```

Install Dovecot 1.2:
```
$ sudo apt-get -t lenny-backports update
$ sudo apt-get -t lenny-backports upgrade dovecot-imapd dovecot-pop3d
```

## Update Dovecot configure

We need to update Dovecot config file `dovecot.conf`, it's `/etc/dovecot.conf` on RHEL/CentOS, `/etc/dovecot/dovecot.conf` on Debian 5.

* Remove setting `umask =`. It wasn't really used anywhere anymore.
* Remove `zlib` from all `mail_plugins =` settings. This plugin is buggy in 1.x and will be fixed only in 2.x.
* Change sieve plugin name `cmusieve` to `sieve` in `protocol lda {}` section.
* Change `ssl_disable=no` to `ssl=yes`.

* `[For MySQL backend]` Add two more columns in `vmail.mailbox` if not present:
```
$ mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN enablesieve TINYINT(1) NOT NULL DEFAULT '1';
mysql> ALTER TABLE mailbox ADD COLUMN enablesievesecured TINYINT(1) NOT NULL DEFAULT '1';
```

* `[For RHEL/CentOS]` Append `managesieve` service related config in `dovecot.conf`:

```
# ManageSieve service. http://wiki.dovecot.org/ManageSieve
protocol managesieve {
    listen = 127.0.0.1:2000
}

# Plugin: sieve. ttp://wiki.dovecot.org/LDA/Sieve
plugin {
    #sieve_global_path =
    #sieve_global_dir = 
    #sieve_before = /var/vmail/sieve/dovecot.sieve
    #sieve_after =
    sieve = /var/vmail/sieve/%Ld/%Ln/dovecot.sieve
    sieve_dir = /var/vmail/sieve/%Ld/%Ln/
}
```

Append `managesieve` in `protocols = ` section in `dovecot.conf`, like this:

```
protocols = pop3 pop3s imap imaps managesieve
```

* `[For Debian 5 (lenny)]` In `dovecot.conf`, move `sieve =` and `sieve_storage =` from section `protocol managesieve {}` to section `plugin {}`, and rename `sieve_storage` to `sieve_dir`:

```
plugin {
    sieve = /var/vmail/sieve/%Ld/%Ln/dovecot.sieve
    sieve_dir = /var/vmail/sieve/%Ld/%Ln/
    # ... SKIP OTHER SETTINGS HERE ...
}
```

## Re-enable RoundCube sieve rules

This is needed so your users will not loose all their RoundCube sieve rules.
You need to run the following commands to mass rename the RoundCube rules and repair their links:

```
find /var/vmail/sieve/ -type l -name 'dovecot.sieve' -exec rm -f '{}' \;
find /var/vmail/sieve/ -type f -name 'roundcube' -exec rename 'roundcube' 'roundcube.sieve' '{}' \;
find /var/vmail/sieve/ -type f -name 'roundcube.sieve' -execdir ln -s '{}' dovecot.sieve \;
```
