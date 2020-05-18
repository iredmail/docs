# Auto learn spam/ham with Dovecot `imap_sieve` plugin

[TOC]

!!! attention

    This feature is enabled by default if your iRedMail server was deployed
    with our [iRedMail Easy platform](https://www.iredmail.org/easy.html).

## Summary

Dovecot offers plugin `imap_sieve` to run sieve script for spam/virus scanning,
it's useful to let end users report spam/ham messages within webmail or MUA,
then on server side we call SpamAssassin to learn the reported messages. The
more spams/hams end users reported, the more precisely SpamAssassin can catch
the spams.

This tutorial shows you how to enable Dovecot plugin `imap_sieve` and create
required shell/sieve scripts to learn spams automatically.

After setup, you can encourage end users to report spam messages by
moving/dragging spam to `Junk` folder. With more spams reported, your iRedMail
server can precisely catch more spams.

## Requirements

- A working iRedMail server.
- Dovecot version 2.2.24 or later. `imap_sieve` plugin is available in version
  2.2.24 and later releases.
    - CentOS 7 ships Dovecot-2.2.36
    - Debian 9 ships Dovecot-2.2.27
    - Ubuntu 16.04 ships Dovecot-2.2.22 (__WARNING: Not qualified__)
    - Ubuntu 18.04 ships Dovecot-2.2.33
    - OpenBSD 6.4 ships Dovecot-2.2.36
    - FreeBSD ships Dovecot-3.x in ports tree

## Enable `imap_sieve` plugin

Please update Dovecot config file `/etc/dovecot/dovecot.conf` to:

* Enable new parameter `mail_attribute_dict` globally.
* Enable new plugin `imap_sieve` in `protocol imap {}` section.
* Add required settings for `imap_sieve` in `plugin {}` section.

```
# Store METADATA information within user's HOME directory
mail_attribute_dict = file:%Lh/dovecot-attributes

protocol imap {
    ...
    mail_plugins = ... imap_sieve
}

plugin {
    sieve_plugins = sieve_imapsieve sieve_extprograms
    imapsieve_url = sieve://127.0.0.1:4190

    # From elsewhere to Junk folder
    imapsieve_mailbox1_name = Junk
    imapsieve_mailbox1_causes = COPY APPEND
    imapsieve_mailbox1_before = file:/var/vmail/sieve/report_spam.sieve

    # From Junk folder to elsewhere
    imapsieve_mailbox2_name = *
    imapsieve_mailbox2_from = Junk
    imapsieve_mailbox2_causes = COPY
    imapsieve_mailbox2_before = file:/var/vmail/sieve/report_ham.sieve

    sieve_pipe_bin_dir = /etc/dovecot/sieve/pipe

    sieve_global_extensions = +vnd.dovecot.pipe +vnd.dovecot.environment

}
```

## Create required directories and files

We will create few directories and files used by `imap_sieve` plugin:

* Directories:
    - `/etc/dovecot/sieve/pipe`: used to store script called by `imap_sieve` plugin.
    - `/var/vmail/imapsieve_copy`: used to store reported spam/ham emails.
* Files:
    - `/var/vmail/sieve/report_spam.sieve`: used to save a copy of reported spam.
    - `/var/vmail/sieve/report_ham.sieve`: used to save a copy of reported ham.
* Shell script:
    - `/etc/dovecot/sieve/pipe/imapsieve_copy`

Create directories:

```
mkdir -p /etc/dovecot/sieve/pipe
mkdir -p /var/vmail/imapsieve_copy
chown vmail:vmail /var/vmail/imapsieve_copy
chmod 0700 /var/vmail/imapsieve_copy
```

Create file `/var/vmail/sieve/report_spam.sieve` with content below:

```
require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];

if environment :matches "imap.user" "*" {
    set "username" "${1}";
}

pipe :copy "imapsieve_copy" [ "${username}", "spam" ];
```

Create file `/var/vmail/sieve/report_ham.sieve` with content below:

```
require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];

if environment :matches "imap.mailbox" "*" {
    set "mailbox" "${1}";
}

if string "${mailbox}" "Trash" {
    stop;
}

if environment :matches "imap.user" "*" {
    set "username" "${1}";
}

pipe :copy "imapsieve_copy" [ "${username}", "ham" ];
```

Create file `/etc/dovecot/sieve/pipe/imapsieve_copy` with content below:

```
#!/usr/bin/env bash
# Author: Zhang Huangbin <zhb@iredmail.org>
# Purpose: Read full email message from stdin, and save to a local file.

# Usage: bash imapsieve_copy <email> <spam|ham> <output_base_dir>

export USER="$1"
export MSG_TYPE="$2"

export OUTPUT_BASE_DIR="/var/vmail/imapsieve_copy"
export OUTPUT_DIR="${OUTPUT_BASE_DIR}/${MSG_TYPE}"
export FILE="${OUTPUT_DIR}/${USER}-$(date +%Y%m%d%H%M%S)-${RANDOM}${RANDOM}.eml"

export OWNER="vmail"
export GROUP="vmail"

for dir in "${OUTPUT_BASE_DIR}" "${OUTPUT_DIR}"; do
    if [[ ! -d ${dir} ]]; then
        mkdir -p ${dir}
        chown ${OWNER}:${GROUP} ${dir}
        chmod 0700 ${dir}
    fi
done

cat > ${FILE} < /dev/stdin

# Logging
#export LOG='logger -p local5.info -t imapsieve_copy'
#[[ $? == 0 ]] && ${LOG} "Copied one ${MSG_TYPE} email reported by ${USER}: ${FILE}"
```

Set correct file owner and permissions:

```
chown vmail:vmail /var/vmail/sieve/report_spam.sieve \
    /var/vmail/sieve/report_ham.sieve \
    /etc/dovecot/sieve/pipe/imapsieve_copy

chmod 0700 /var/vmail/sieve/report_spam.sieve \
    /var/vmail/sieve/report_ham.sieve \
    /etc/dovecot/sieve/pipe/imapsieve_copy
```

Restart Dovecot service to enable this plugin.

```
service dovecot restart
```

## Setup cron job to scan and learn spam/ham messages

Dovecot can now save a copy of reported spam/ham automatically, we still need
a shell script to call SpamAssassin to actually learn spam/ham periodly.

Create script `/etc/dovecot/sieve/scan_reported_mails.sh` with content below,
it's used to call `sa-learn` command to learn reported spam/ham emails:

!!! attention

    If you're running FreeBSD or OpenBSD, please change the Amavisd daemon
    user name in variable `AMAVISD_USER` below.

```
#!/usr/bin/env bash
# Author: Zhang Huangbin <zhb@iredmail.org>
# Purpose: Copy spam/ham to another directory and call sa-learn to learn.

# Paths to find program.
export PATH="/bin:/usr/bin:/usr/local/bin:$PATH"

export OWNER="vmail"
export GROUP="vmail"

# The Amavisd daemon user.
# Note: on OpenBSD, it's "_vscan". On FreeBSD, it's "vscan".
export AMAVISD_USER='amavis'

# Kernel name, in upper cases.
export KERNEL_NAME="$(uname -s | tr '[a-z]' '[A-Z]')"

# A temporary lock file. should be removed after successfully examed messages.
export LOCK_FILE='/tmp/scan_reported_mails.lock'

# Logging to syslog with 'logger' command.
export LOG='logger -p local5.info -t scan_reported_mails'

# `sa-learn` command, with optional arguments.
export SA_LEARN="sa-learn -u ${AMAVISD_USER}"

# Spool directory.
# Must be owned by vmail:vmail.
export SPOOL_DIR='/var/vmail/imapsieve_copy'

# Directories which store spam and ham emails.
# These 2 should be created while setup Dovecot antispam plugin.
export SPOOL_SPAM_DIR="${SPOOL_DIR}/spam"
export SPOOL_HAM_DIR="${SPOOL_DIR}/ham"

# Directory used to store emails we're going to process.
# We will copy new spam/ham messages to these directories, scan them, then
# remove them.
export SPOOL_LEARN_SPAM_DIR="${SPOOL_DIR}/processing/spam"
export SPOOL_LEARN_HAM_DIR="${SPOOL_DIR}/processing/ham"

if [ -e ${LOCK_FILE} ]; then
    find $(dirname ${LOCK_FILE}) -maxdepth 1 -ctime 1 "$(basename ${LOCK_FILE})" >/dev/null 2>&1
    if [ X"$?" == X'0' ]; then
        rm -f ${LOCK_FILE} >/dev/null 2>&1
    else
        ${LOG} "Lock file exists (${LOCK_FILE}), abort."
        exit
    fi
fi

for dir in "${SPOOL_DIR}" "${SPOOL_LEARN_SPAM_DIR}" "${SPOOL_LEARN_HAM_DIR}"; do
    if [[ ! -d ${dir} ]]; then
        mkdir -p ${dir}
    fi

    chown ${OWNER}:${GROUP} ${dir}
    chmod 0700 ${dir}
done

# If there're a lot files, direct `mv` command may fail with error like
# `argument list too long`, so we need `find` in this case.
if [[ X"${KERNEL_NAME}" == X'OPENBSD' ]]; then
    [[ -d ${SPOOL_SPAM_DIR} ]] && find ${SPOOL_SPAM_DIR} -name '*.eml' -exec mv {} ${SPOOL_LEARN_SPAM_DIR}/ \;
    [[ -d ${SPOOL_HAM_DIR} ]]  && find ${SPOOL_HAM_DIR}  -name '*.eml' -exec mv {} ${SPOOL_LEARN_HAM_DIR}/  \;
else
    [[ -d ${SPOOL_SPAM_DIR} ]] && find ${SPOOL_SPAM_DIR} -name '*.eml' -exec mv -t ${SPOOL_LEARN_SPAM_DIR}/ {} +
    [[ -d ${SPOOL_HAM_DIR} ]]  && find ${SPOOL_HAM_DIR}  -name '*.eml' -exec mv -t ${SPOOL_LEARN_HAM_DIR}/  {} +
fi

# Try to delete empty directory, if failed, that means we have some messages to
# scan.
rmdir ${SPOOL_LEARN_SPAM_DIR} &>/dev/null
if [[ X"$?" != X'0' ]]; then
    output="$(${SA_LEARN} --spam ${SPOOL_LEARN_SPAM_DIR})"
    rm -rf ${SPOOL_LEARN_SPAM_DIR} &>/dev/null
    ${LOG} '[SPAM]' ${output}
fi

rmdir ${SPOOL_LEARN_HAM_DIR} &>/dev/null
if [[ X"$?" != X'0' ]]; then
    output="$(${SA_LEARN} --ham ${SPOOL_LEARN_HAM_DIR})"
    rm -rf ${SPOOL_LEARN_HAM_DIR} &>/dev/null
    ${LOG} '[CLEAN]' ${output}
fi

rm -f ${LOCK_FILE} &>/dev/null
```

Run command `crontab -e -u root` to setup cron job for root user, scan emails
every 10 minutes:

```
# iRedMail: Scan reported mails.
*/10   *   *   *   *   /bin/bash /etc/dovecot/sieve/scan_reported_mails.sh
```

## Tests

### Report spam: Move email from Inbox to Junk

- Login to webmail or any IMAP client like Outlook/Thunderbird.
- Move an email from `Inbox` folder to `Junk` folder.

In Dovecot log file `/var/log/dovecot/imap.log` (or `dovecot.log` if you didn't
configure syslog daemon to separate log content), you should see log lines like
below:

```
Jan 31 21:10:42 c7 dovecot: imap(<email>): sieve: pipe action: piped message to program `imapsieve_copy'
Jan 31 21:10:42 c7 dovecot: imap(<email>): sieve: left message in mailbox 'Junk'
Jan 31 21:10:42 c7 dovecot: imap(<email>): expunge: box=INBOX, uid=7, msgid=, size=7805, from=<email>, subject=<subject>
```

In the meantime, you should see an email in `/var/vmail/imapsieve_copy/spam/`,
file name in `<email>-<timestamp>-<random_number>.eml` format.

### Report ham: Move email from Junk to any other folder (except `Trash`)

If you found a clean email in `Junk` folder, just move it from `Junk` to any
other folder except `Trash`.

In Dovecot log file `/var/log/dovecot/imap.log` (or `dovecot.log`), you should
see log lines like below:

```
Jan 31 21:15:51 c7 dovecot: imap(<email>): sieve: pipe action: piped message to program `imapsieve_copy'
Jan 31 21:15:51 c7 dovecot: imap(<email>): sieve: left message in mailbox 'INBOX'
Jan 31 21:15:51 c7 dovecot: imap(<email>): expunge: box=Junk, uid=7, msgid=, size=7805, from=<email>, subject=<subject>
```

In the meantime, you should see an email in `/var/vmail/imapsieve_copy/ham/`,
file name in `<email>-<timestamp>-<random_number>.eml` format.

### Scan reported mails

It's ok to run the script manually to scan reported mails:

```
bash /etc/dovecot/sieve/scan_reported_mails.sh
```

If it scanned messages, it will log a message in `/var/log/syslog` or
`/var/log/messages` like this:

```
Jan 31 04:51:34 mail scan_reported_mails: [CLEAN] Learned tokens from 1 message(s) (1 message(s) examined)
Jan 31 05:03:16 mail scan_reported_mails: [SPAM] Learned tokens from 1 message(s) (1 message(s) examined)
```

### Check detailed bayes learning log on command line

You can either [turn on debug mode in Amavisd and SpamAssassin](./debug.amavisd.html)
to check how bayes learning works in SpamAssassin, or run `sa-learn` manually
to check it with a sample email.

To check on command line, please upload/save a sample email to
`/opt/sample.eml`, then run `sa-learn` as root user:

```
# su -s /bin/bash amavis -c "spamassassin -D bayes < /opt/sample.eml"
May 21 05:27:08.244 [32241] dbg: bayes: learner_new self=Mail::SpamAssassin::Plugin::Bayes=HASH(0x2fe8cb8), bayes_store_module=Mail::SpamAssassin::BayesStore::DBM
May 21 05:27:08.264 [32241] dbg: bayes: using username: amavis
May 21 05:27:08.264 [32241] dbg: bayes: learner_new: got store=Mail::SpamAssassin::BayesStore::DBM=HASH(0x387a1c8)
M
...
```

## Check bayes data

Run `sa-learn` as Amavisd daemon user with `--dump` argument will show the bayes data like below:

```
# su -s /bin/bash amavis -c "sa-learn --dump magic"

0.000          0          3          0  non-token data: bayes db version
0.000          0    3778575          0  non-token data: nspam
0.000          0    6326326          0  non-token data: nham
0.000          0     539978          0  non-token data: ntokens
0.000          0 1558372204          0  non-token data: oldest atime
0.000          0 1558415857          0  non-token data: newest atime
0.000          0          0          0  non-token data: last journal sync atime
0.000          0 1558415403          0  non-token data: last expiry atime
0.000          0      43200          0  non-token data: last expire atime delta
0.000          0      59325          0  non-token data: last expire reduction count
```

* `nspam` means number of learnt spams.
* `nham` means number of learnt ham/clean emails.

## See also

* [Store SpamAssassin bayes in SQL](./store.spamassassin.bayes.in.sql.html)

## References

* [Dovecot wiki: Antispam with Sieve](https://wiki.dovecot.org/HowTo/AntispamWithSieve)

    You may notice a difference between current tutorial and Dovecot wiki
    tutorial: our setup saves reported mails and scan it later with `sa-learn`
    by cron job, but setup in Dovecot wiki calls `sa-learn` directly. We make
    this change due to performance issue: when user moves a message to `Junk`
    folder, webmail will wait for `sa-learn` to finish the scan then return
    responsive, but if user moves a log messages at the same time, webmail will
    hang and user have to wait there. This is not good user experience.
