Getting started
===============

Requirements
------------

The TorQ-FX pack currently runs on Linux only, and requires kdb+ version 3.4, release date 2016.05.12 or later.

##Installation

<div style="width:640px; height:360px; margin: 0 auto;">
<iframe src="https://player.vimeo.com/video/184552498" width="640" height="360" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
</div>

</br>

The above video shows how to set up the TorQ Finance Starter Pack; the setup for the TorQ-FX pack is very similar.

The system is built on TorQ, a framework for kdb+ and may be installed as follows:

1.  Download and install the latest version of kdb+ from [Kx systems](http://kx.com) 

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

Individual processes are also started using this script, for example to start the downloader process, run

        bash startFX.sh downloader1

The pack can be stopped using the stopFX.sh script, eg

        bash stopFX.sh all

The stop script also allows processes to be stopped individually, for example to stop the downloader process, run

        bash stopFX.sh downloader1

##Connecting to a running process

The q processes the pack runs can be connected to as follows:

-   Opening a connection from another q process using hopen
-   qcon
-   an IDE

All processes are password protected, a list of usernames and passwords is in appconfig/passwords/accesslist.txt

##Downloading data

The downloader process can be set to run on startup, and will run every day at a certain time. It can also be manually called by connecting to the downloader process and running the download function, which takes a start date, an end date and a list of currency pairs as symbols as parameters.
For example, to download all data between 1st December 2016 and the current date for the currencypairs EUR/GBP, GBP/USD, EUR/USD, EUR/JPY, GBP/JPY and USD/JPY, run:

        download[2016.12.01;.z.d;`EURGBP`GBPUSD`EURUSD`EURJPY`GBPJPY`USDJPY]

The currency pairs parameter also takes `ALL as a parameter, which downloads data for all the currencypairs listed in the allcpairs parameter in appconfig/settings/downloader.q. For example, to get data for all currency pairs between 3rd September 2015 and 28th November 2016, run

        download[2015.09.03;2016.11.28;`ALL]

##Querying the HDB

Queries can be run either directly against the HDB, or through the gateway.
For example, when connected to one of the HDB processes:

       select high:max RateBid,low:min RateBid,open:first RateBid,close:last RateBid by CurrencyPair,date from gainfx where date within (2016.12.18;2016.12.23)

To run the same query through the gateway, run:

       .gw.syncexec["select high:max RateBid,low:min RateBid,open:first RateBid,close:last RateBid by CurrencyPair,date from gainfx where date within (2016.12.18;2016.12.23)";`hdb]

