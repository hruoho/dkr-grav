#!/bash
MYDIR=$1
cd /usr/share/nginx/$MYDIR && \
bash perms.sh && \
./bin/plugin login add-user -u admin -p P4ssW0rd -t Admin -e change@me.com -P b -N "Full Name" && \
bash perms.sh
