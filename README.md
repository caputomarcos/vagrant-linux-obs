# Oracle WebLogic Server 11gR1 (10.3.6) + OSB 11gR1 (11.1.1.7.0)  on Ubuntu 12.04 using Vagrant

This project enables you to install Weblogic with OSB in a virtual machine running
Ubuntu 12.04, using [Vagrant] and [Puppet].

## Requirements

* [Vagrant] and [VirtualBox] installed.
* At least 4 GB of RAM.

## Installation

* Clone this project:

        $ git clone https://github.com/kgrodzicki/vagrant-ubuntu-osb.git

* Install [vbguest]:

        $ vagrant plugin install vagrant-vbguest

* Download [Oracle WebLogic Server 11gR1 (10.3.6) + Coherence - Package Installer]. Place the file
  `wls1036_generic.jar` in the directory `modules/oracle/files`
  of this project.

* Download [Oracle Service Bus (11.1.1.7.0)]. Place the file
  `ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip` in the directory `modules/oracle/files`
  of this project.

* Run `vagrant up` from the base directory of this project. It takes a while..

* Simple 'localDomain' is not installed by puppet automatically. To do so run commands:
  
        $ vagrant ssh
        $ /tmp/install_domain.sh

* To run weblogic server run command:
  
        $ oracle/user_projects/domains/localDomain/startWebLogic.sh

Start browser from host machine: [http://localhost:7001/sbconsole]. User 'weblogic', password 'weblogic1'.

## Troubleshooting
Sometimes installation of domain fails at the first time. In that case run install_domain.sh more than one time :)

[Vagrant]: http://www.vagrantup.com/

[VirtualBox]: https://www.virtualbox.org/

[Puppet]: http://puppetlabs.com/

[Oracle WebLogic Server 11gR1 (10.3.6) + Coherence - Package Installer]: http://www.oracle.com/technetwork/middleware/service-bus/downloads/index.html

[Oracle Service Bus (11.1.1.7.0)]: http://www.oracle.com/technetwork/middleware/service-bus/downloads/index.html

[vbguest]: https://github.com/dotless-de/vagrant-vbguest

[http://localhost:7001/sbconsole]: http://localhost:7001/sbconsole
