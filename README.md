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
software tools, and data of the Unix-like environment. Thus, it is possible to launch Windows applications from the Cygwin environment,
as well as to use Cygwin tools and applications within the Windows operating context.

## Install using a Powershell Script

### Single Command

The PowerShell script can be downloaded and executed using a single command.

> **Note**: Execute script as a normal user. 

From GitHub.

```cmd
powershell -Command "Invoke-Expression(Invoke-WebRequest 'https://raw.githubusercontent.com/Scanframe/sf-cygwin-bin/master/install-cygwin.ps1').Content"
```

From Windows file server address.

```cmd
powershell -Command "Invoke-Expression (Get-Content -raw '\\canberra\userdata\source\cygwin-bin\install-cygwin.ps1')"
```

### Download script & run-it 

Download the PowerShell script **[install-cygwin.ps1](/Scanframe/sf-cygwin-bin/blob/master/install-cygwin.ps1 "Link to script repository location.")**
and run it like this from the command line using `cmd.exe` console.

```powershell
powershell -ExecutionPolicy ByPass -File install-cygwin.ps1
```

> **Note**: Execute script as a normal user.

### What does it do?

What it does:

* Installs Windows multi-tab terminal.
* Download the Cygwin installer.
* Install Cygwin and additional packages.
* Configure the `%USERPROFILE%\cygwin` directory as the home directory for Cygwin Bash.
* Clone this repository as the `~/bin` directory.
* Copying `.bash_profile` and `.bashrc` from this repo into the home directory.

What it does NOT do:

* Configure the multi-tab terminal for Windows using Cygwin.
* Generate an SSH key.

## Install Manually

### Using WinGet Package Manager

Simple from the command-line.

```shell
winget install --exact --id Cygwin.Cygwin
```

> Seems to be broken on a faulty hash (2023-12-01).  
> In the mean-time download it manually.

### By Downloading

Goto the Cygwin [website](https://www.cygwin.com/ "Link to cygwin website.") and download 64 bit version of Cygwin.
Run the Cygwin **Setup** executable from a dedicated directory like `C:\Users\<home-dir>\lib\Cygwin-Setup` since it stores cached files
in the same directory. The setup could be run multiple times to install additional packages.
Run the Installer and install it in the default location (`C:\cygwin64`) for all users.
Use a nearby proxy for fast downloading the packages.

Select the following initial needed packages using the Setup application:

* git
* wget
* openssh
* bash-completion
* psmisc
* procps
* jq
* libproc2-0
* joe
* mc
* xorg-server
* xterm

Missing a package for a command look it up [here](https://cygwin.com/cgi-bin2/package-grep.cgi "Cygwin Package Search").

### Configuration

**Set the cygwin users home directory to the Windows users directory**

Edit the file `/etc/nsswitch.conf` or from Windows using `C:\<cygwin-dir>\etc\nsswitch.conf` and set the line with `db_home` as shown.

```bash
# passwd:   files db
# group:    files db
# db_enum:  cache builtin
db_home:  /cygdrive/c/Users/%u/cygwin
# db_shell: /bin/bash
# db_gecos: <empty>
```

**Clone the Git 'bin-bash' shared scripts repository**

Clone the bin directory using this on the cygwin command-line.

```bash
git clone https://github.com/Scanframe/sf-cygwin-bin ~/bin
```

**Copy Files**

Copy the next 2 files to the home directory.

* `~/bin/.bash_profile`
* `~/bin/.bashrc`

```bash
cp "${HOME}/bin/"{.bash_profile,.bashrc} "${HOME}/"
```

**Install additional packages from the command-line**

After a Cygwin restart all script from the script repository are in effect and packages are now easily install using the `apt-cyg` script.
To find a certain command/application for cygwin use the package finder [here](https://cygwin.com/cgi-bin2/package-grep.cgi "Pacakge search")
So installing the `killall` command you need to install the `psmisc` package like this:

```bash
apt-cyg install psmisc procps-ng
```

Now install the 'needed' multiple packages to easier use :

```bash
apt-cyg install rsync bash-completion joe mc bash-completion subversion
```

Type `apt-cyg` for additional options when needed.

> **Note**  
> Latest Cygwin version the `apt-cyg` script does not install all library dependencies somehow.
> So run the Cygwin Setup again.

## Multi-Tab Terminal Application

Install the multi-tab terminal which is a convenient way to have multiple terminals in a single window/application.

```shell
winget install --exact --id Microsoft.WindowsTerminal
```

Configure the tab by opening the bat-file `C:\cygwin64\Cygwin.bat` and use icon file `C:\cygwin64\Cygwin-Terminal.ico`.

## VcXsrv (Optional X-server for Windows)

> This is an alternative to the Cygwin package `xorg-server`.

## Installing

### Download

Goto the sourceforge [website](https://sourceforge.net/projects/vcxsrv/ "VcXsrv Windows X Server") and download the installer.

Run the installer with all defaults.<br/>
Start the X-server using the command `xserver-start.sh` from the cygwin shell.<br/>
In the Windows system tray an X-icon mst be visible.<br/>

### Additional Terminal Window

Call the `terminal` to open a secondary Cygwin terminal from an existing terminal.

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

### Use X-Server from VirtualBox VM

The `xssh` will find the host only adapter IP-address to pass in the `DISPLAY` environment variable to the bash shell.

```bash
# Run the ssh command passing the DISPLAY environment variable.
ssh $* -t "DISPLAY=${IP_HOST_ONLY}:0.0 /bin/bash -c 'source ~/.profile && /bin/bash'"
```

To connect to the virtual machine VM use `xssh` like `xssh user@linux-vm-ip`.  
To make it easier to remember which IP for which virtual machine edit the `/etc/hosts`
file from within the Cygwin terminal.  
The `sudo` command will use the elevation function from Windows.

```bash
sudo joe /etc/hosts
```
