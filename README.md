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

Check all fleet units:  
```
check-fleet-units -e http://IP:PORT
```

Check a specific fleet unit:  
```
check-fleet-units -e http://IP:PORT -u unit_name
```

Check multiple fleet units:  
```
check-fleet-units -e http://IP:PORT -u unit1,unit2,unit3
```
It should be noted that unit names will match on partial names, so if you have a
bunch of units with similar names, you can just specify a single "unit" to check.

Example:  
Assume you have the following services -
* docker-service1
* docker-service2
* docker-service3

If you want to check all of these at once without manually checking each, you can
do this:
```
check-fleet-units -e http://IP:PORT -u docker-service
```

License
---------------------
Released under the same terms as Sensu (the MIT license); see LICENSE
for details.
