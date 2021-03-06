// Downloader process

files:@[value;`files;`:files]					// Location of the table containing details of files already downloaded
allcpairs:@[value;`allcpairs;`EURGBP`EURJPY`EURUSD`GBPJPY`GBPUSD`USDJPY]		// List of currency pairs to download
runtime:@[value;`runtime;19:00:00]				// Time to run download function each day
initialrun:@[value;`initialrun;1b]				// Whether to download all historical data on startup
initialrunstart:@[value;`initialrunstart;2017.01.01]		// Date to start downloading from for intialrun
emailsenabled:@[value;`emailsenabled;0b]			// Whether to send emails when new files are available
emailaddresses:@[value;`emailaddresses;"test@aquaq.co.uk"]	// Email addresses to send a emails to

// Check if files table exists, if not create
$[0=count key files;[files set ([]names:();urls:();currencypair:();startdate:();size:();downloadtime:());filetab:get files;];filetab:get files]

// Function for downloading zip files for specified date range and currencypairs
download:{[startdate;enddate;currencypairs]
	if[any currencypairs=`ALL;currencypairs:allcpairs];
  // Check all the currencypairs are valid; if any aren't remove them, and if none are valid then stop the function
	if[count invalid:currencypairs where 6<>count each string currencypairs,:();
		.lg.o[`download;"Invalid currency pairs supplied: "," " sv string invalid];currencypairs:currencypairs except invalid];
	.lg.o[`download;" " sv ("Running download function for";" " sv string currencypairs,:();"between";string startdate;"and";string enddate)];
        .lg.o[`download;"Generating URLs"];
  // Data runs from 5pm on Sunday to 5pm on Friday. Files are stored on the gain capital site by the month of the monday in the week
  // sdate and edate are the Mondays in the week of startdate and enddate
  // For sdate, this week runs from Saturday to Friday, ie if the startdate is a Saturday or Sunday, sdate is the next Monday, if startdate is a weekday, sdate is the Monday of that week
  // For edate, it is similar but the week runs from Sunday to Saturday, ie if the enddate is a Sunday, edate is the next Monday, otherwise it is the previous Monday      
	sdate:$[(startdate mod 7) in 0 1;7+`week$startdate;`week$startdate];
        edate:$[0=enddate mod 7;enddate-5;1=enddate mod 7;enddate+1;`week$enddate];
  // Dates will be a list of Monday's in the daterange
  // For 2002 and before, there is one zip file for the whole year. For January 2003, there is 1 zip file for the month. All other dates should have one zip file per week 
        dates:sdate+7*til 1+`long$(edate-sdate)%7;
	dates[where dates in (2004.03.15;2004.03.22)]:2004.03.08;
	dates:distinct {$[2003>`year$x;x:"D"$(string `year$x),".01.01";2003.01m=`month$x;x:2003.01.01;x]}each dates; 
  // Convert the currencypairs to the format needed in the URLs
	cpairs:`${"_" sv (3#string x;3_string x)}each currencypairs;
  // Generate the urls
        urls:raze `${$[2007=`year$x;x:x+4;x within (2005.04.04;2005.04.25);x:x+4;(`month$x) in (2006.10m;2006.11m);x;(`month$x) in (2004.06m;2004.07m;2003.12m;2004.01m);x:x+2;2009.05.01>x;x:x+3;x];
		$[2003>`year$x;"http://ratedata.gaincapital.com/",(string `year$x),"/",(string y),"_",(string `year$x),".zip";
		"/" sv ("http://ratedata.gaincapital.com";string `year$x;
               raze (1_string 100+`mm$x;"%20";("January";"February";"March";"April";"May";"June";"July";"August";"September";"October";"November";"December") -1+`mm$x);
                raze (string y;
			$[2003.01m=`month$x;"";x within (2004.03.08;2004.03.26);"_Week2-4";2009.05.01>x;"_Week",first string 1+(-1+`dd$x) div 7;"_Week",first string 1+(`dd$x) div 7]
				;".zip"))]}'[;cpairs]each dates;
	ndates:asc (count urls)#dates;
  // Generate the names each file will be saved as
	names:hsym `$({getenv[`KDBZIP],"/",((7#last "/" vs x) except "_")}each string urls),'{raze ("." vs x),".zip"}each string ndates;
        .lg.o[`download;"Downloading files"];
  // Count number of rows in files table before download
	scount:count filetab;
  // Download any available files not already downloaded in the date range      
	{$[not x in filetab[`names];
                [.lg.o[`download;"Downloading ",1_string y];
			.[{x 1:.Q.hg y};(x;y);{[y;e].lg.e[`download;"Download failed for file ",string[y],": ",e];'}[y]];
			$[0=count key x;.lg.e[`download;1_(string y)," failed to download"];
				2000<hcount x;[`filetab upsert (x;y;6#-18#string x;8#-12#string x;hcount x;.proc.cp[]);.lg.o[`download;1_(string y)," downloaded successfully"]];
					[hdel x;.lg.o[`download;1_(string y)," is empty, file deleted"]]]];
			.lg.o[`download;1_(string y)," has already been downloaded"]]}'[names;hsym urls];
  // Count the number of rows in the file table after download	
	ecount:count filetab;
        .lg.o[`download;"Finished downloading"];
  // Check if new files have been downloaded, if there are new files, send an email to a list of users 
	if[1b=emailsenabled;$[ecount>scount;[newfiles::(neg ecount-scount)#filetab;
		.email.senddefault[`to`subject`body!(`$emailaddresses;"New FX files available";
		("Data for the following is now avaialble:";"; " sv {(x," for weeks beginning ",y)}'[key exec startdate by currencypair from newfiles;
			{", " sv x}each value exec startdate by currencypair from newfiles]))]
		];]];
  // Write the updates to the filetab table to disk
	files upsert (neg ecount-scount)#filetab;
        }


// Download all historical data if initialrun enabled
if[1b=initialrun;download[initialrunstart;.z.d;`ALL]]

// Run the download function with the current date at a specified time each day
dailydownload:{download[.proc.cd[]-30;.proc.cd[];`ALL]}
.timer.rep[.proc.cd[]+runtime;0W;1D;(`dailydownload`);0h;"Download function";0b]
