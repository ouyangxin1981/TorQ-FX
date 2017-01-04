
#load env script
. ./setenv.sh

# this function waits for a process to be killed for a time=timeout_limit in seconds
killWait () {
	PIDf=$1
	if [ $PIDf > /dev/null ]; then

   		kill $PIDf > /dev/null 2>&1
		
	        wait
   		counter=0
   		timeout_limit=3
   		while ( ps -p $PIDf > /dev/null ) && [ $counter -lt $timeout_limit ]; do
   			counter=`expr $counter + 1`
   			kill $PIDf > /dev/null 2>&1
			sleep 2
   		done
  
   		if ps -p $PIDf > /dev/null
   		then
      			echo "Process $PIDf did not exit"
   		else
      			echo Process Ended
   		fi
	else
 		echo Process already shut down
	fi
}


if [ $# -gt 0 ]; then

for i in "$@"; do

if [ "$i" = "discovery" ] || [ "$i" = "discovery1" ] || [ "$i" = "all" ] ; then
        echo 'Shutting down discovery...'
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype discovery \-procname discovery1")
        killWait $PID
fi
if [ "$i" = "hdb" ] || [ "$i" = "hdb1" ] || [ "$i" = "all" ]; then
        echo 'Shutting down hdb1...'
	PID=$(pgrep -f "\ $KDBSTACKID \-proctype hdb \-procname hdb1")
        killWait $PID
fi

if [ "$i" = "hdb" ] || [ "$i" = "hdb2" ] || [ "$i" = "all" ]; then
        echo 'Shutting down hdb2...'
	PID=$(pgrep -f "\ $KDBSTACKID \-proctype hdb \-procname hdb2")
        killWait $PID
fi

if [ "$i" = "hdb" ] || [ "$i" = "hdb3" ] || [ "$i" = "all" ]; then
        echo 'Shutting down hdb3...'
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype hdb \-procname hdb3")
        killWait $PID
fi

if [ "$i" = "gateway" ] || [ "$i" = "gateway1" ] || [ "$i" = "all" ]; then
        echo 'Shutting down gateway1...'
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype gateway \-procname gateway1")
        killWait $PID
fi

if [ "$i" = "housekeeping" ] || [ "$i" = "housekeeping1" ] || [ "$i" = "all" ]; then
        echo 'Shutting down housekeeping1...'
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype housekeeping \-procname housekeeping1")
        killWait $PID
fi

if [ "$i" = "filealerter" ] || [ "$i" = "filealerter1" ] || [ "$i" = "all" ]; then
        echo 'Shutting down filealerter1...'
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype filealerter \-procname filealerter1")
        killWait $PID
fi

if [ "$i" = "downloader" ] || [ "$i" = "downloader1" ] || [ "$i" = "all" ]; then
        echo 'Shutting down downloader1...'
        PID=$(pgrep -f "\ $KDBSTACKID \-proctype downloader \-procname downloader1")
        killWait $PID
fi

done

else
    echo "Script must be passed name of process"
fi
