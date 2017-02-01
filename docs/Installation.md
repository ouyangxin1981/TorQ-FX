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

The currency pairs parameter also takes `ALL as a parameter, which downloads data for all the currencypairs listed in the allcpairs parameter in appconfig/settings/downloader.q. For example, to get data for all currency pairs between 3rd September 2015 and 28th November 2016, run:

        download[2015.09.03;2016.11.28;`ALL]

The data that is downloaded is pulled down in weeks (Sunday-Friday).  If you ask to download data where the start date or end date are in the middle of a week, the downloader will download data for the whole week that contains that date unless the entered date was a Saturday. If the start date was a Saturday then it will take next day (Sunday) as the start date.  If the end date was a Saturday then it will download up to the previous day (Friday). 
For example the dates below will return data for 2017.01.01-2017.01.20.

	 download[2017.01.04;2017.01.19;`ALL]

When the download function is running you will be unable to connect to the downloader process.  If you wish to see what the downloader is doing you can tail the downloader log file as shown.  This can be useful if you wish to check if the download function is still running or if there is actually a problem connecting to the downloader process.

	tail -f out_downloader1.log

##Data Schema

The data that is downloaded from Gain Capital is tick-by-tick FX data. Each tick message will show the top of book (best bid and best ask for a currency pair at that time.
The schema for the downloaded data is as follows:

meta gainfx
c           | t f a
------------| -----
date        | d
lTid        | j
cDealable   | c
CurrencyPair| s   p
RateDateTime| p
RateBid     | f
RateAsk     | f

The date column is of type date and shows the trading date of the data.  
The lTid column is of type long and is a unique identifier that allows for speration of messages that come in with teh same timestamp.  
The cDealable column is of type char and lets you know if a trade can take place ("D" means it can trade). Sometimes Gain Capital so not wish to trade around events such as major news announcements.
The CurrencyPair column is of type sym and has a p attribute applied to it.  This column tells what currencies are being traded.
The RateDateTime column is of type timestamp and shows the date and time of tick message with precision to nano-seconds.
The RateBid column is of type float and shows the best bid at this time in the market.
The RateAsk column is of type float and shows the best ask at this time in the market.

##Querying the HDB

Queries can be run either directly against the HDB, or through the gateway. 
For example, when connected to one of the HDB processes:

       select high:max RateBid,low:min RateBid,open:first RateBid,close:last RateBid by CurrencyPair,date from gainfx where date within (2016.12.18;2016.12.23)

To run the same query through the gateway, run:

       .gw.syncexec["select high:max RateBid,low:min RateBid,open:first RateBid,close:last RateBid by CurrencyPair,date from gainfx where date within (2016.12.18;2016.12.23)";`hdb]

The suggested approach would be to use the gateway for querying.  As there are three hdb processes, the gateway will perform load balancing when a query is sent through. This allows clients to retrieve data faster than they would if they all were directly querying the same hdb process.
