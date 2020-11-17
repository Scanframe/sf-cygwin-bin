# Cygwin Bash Scripts

Contains shared scripts for anyone.
Usually put in the `~/bin` directory, which is the users home directory in a cygwin bash shell.


# Installing Cygwin (Bash for windows)

## General
Cygwin is a POSIX-compatible environment that runs natively on Microsoft Windows. 
Its goal is to allow programs of Unix-like systems to be recompiled and run natively on 
Windows with minimal source code modifications by providing them with the same underlying POSIX API they would expect in those systems.

The Cygwin installation directory behaves like the root and follows a similar directory layout to that found in Unix-like 
systems, with familiar directories like /bin, /home, /etc, /usr, /var available within it, and includes by default hundreds of 
programs and command-line tools commonly found in the Unix world, plus the terminal emulator Mintty 
which is the default command-line interface tool provided to interact with the environment.

Cygwin provides native integration of Windows-based applications, data, and other system resources with applications, 
software tools, and data of the Unix-like environment. Thus it is possible to launch Windows applications from the Cygwin environment, 
as well as to use Cygwin tools and applications within the Windows operating context.

## Installing
<br/>

### Downloading

Goto the Cygwin [website](https://www.cygwin.com/ "Link to cygwin website.") and download the appropriate 32 or 64 bit version of Cygwin.

Run the Installer and install it in the default location for "all users". Use a nearby proxy for downloading the packages.

Select the following needed packages:
* wget
* openssh
* git

Missing a package for a command look it up [here](https://cygwin.com/cgi-bin2/package-grep.cgi "Cygwin Package Search").

### Configuration

**Set the cygwin users home directory to the Windows users directory**

Edit the file `/etc/nsswitch.conf` or from Windows using `C:\<cygwin-dir>\etc\nsswitch.conf` and set the line  with `db_home` as shown.

```bash
# passwd:   files db
# group:    files db
# db_enum:  cache builtin
db_home:  /cygdrive/c/Users/%u/cygwin
# db_shell: /bin/bash
# db_gecos: <empty>
```

**Clone the Git 'bin' Enzo scripts repository**

Clone the bin dirtectory using this on the cygwin command-line.

 `git clone https://git.scanframe.com/enzo/bin-bash.git ~/bin`

**Uncomment section in start script"

This next section is commented out in `.bash_profile` which need uncommenting.

```bash
# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi
```

Add this to the end of the file to enable `bash-completion` when it is installed.

```bash
# Use bash completion when installed.
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
```

**Include scripts into `.bashrc` from the `bin` repo"

This addition is needed to have your `ssh-agent` and ssh-key loaded from your `.ssh` directory.

```bash
# Include bash from Ubuntu distro.
source ~/bin/cyg-bashrc.sh

# Load the ssh-agent and default key.
source ~/bin/load-ssh-agent.sh

# Set the display for the X-server
export DISPLAY=:0.0

# set the needed environment variables for qmake and Visual Studio et cetera.
source ~/bin/set-env.sh

# Start the X-server
source ~/bin/xserver-start.sh
```

**Install additional packages from the command-line**

After a cygwin restart all script from the script repository are ineffect and packages are now easily install using the `apt-cyg` script.
To find a certain command/application for cygwin use the package finder [here](https://cygwin.com/cgi-bin2/package-grep.cgi "Pacakge search")
So installing the `killall` command you need to install the `psmisc` package like this:

```bash
apt-cyg install psmisc
```

Now install the 'needed' multiple packages to easier use :

```bash
apt-cyg install rsync bash-completion joe mc xfce4-terminal xterm bash-completion subversion
```

Type `apt-cyg` for additional options when needed.

# VcXsrv (X-server for Windows)

## Installing

### Download

Goto the sourceforge [website](https://sourceforge.net/projects/vcxsrv/ "VcXsrv Windows X Server") and download the installer.

Run the installer with all defaults.<br/>
Start the X-server using the command `xserver-start.sh` from the cygwin shell.<br/>
In the Windows system tray an X-icon mst be visible.<br/>

### Running Xfce Terminal

Install package for the `xfce4-terminal` using the following command:

 ```bash
 apt-cyg install xfce4-terminal
 ```

Then start it using the script called `terminal` and add a `&` to make it run the background.<br/>
Use `Ctrl+Shift+T` to create a terminal tab which can be controlled with  `Ctrl+PgUp` en `Ctrl+PgUp`.<br/>
To close a tab use `Ctrl+D`.

### Running Xterm

Install package for the `xterm` using the following command:

```bash
apt-cyg install xterm
```

Then start it using the script called `xterm.sh` and add a `&` to make it run the background.<br/>
And `xterm` can be run multiple times to create multiple command shells.

# Personal SSH Key

## Create a key

If you do not have a personal rsa ssh-key create one using the `ssh-keygen` application from openssh.<br/>
The option `-C` specifies the comment which is added to the key and is readable from a server which then can use it to act on it in shell scripts.<br/>

Always use add a sensible pass phrase to encrypt your key since this key allows others to access your privates and nobody else touches your privates! :)

```bash
ssh-keygen -t rsa -C <email-address>
```

The key is saved in the `~/.ssh` subdirectory using 2 files:
* id_rsa (private with pass frase encrypted key) 
* id_rsa.pub (public key for on remote systems)

Now the key is generated call `ssh-add` to add it to the already runing `ssh-agent` which was started in the `.bashrc` of cygwin.<br/>
Also when cygwin is restarted you're asked to enter your pass phrase because the `ssh-agent` automatically loads the created ssh-key.

Check if the key is loaded using `ssh-add -L`.

## Access Remote
Drop your public key on a remote system to access itr without passing a password.<br/>
When having access to a system with username and password then you can add the key to the file `~/.ssh/authorized_keys` like this.

```bash
# Open ssh session.
ssh <username>@<remote-name-or-ip>
# Add the line with the public key to the list of keys.
ssh-add -L >> .ssh/authorized_keys
```

Much shorter is:

```bash
ssh-copy-id <username>@<remote-name-or-ip>
```

This is only possible when you can login to the system using username and password. Some systems have ssh access
using usernames blocked and only allow ssh-keys for authentication.

## Notes

### Forwarding

When ssh-agent forwarding is enabled accessing another remote system from a remote system with the same key is possible.
This feature is really helpful when accessing containers with no public IP.
Add the following content to the file `~/.ssh/config`.

```conf
Host *
        ForwardAgent yes
        IdentityFile ~/.ssh/id_rsa
```	

### Port Tunneling

Ssh is also used for tunneling tcp-ip ports. 

For example a mysql at port **3306** is only accessible from localhost on a remote system for security reasons. 
To access it you can tunnel is locally using the command:

```bash
# Tunnel local port localhost:3307 to remote port localhost:3306 and run in the background.
ssh -f -N -L 0.0.0.0:3307:localhost:3306 <username>@<remote-host>
```

Now a mysql client can open a connection on the remote using localhost:3307.
