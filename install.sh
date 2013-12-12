#!/usr/bin/env bash

# If exist, delete old files. Do NOT delete local config files.
echo "Deleting old files"
rm /opt/najibnsupdate/bin/nsupdate
rm /opt/najibnsupdate/bin/nsupdate_func.sh

mkdir -p /opt/najibnsupdate/bin
ln -s ~/Github/najibnsupdate/README.txt /opt/najibnsupdate/README.txt
ln -s ~/Github/najibnsupdate/LICENSE.txt /opt/najibnsupdate/LICENSE.txt
ln -s ~/Github/najibnsupdate/bin/nsupdate /opt/najibnsupdate/bin/nsupdate
ln -s ~/Github/najibnsupdate/bin/nsupdate_func.sh /opt/najibnsupdate/bin/nsupdate_func.sh

# copy default configuration OR create blank dir/file
# do NOT replace/overwrite if already have at destination/installation directory
# just copy skeleton
cp -vR ~/Github/najibnsupdate/etc /opt/najibnsupdate/

# if not exist, create new empty log files
touch /opt/najibnsupdate/var/log/nsupdate.log
touch /opt/najibnsupdate/var/log/ip-list.txt
ln -s /opt/najibnsupdate/var/log/nsupdate.log /var/log/najibnsupdate.log
ln -s /opt/najibnsupdate/var/log/ip-list.txt /var/log/najibnsupdate-iplist.txt

# Add to schedule
#ln -s ~/Github/najibnsupdate/local/rc.local

echo "All done."
