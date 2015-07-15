sensu-plugins-fleet
===============================

Functionality
-------------------------

Queries fleet for the status of all units. Returns the name of the service
and IP of each unit it finds inactive.  

Files
---------------------
* bin/check-fleet-units.rb

Usage
---------------------
```
check-fleet-units -e http://IP:PORT
```

License
---------------------
Released under the same terms as Sensu (the MIT license); see LICENSE
for details.
