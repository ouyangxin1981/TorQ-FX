# if running the kdb+tick example, change these to full paths
# some of the kdb+tick processes will change directory, and these will no longer be valid
export TORQHOME=${PWD}
export KDBCONFIG=${TORQHOME}/config
export KDBCODE=${TORQHOME}/code
export KDBLOG=${TORQHOME}/logs
export KDBHTML=${TORQHOME}/html
export KDBLIB=${TORQHOME}/lib
export KDBSTACKID="-stackid ${KDBBASEPORT}"

#Sets the application specific configuration directory
export KDBAPPCONFIG=${TORQHOME}/appconfig
#sets kdbhdb directory
export KDBHDB=${TORQHOME}/fxhdb
#set KDBBASEPORT to the default value for a TorQ Installation
export KDBBASEPORT=6000
#Create fxhdb, fxdata, proczip and csv dirctories
mkdir -p ${KDBHDB}
mkdir -p fxdata
mkdir -p proczip
mkdir -p csv
# if using the email facility, modify the library path for the email lib depending on OS
# e.g. linux:
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$KDBLIB/l[32|64]
# e.g. osx:
# export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$KDBLIB/m[32|64]
