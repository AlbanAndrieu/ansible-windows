ansible-windows
====================

A role for installing windows.

[![Build Status](https://api.travis-ci.org/AlbanAndrieu/ansible-windows.png?branch=master)](https://travis-ci.org/AlbanAndrieu/ansible-windows)
[![Galaxy](http://img.shields.io/badge/galaxy-windows-blue.svg?style=flat-square)](https://galaxy.ansible.com/list#/roles/1994)
[![Tag](http://img.shields.io/github/tag/AlbanAndrieu/ansible-windows.svg?style=flat-square)]()

## Actions

- This is a sample. It sinply test hat windows can be reached fron Ansible

Usage example
------------

    - name: Install windows
      connection: local  
      hosts: windows
      remote_user: albandri
      roles:
        - role: windows           
        
Requirements
------------

none

Dependencies
------------

https://github.com/AlbanAndrieu/ansible-vagrant-role.git

License
-------

MIT

#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/AlbanAndrieu/ansible-windows/issues)!
