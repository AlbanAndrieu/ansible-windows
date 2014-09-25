ansible-windows
====================

A role for installing windows.

[![Build Status](https://api.travis-ci.org/AlbanAndrieu/ansible-windows.png?branch=master)](https://travis-ci.org/AlbanAndrieu/ansible-windows)

## Actions

- Ensures that windows is installed

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

none

License
-------

MIT

#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/AlbanAndrieu/ansible-windows/issues)!
