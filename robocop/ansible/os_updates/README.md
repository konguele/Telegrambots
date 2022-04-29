Role Name
=========

It is a role created to update my AlmaLinux servers, but it is valid for any server that in the Ansible facts appears as OS_Family = RedHat.

Requirements
=========

The only requirement that is needed is to be part of OS_Family = RedHat, if not, the dnf command must be edited by apt-get or if it is old and belongs to redhat, the yum command must be used.

Command Example
=========

ansible-playbook -i ../inventario/inv1 updates.yml
