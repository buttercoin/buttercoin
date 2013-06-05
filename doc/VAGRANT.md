Using Vagrant
=============

Vagrant is a very useful tool for separating your development environment from your desktop environment. It utilizes virtual machines and chef to build a known development platform as required.

- Install the following prerequisites.
  - Virtualbox - https://www.virtualbox.org/wiki/Downloads
  - Vagrant - http://downloads.vagrantup.com/
- Install the following vagrant plugins to enable Chef and the very useful Berkshelf that manages Chef cookbooks

```
$ vagrant plugin install vagrant-omnibus
$ vagrant plugin install vagrant-berkshelf
```

- Clone the repository

```
$ git clone https://github.com/buttercoin/buttercoin.git
```

- Change directory to the root of the project

```
$ cd buttercoin
```

- You can then bring up the vagrant virtual machine (The first time you do this it may take quite a long time while the machine is instantiated and node.js is compiled and installed at the correct version)

```
$ vagrant up
```

- Once started you can connect to it using SSH

```
$ vagrant ssh
```

- Switch to your working directory

```
vagrant@buttercoin:~$ cd /vagrant/
```

- Install the node module dependencies within the vagrant instance to ensure platform specific stuff is built correctly

```
vagrant@buttercoin:/vagrant$ npm install
```

- If you run into issues installing dependencies from `git://` urls (corporate firewalls may block the required port) the following git command should help

```
vagrant@buttercoin:/vagrant$ git config --global url.https://github.com/.insteadOf git://github.com/
```

- Run the tests

```
vagrant@buttercoin:/vagrant$ npm test
```

- If you have a problem running the test.sh script (which happens if you check out on Windows as line endings may confuse things) the following git command should help (be warned this will also discard any local changes so run it before you make any)

```
vagrant@buttercoin:/vagrant$ git reset --hard
```

- Start the buttercoin server (this may also require the above git command to fix the scripts if they were checked out on Windows)

```
vagrant@buttercoin:/vagrant$ npm start
```

- And connect to it on the virtual machine's IP (33.33.33.50)
- You can pause, shut down or destroy the vagrant instance using the following commands in the working directory on the host

```
$ vagrant suspend
$ vagrant halt
$ vagrant destroy
```

- and bring it up again using

```
$ vagrant up
```

NB. You should perform the `npm install`, `npm start`, `npm test`, etc from within the virtual machine but edit files and use `git` on the host machine (this is particularly important if your desktop environment is Windows)
