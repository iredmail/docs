# iRedAdmin-Pro: Custom (Amavisd) ban rules
[TOC]

## Builtin ban rules

iRedMail-1.4.1 ships 4 builtin Amavisd ban rules, they're defined in
[Amavisd config file](./file.locations.html#amavisd) like below:

```
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

- `ALLOW_MS_OFFICE`: Allow all Microsoft Office documents.
- `ALLOW_MS_WORD`: Allow Microsoft Word documents (`.doc`, `.docx`).
- `ALLOW_MS_EXCEL`: Allow Microsoft Excel documents (`.xls`, `.xlsx`).
- `ALLOW_MS_PPT`: Allow Microsoft PowerPoint documents (`.ppt`, `.pptx`).

## Add new ban rules

You're free to add new ban rules inside `%banned_rules = ();` parameter.
For example, let's add new rule `BLOCK_COMPRESS` to block few compress file
formats, and `ALLOW_PDF` to allow / bypass `.pdf` files:

```
%banned_rules = (
    # ... omit other existing rules here ...

    'BLOCK_COMPRESS'    => new_RE([qr'.\.(zip|7z|gz|bz2|tar|rar)$'i]),
    'ALLOW_PDF'         => new_RE([qr'.\.pdf$'i => 0]),
)
```

Restarting Amavisd service is required after updated its config file.

If you're running iRedAdmin-Pro, please list your custom rules in its config
file `/opt/www/iredadmin/settings.py` like below, so that you can use them
in per-user, per-domain and global `Spam Policy` page.

```
# Add this parameter if it doesn't exist.
# The syntax is (Python dictionary):
# {
#   "rule-name-1": "comment-2",
#   "rule-name-2": "comment-2",
# }
AMAVISD_BAN_RULES = {
    "BLOCK_COMPRESS": "Block compressed files (zip, 7z, gz, bz2, tar, rar)",
    "ALLOW_PDF": "Allow PDF files (.pdf)
}
```

Restarting "iredadmin" service is required after updated its config file.

## How to use the ban rules

### Assign ban rules with iRedAdmin-Pro

With iRedAdmin-Pro, you can easily manage per-user, per-domain and global spam
policies, including ban rules.

- For per-user ban rules, please go to user profile page, tab "__Spam Policy__".
- For per-domain ban rules, please go to domain profile page, tab "__Spam Policy__".
- For global ban rules, please click "__System__" on main navigation bar, then
  choose "__Global Spam Policy__".

Note: per-user spam policy has the highest priority, and global one has the
lowest priority.

### Assign ban rules with SQL command line

If you already define per-user, per-domain, or global spam policy with
iRedAdmin-Pro or manually, you can now assign these ban rules to them.

For example, if you have spam policy for user `user@domain.com`, to allow
this user to accept Microsoft Word and Excel documents, you can run SQL
commands below to achieve it (Note: we use MySQL for example):

```
USE amavisd;
UPDATE policy SET banned_rulenames="ALLOW_MS_WORD,ALLOW_MS_EXCEL" WHERE policy_name="user@domain.com";
```

Multiple rule names must be separated by comma.
