# Upgrade iRedMail from 1.4.0 to 1.4.1

[TOC]

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Jul 23, 2021: initial draft document.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.4.1
```

### Amavisd: Add some useful ban rules

Microsoft Office documents are banned with iRedMail default settings, but it's
common that some mailbox may need to receive such documents.

Here we define some ban rules to allow these Office document types, iRedMail
server admin can update per-user spam policy to allow receiving such documents.

- Update Amavisd config file and append these lines before the last line (`1;`):
    - on RHEL/CentOS/Rocky Linux, it's `/etc/amavisd/amavisd.conf`.
    - on Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`.
    - on FreeBSD, it's `/usr/local/etc/amavisd.conf`.
    - on OpenBSD, it's `/etc/amavisd/amavisd.conf`.

```
# Define some useful rules.
%banned_rules = (
    # Allow all Microsoft Office documents.
    'ALLOW_MS_OFFICE'   => new_RE([qr'.\.(doc|docx|xls|xlsx|ppt|pptx)$'i => 0]),

    # Allow Microsoft Word, Excel, PowerPoint documents separately.
    'ALLOW_MS_WORD'     => new_RE([qr'.\.(doc|docx)$'i => 0]),
    'ALLOW_MS_EXCEL'    => new_RE([qr'.\.(xls|xlsx)$'i => 0]),
    'ALLOW_MS_PPT'      => new_RE([qr'.\.(ppt|pptx)$'i => 0]),

    # Default rule.
    'DEFAULT' => $banned_filename_re,
);
```

- Restarting Amavisd service is required.

Here we defines 5 ban rules:

- `ALLOW_MS_OFFICE`: Allow all documents whose file name ends with any of
  `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`.
- `ALLOW_MS_WORD`: Allow just Microsoft Word documents (`.doc`, `.docx`).
- `ALLOW_MS_EXCEL`: Allow just Microsoft Excel documents (`.xls`, `.xlsx`).
- `ALLOW_MS_PPT`: Allow just Microsoft PowerPoint documents (`.ppt`, `.pptx`).
- `DEFAULT`: use the default ban rule defined in `$banned_filename_re`.

You're free to define more ban rules to fit your own needs.

!!! attention

    #### Example: How to use these ban rules

    If you already define per-user, per-domain, or global spam policy with
    iRedAdmin-Pro or manually, you can now assign these ban rules to them.

    For example, if you have spam policy for user `user@domain.com`, to allow
    this user to accept Microsoft Word and Excel documents, you can run SQL
    commands below to achieve it (Note: we use MySQL for example):

        USE amavisd;
        UPDATE policy SET banned_rulenames="ALLOW_MS_WORD,ALLOW_MS_EXCEL" WHERE policy_name="user@domain.com";
