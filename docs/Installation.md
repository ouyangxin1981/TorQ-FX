Getting started
===============

Requirements
------------

The TorQ-FX pack currently runs on Linux only, and requires kdb+ version 3.4, release date 2016.05.12 or later.

##Installation

The system is based on TorQ, a framework for kdb+ and may be installed
as follows:

1.  Download and install the latest version og kdb+ from [Kx systems](http://kx.com) 

2.  Download the main TorQ code base from [here](https://github.com/AquaQAnalytics/TorQ.git).

3.  Download TorQ-FX code base from [here](https://github.com/AquaQAnalytics/TorQ-FX.git).

4.  Unzip the TorQ package into the desired location.

5.  Extract the TorQ-FX package over the top of the main TorQ
    package.

##Configuration

There are a number of settings that can be specified before the pack is started.
The downloader process can be set to send emails when new files have been successfully downloaded. To enable this feature, email server details should be set in config/settings/default.q.
The file appconfig/settings/downloader.q contains a number of other options for the downloader process:

1. The time that the downloader process will attempt to download files each day

2. The list of currency pairs that will be downloaded by default

3. Whether the download function should be run from a certain date on startup, and what this date should be

The environment variables for the pack are located in the setenv.sh script.

##Starting the pack

Run the startFX.sh script to start the pack, eg
bash startFX.sh all

The pack can be stopped using the stopFX.sh script, eg
bash stopFX.sh all

##Connecting to a running process

The q processes the pack runs can be connected to as follows:

-   Opening a connection from another q process using hopen
-   qcon
-   an IDE

All processes are password protected, a list of usernames and passwords is in appconfig/passwords/accesslist.txt
