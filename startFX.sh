if [ $# -gt 0 ]; then

for i in "$@"; do


if [ "$i" = "discovery" ] || [ "$i" = "discovery1" ] || [ "$i" = "all" ]; then
	PID=$(pgrep -f "\ $KDBSTACKID \-proctype discovery \-procname discovery1")
	if [ -z "$PID" ]; then
                echo 'Starting discovery proc...'
                nohup q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/discovery.q -loaddir ${KDBAPPCODE}/common ${KDBSTACKID} -proctype discovery -procname discovery1 -U appconfig/passwords/accesslist.txt -localtime -w 20000 </dev/null >$KDBLOG/torqdiscovery.txt 2>&1 &
        fi
fi
if [ "$i" = "hdb" ] || [ "$i" = "hdb1" ] || [ "$i" = "all" ]; then
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype hdb \-procname hdb1")
	if [ -z "$PID" ]; then
                echo 'Starting hdb1...'
                nohup q ${TORQHOME}/torq.q -load ${KDBHDB} ${KDBSTACKID} -proctype hdb -procname hdb1 -loaddir ${KDBAPPCODE}/hdb ${KDBAPPCODE}/common -U appconfig/passwords/accesslist.txt -localtime -g 1 -T 60 -w 1000000 </dev/null >$KDBLOG/torqhdb1.txt 2>&1 &
        fi
fi
if [ "$i" = "hdb" ] || [ "$i" = "hdb2" ] || [ "$i" = "all" ]; then
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype hdb \-procname hdb2")
	if [ -z "$PID" ]; then
                echo 'Starting hdb2...'
                nohup q ${TORQHOME}/torq.q -load ${KDBHDB} ${KDBSTACKID} -proctype hdb -procname hdb2 -loaddir ${KDBCODE}/hdb ${KDBCODE}/common -U appconfig/passwords/accesslist.txt -localtime -g 1 -T 60 -w 1000000 </dev/null >$KDBLOG/torqhdb2.txt 2>&1 &
        fi
fi
if [ "$i" = "hdb" ] || [ "$i" = "hdb3" ] || [ "$i" = "all" ]; then
	PID=$(pgrep -f "\ $KDBSTACKID \-proctype hdb \-procname hdb3")
	if [ -z "$PID" ]; then
                echo 'Starting hdb3...'
                nohup q ${TORQHOME}/torq.q -load ${KDBHDB} ${KDBSTACKID} -proctype hdb -procname hdb3 -loaddir ${KDBAPPCODE}/hdb ${KDBAPPCODE}/common -U appconfig/passwords/accesslist.txt -localtime -g 1 -T 60 -w 1000000 </dev/null >$KDBLOG/torqhdb3.txt 2>&1 &
        fi
fi
if [ "$i" = "gateway" ] || [ "$i" = "gateway1" ] || [ "$i" = "all" ]; then
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype gateway \-procname gateway1")
	if [ -z "$PID" ]; then
                echo 'Starting gw...'
                nohup q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/gateway.q ${KDBSTACKID} -proctype gateway -procname gateway1 -loaddir ${KDBAPPCODE}/common -U appconfig/passwords/accesslist.txt -localtime -g 1 -w 20000 -T 180 </dev/null >$KDBLOG/torqgw.txt 2>&1 &
        fi
fi
if [ "$i" = "housekeeping" ] || [ "$i" = "housekeeping1" ] || [ "$i" = "all" ]; then
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype housekeeping \-procname housekeeping1")
	if [ -z "$PID" ]; then
                echo 'Starting housekeeping proc...'
                nohup q ${TORQHOME}/torq.q -load ${KDBCODE}/processes/housekeeping.q ${KDBSTACKID} -proctype housekeeping -procname housekeeping1 -loaddir ${KDBAPPCODE}/common -U appconfig/passwords/accesslist.txt -localtime -g 1 -w 50000 </dev/null >$KDBLOG/torqhousekeeping.txt 2>&1 &
        fi
fi
done
else
        echo "Script must be passed name of process"

fi
