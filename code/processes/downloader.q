// Downloader process

files:@[value;`files;`:files]					// Location of the table containing details of files already downloaded
allcpairs:@[value;`allcpairs;`AUDCAD`AUDCHF`AUDJPY]		// List of currency pairs to download
runtime:@[value;`runtime;17:00:00]				// Time to run download function each day
initialrun:@[value;`initialrun;0b]				// Whether to download all historical data on startup
initialrunstart:@[value;`initialrunstart;2016.11.21]		// Date to start downloading from for intialrun


// Check kdb version is recent enough to use .Q.hg
$[.z.K<3.4;[.lg.e[`version;"Need version 3.4, 2016.05.12 or later"];exit 1];
	.z.k>2016.05.12;();[.lg.e[`version;"Need version 3.4, 2016.05.12 or later"];exit 1]]

// Check if files table exists, if not create
$[0=count key files;[files set ([]names:();urls:();size:();downloadtime:());filetab:get files;];[filetab:get files;]]

// Function for downloading zip files for specified date range and currencypairs
download:{[startdate;enddate;currencypairs]
	if[any currencypairs=`ALL;currencypairs:allcpairs];
  // Check all the currencypairs are valid; if any aren't remove them, and if none are valid then stop the function
	$[1<count currencypairs;[cpairs1:currencypairs where 6=count each string currencypairs;
		if[0<count currencypairs where 6<>count each string currencypairs;
			{.lg.o[`download;raze string x," is not a valid currencypair"]}each currencypairs where 6<>count each string currencypairs]];
                6=count string currencypairs;cpairs1:currencypairs;[cpairs1:();.lg.o[`download;raze string currencypairs," is not a valid currency pair"]]];
	if[0=count cpairs1;.lg.e[`download;"No valid currencypairs; function will stop"];'`NoCurrencyPairs];
	.lg.o[`download;" " sv ("Running download function for";
		$[1=count cpairs1;string first cpairs1;", " sv string cpairs1];"between";string startdate;"and";string enddate)];
        .lg.o[`download;"Generating URLs"];
  // Data runs from 5pm on Sunday to 5pm on Friday. Files are stored on the gain capital site by the month of the monday in the week
  // sdate will be the Monday of the week of the startdate, edate will be the Monday of the week containing the enddate
  // So if the startdate is a Saturday or Sunday, sdate will be the following Monday; for Tuesday to Friday, sdate will be the previous Monday
  // For edate it is the same except that if the enddate is a Saturday, edate will be the previous Monday      
	sdate:$[(startdate mod 7) in 0 1;7+`week$startdate;`week$startdate];
        edate:$[0=enddate mod 7;enddate-5;1=enddate mod 7;enddate+1;`week$enddate];
  // Dates will be a list of Monday's in the daterange 
        dates:{x+7}\[`long$(edate-sdate)%7;sdate];
  // Convert the currencypairs to the format needed in the URLs
	cpairs:`${"_" sv (3#string x;3_string x;"Week")}each cpairs1;
        urls:raze `${"/" sv ("http://ratedata.gaincapital.com";string `year$x;
               raze (1_string 100+`mm$x;"%20";("January";"February";"March";"April";"May";"June";"July";"August";"September";"October";"November";"December") -1+`mm$x);
                raze (string y;first string 1+(`dd$x) div 7;".zip"))}'[;cpairs]each dates;
	ndates:asc (count urls)#dates;
  // Generate the names each file will be saved as      
	names:hsym `$({(-7#-10_x) except "_"}each string urls),'{raze ("." vs x),".zip"}each string ndates;
        .lg.o[`download;"Downloading files"];
  // Count number of rows in files table before download
	scount:count filetab;
  // Download any available files not already downloaded in the date range      
	{$[not x in filetab[`names];
                [.lg.o[`download;"Downloading ",1_string x];
			.[{x 1:.Q.hg y};(x;y);{[x;y;e].lg.e[`download;"Remote service unavailable"];'}[x;y]];
			$[0=count key x;.lg.e[`download;1_(string x)," failed to download"];
				2000<hcount x;[`filetab upsert (x;y;hcount x;.proc.cp[]);.lg.o[`download;1_(string x)," downloaded successfully"]];
					[hdel x;.lg.o[`download;1_(string x)," is empty, file deleted"]]]];
			.lg.o[`download;1_(string x)," has already been downloaded"]]}'[names;hsym urls];
  // Count the number of rows in the file table after download	
	ecount:count filetab;
        .lg.o[`download;"Finished downloading"];
  // Check if new files have been downloaded, if there are new files, send an email to a list of users 
	$[ecount>scount;[newfiles::(neg ecount-scount)#filetab[`names];
		// .email.senddefault[`to`subject`body!(`$"test@aquaq.co.uk";"New FX files available";("The following files are now available:";string newfiles))]
		];];
  // Write the updates to the filetab table to disk
	files upsert (neg ecount-scount)#filetab;
        }


// Download all historical data if initialrun enabled
if[1b=initialrun;download[initialrunstart;.z.d;`ALL]]

// Run the download function with the current date at a specified time each day
.timer.rep[.proc.cd[]+runtime;0W;1D;(`download;.proc.cd[];.proc.cd[];`ALL);0h;"Download function";0b]
