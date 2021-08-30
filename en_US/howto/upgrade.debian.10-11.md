# Fixes you need after upgrading Debian from 10 to 11

[TOC]

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

## iRedAPD and iRedAdmin(-Pro)

Debian 11 offers newer Python release, few Python modules must be re-installed:

```
pip3 install -U web.py
```

Services must be restarted:

```
service iredapd restart
service iredadmin restart
```
