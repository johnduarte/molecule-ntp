Role Name
=========

This is a simple test repo using the [molecule framework](https://molecule.readthedocs.io/en/latest/)
for deploying system state via [ansible](https://www.ansible.com/)
and validating that state using
[infratest](https://testinfra.readthedocs.io/en/latest/).

Requirements
------------

The following packages should be installed via pip in order to run molecule.
In order to isolate the dependencies, it is recommended that you use a python
virtualenv. However, such a virtualenv _must_ be located outside of the
directory structure of this repo or the ansible linter will attempt to verify
the dynamic yaml inside of core ansible and fail spectacularly because the
entire virtualenv directory will be in scope for lint inspection.

Here are the basic steps to get started with this repo:
```
cd /path/where/the/repo/will/be/cloned/to
virtualenv --python python2 venv-molecule
. venv-molecule/bin/activate
pip install molecule testinfra ansible docker-py
git clone git@github.com:johnduarte/molecule-ntp
cd molecule-ntp
molecule test
```

This branch uses the `delegated` driver. You must ensure that your ssh
configuration is setup to connect to the SUT, that you have an ssh-agent
running, and that the key for the SUT has been added to the running agent.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: molecule-ntp, x: 42 }

Generate Molecule Config from Ansible Dynamic Inventory
-------------------------------------------------------

The `moleculerize.py` script will build molecule config files from a RPC-O Ansible dynamic inventory file. As a
prerequisite to using the `moleculerize.py` script a dynamic inventory must be generated from a RPC-O build:

```
sudo su -
cd /opt/openstack-ansible/playbooks/inventory
./dynamic_inventory.py > /path/to/dynaic_inventory.json
```

Now you can generate a `molecule.yml` config file using the `moleculerize.py` script:

```
cd /path/to/molecule-ntp
./moleculerize.py /path/to/dynaic_inventory.json
```

The above command assumes that the `templates/molecule.yml.j2` template will be used along with `molecule.yml` as 
the output file.

License
-------

Apache

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
