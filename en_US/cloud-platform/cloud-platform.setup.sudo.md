# Setup sudo

## What is `sudo`

From [wikipedia](https://en.wikipedia.org/wiki/Sudo):

> sudo is a program for Unix-like computer operating systems that allows users
> to run programs with the security privileges of another user, by default the
> superuser `root`. It originally stood for "superuser do" as the older versions
> of sudo were designed to run commands only as the superuser. However, the later
> versions added support for running commands not only as the superuser but also
> as other (restricted) users, ...
>
> Unlike the similar command `su`, users must, by default, supply their own
> password for authentication, rather than the password of the target user.
> After authentication, and if the configuration file, which is typically
> located at `/etc/sudoers`, permits the user access, the system invokes the
> requested command. The configuration file offers detailed access permissions,
> including enabling commands only from the invoking terminal; requiring a
> password per user or group; requiring re-entry of a password every time or
> never requiring a password at all for a particular command line. It can also
> be configured to permit passing arguments or multiple commands.

## Setup sudo for iRedMail cloud deployment

With the iRedMail cloud platform, you can deploy iRedMail by connecting to
target server via ssh as a non-privileged user (e.g. `ubuntu`) which is allowed
to run command as `root` with `sudo`.

Let's say you're going to connect as user `ubuntu`, steps to setup sudo for
`ubuntu` user:

* Run command `visudo` as root user.

    Although you can edit sudo config file `/etc/sudoers` with your favourite
    text editor, but `visudo` will help check syntax while saving changes. this
    is helpful to avoid some mistakes like misspelled username, or any other
    keyword.

* Add lines below at the end, save your changes and quit `visudo`.

```
# Allow user `ubuntu` to run all commands without typing its own password.
ubuntu  ALL=(ALL) NOPASSWD: ALL

# We're going to connect without a real tty, below setting will speed up the
# iRedMail deployment process.
Defaults:ubuntu !requiretty
```

## References

* [sudo manual page](https://www.sudo.ws/man/1.8.3/sudo.man.html)
* [10 Useful Sudoers Configurations for Setting ‘sudo’ in Linux](https://www.tecmint.com/sudoers-configurations-for-setting-sudo-in-linux/)
* [Difference Between su and sudo and How to Configure sudo in Linux](https://www.tecmint.com/su-vs-sudo-and-how-to-configure-sudo-in-linux/)
