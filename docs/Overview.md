##Overview#

The processes that make up the TorQ-FX pack are described below; more information on the TorQ processes can be found in the [TorQ documentation](http://aquaqanalytics.github.io/TorQ/).

##Processes#

The architecture of the system is shown in the diagram below.

![FX architecture](graphics/TorQ-FX-Arch.png)

####Downloader#
The downloader process can be set to pull market data from the Gain Capital website down into a designated directory in the system (default is fxdata). Various settings can be set for the downloader; the time the downloader function runs each day; which currency pairs it should download by default; whether to download from a specified date on startup and whether to send emails when files have been successfully downloaded.

####Filealerter#
This is a long running process periodically checking for the presence of new files in a set directory, with a default poll time of 10 seconds.  When it discovers new files it will unzip and load the data from the extracted csv file into the hdb sequentially for each new file.

####Discovery#
The discovery process is used by other processes to locate processes of interest and register their own capabilities.

####HDB#
There are three hdb processes that will be automatically updated and maintained with the data downloaded from Gain Capital.

####Gateway#
Both synchronous and asynchronous gateways are provided. The gateways may access a single process or join data across multiple processes and are also responsible for loading balancing. Additionally the gateway implements a level of resilience by hiding the failure of processes in the backend from users. The use of synchronous calls causes the gateway to block, limiting to serving one query at a time, ideally it is recommended that the gateway should only be used with asynchronous calls. Users have two options when using asynchronous calls, either block and wait for the result (deferred synchronous) or post a call back function which the gateway will call back to the user with. The process type is used to determine the servers to execute queries against in both synchronous and asynchronous cases.

####Housekeeping#
Log files on disk are maintained by the housekeeping process. Initially log files are compressed to reduce usage and stored after a set amount of time. Beyond this period log files are then removed from the log directory.
