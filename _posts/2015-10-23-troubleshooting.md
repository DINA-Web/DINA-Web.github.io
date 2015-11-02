---
layout: post
title: "Troubleshooting"
---

In case of DINA-Web operational emergencies... you could try to restart stuff! But first please have a read on the suggested order of actions below:

# First check health of dina-as and dina-web

Log onto `dina-as` and `dina-db` and issue these commands:

~~~
# first check uptime, did someone restart the server and check load averages
# understanding the three load average numbers is important! read on internet!
uptime

# check disks - out of space on any of the disks?
df -h

# check memory - is swap being used?
free -m

# check processes running - for heavy CPU users or memory hogs?
top
~~~

# Check logs!

Then using clues from above, check logs at system level:

~~~
# begin with the syslog but also check other logs in /var/log
sudo tailf -100 /var/log/syslog
~~~

To check logs at application level:

~~~
# go home
cd

# from there find app dir (wildfly, mean, lamp, solr etc)
# differs dep on if you are @ dina-db or dina-as
cd bitnami/[appdir]/.../log
tailf [logfile.txt]
~~~

# Do your own investigation

Please investigate based on findings above! Fix just the stuff that is broken, if possible. Really need to restart? That is unfortunate. But ok. Just restart at the "least possible level" and move up from there if required.

## Restarting one specific app

For example: you might find in a wildfly log an ERROR! This could have stopped a module from deploying properly, explaining why it doesn't appear under its regular URL, for example: https://dina-web.net/loan. Once you found the cause of the ERROR, redeploy ONLY that application using suitable command, for example: `admin@dina-as:bitnami/wildfly/bin/jboss-cli.sh --connect --command="deploy dina-loan.war"`.

Check that it works :) and let people know that the issue is resolved.

## Restarting system level services (affecting all apps)

If you need to restart the whole database, use this approach:

~~~
cd
cd bitnami/lamp/

# please try to stop the "culprit"/problematic service first
./ctlscript.sh stop mysql

# NB: you might need to kill a "hung" process, please use pkill or sudo kill -9 in worst case
# you can see which processes have started others with
ps auxf

# then start the service again
./ctlscript.sh start mysql

~~~

### Restarting mongod if there is a .lock file

If `mongod` does not start up properly it could be due to not shutting down cleanly. Verify that this is really the case...

A `.lock` file will then need to [be dealt with](http://docs.mongodb.org/manual/tutorial/recover-data-following-unexpected-shutdown/).

~~~
# load the environment for the "meanstack" which includes mongo and mongod
# log in to dina-db first

cd
cd meanstack*
use_meanstack
cd mongodb/bin
 
# save backup of corrupted database
mkdir ../data/db0
mongod --dbpath ../data/db --repair --repairpath ../data/db0

# fix corrupted mongodb inplace
rm ../data/db/mongod.lock
mongod --dbpath ../data/db --repair

# then restart the mongodb using regular bitnami ctlscript
/etc/init.d/bitnami-mean start
~~~


# Restarting full system / box

Please avoid to restart the full system if possible. If REALLY required, contact ISIT (they need to keep an eye on the boxes coming back up properly, once a box didn't come back up and ISIT had to press Yes in a console terminal on the hypervisor for the reboot to go through). 

This is how you restart the full system once you have ISIT standing by:

~~~
# please first shut down services ie see above
# ie run ./ctlscript.sh start [service-name, for example mysql, wildfly etc etc]

# dina-as
sudo /etc/init.d/bitnami-service stop && sudo shutdown -r now


# dina-db
sudo /etc/init.d/bitnami-mean stop
sudo /etc/init.d/bitnami-mysql stop
sudo /etc/init.d/bitnami-solr stop
sudo shutdown -r now
~~~

## If restarting, please remember

The `dina-db` server should restart cleanly. However, make sure to have Stefan or Lars as backups somewhere in the background when doing the restart because it COULD HANG and then it is only them that can fix the issue. 

For example at the latest restart `solr` reported error "ah00058" and this stopped the entire server from coming up. Looking into if that service incorrectly tries to load or unload a web server. Startup scripts (under /etc/init.d/bitnami-solr) has been removed, updated, reinstalled to make sure that explicitly only solr is started automatically by that script.
 
Currently, `dina-as` needs some manual overseeing. Specifically:

### Autoloading of firewall rules

This currently fails, possibly because time synch vs dc1.nrm.se is not available due to the network setup. So load manually with:

~~~
~/bin/80443.sh
~~~

### Cleaning out a Java timer

Also a java timer is not clearly removed and started "doubly" so it
would be nice to resolve that. Manually:

~~~
cd bitnami/wildfly/standalone/data/
rm -rf timer-service-data
~~~

### Check DINA apps status

Then check and possibly redeploy any Java apps that might not have deployed properly under Wildfly:

~~~
cd dina-release
more README.HOWTORELEASE.txt
# check deployment status for DINA apps with
~/bitnami/wildfly/bin/jboss-cli.sh --connect --command=deployment-info
~~~

### Flush connection

If need to flush a connectionpool (dina-web.net/naturalist needs this after dina-db restart), use:

~~~
cd bitnami/wildfly
bin/jboss-cli.sh
# then issue these commands
connect
data-source flush-all-connection-in-pool --name=NaturDS
exit
~~~

# Zombies / NOT KILLABLE

NB: High load avg can be due to processes in D state: That status of "D" is uninterruptible sleep; loadavg = (runq + uninterruptable). If you have say 3 "D" tasks, the loadavg will never drop below around 3. Indicates a failed or problematic cifs disk mount. Use:

~~~
top -b -n 1 | awk '{if (NR <=7) print; else if ($8 == "D") {print; count++} } END {print "Total status D: "count}'
~~~

Perhaps no way around a restart to get rid of unkillable zombies.
