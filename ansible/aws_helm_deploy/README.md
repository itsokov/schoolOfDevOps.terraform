Role Name
=========

Configures AWS CLI with the credentials from the machine you are deploying form. 
Installs Kubernetes and Helm on an EC2 instance and configures them to connect to a EKS cluster. 
Then proceeds to install bitnami/external-dns bitnami/wordpress helm chart.

Dependencies
------------

Depends on community.kubernetes Galaxy role

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      become: yes
      remote_user: ec2-user
      become_user: root
      roles:
        - .

License
-------

BSD

Author Information
------------------

Ivaylo Tsokov
