The TorQ-FX pack has been built to demonstrate an example of one type of system that can be built on top of the TorQ framework. This pack will build and maintain an FX database using data from [GAIN capital](http://ratedata.gaincapital.com/).

The data consists of bid and ask prices for a range of over 70 currencies going back several years, with new data available each week. This is automatically downloaded and saved to disk where it can be loaded by 3 HDB processes, and accessed through a gateway.

Please note that this pack runs on Linux only and requires kdb+ version 3.4, release date 2016.05.12 or later.
