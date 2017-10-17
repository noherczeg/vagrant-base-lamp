Vagrant Sample Box
============

Requirements
------------
* VirtualBox <http://www.virtualbox.org>
* Vagrant <http://www.vagrantup.com>

Usage
-----

### Configuration
Database scripts can be placed under the `./provision-sql` folder. Vagrant will run all files under it 
in the order they appear in the folder.

The server and application configurations are available under the `./provision-files` folder.

### Startup
```
$ vagrant up
```

### Connecting

#### SSH
```
$ vagrant ssh
```

#### Apache
The Apache server is available at <http://localhost:8888>

#### MySQL
Externally the MySQL server is available at port `8889`, and when running on the VM it is available as a socket or at port `3306` as usual.
Username: root
Password: root

Sample DataBase: mysql

### Running commands in the guest
As usual, you can run commands from the host which are ran inside the guest. You only need to feed Vagrant's ssh command.

```
$ vagrant ssh -c 'composer about'
```

Technical Details
-----------------
* Ubuntu 16.04 64-bit
* Apache 2.4
* PHP 5.6
* MySQL 5.7
* XDebug
* Composer

The web root is located in the project directory at `src/` and you can install your files there
