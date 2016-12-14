files:`:files			//Location of the table containing details of files already downloaded
allcpairs:`AUDCAD`AUDCHF`AUDJPY		//List of currency pairs to download
runtime:17:09:30		//Time to run download function each day
initialrun:0b			//Whether to download all historical data on startup

lg:{-1(string .z.p)," ",x}
// $[.z.K<3.4;{-2 "Error: Need version 3.4 or later";exit 1}[];.z.k>2016.05.12;;{-2 "Error: Need release date 2016.05.12 or later";exit 1}[]]
$[.z.K<3.4;{.lg.e[`version;"Need version 3.4 or later"];exit 1}[];.z.k>2016.05.12;;{.lg.e[`version;"Error: Need release date 2016.05.12 or later"];exit 1}[]]

download:{[startdate;enddate;currencypairs]
        .lg.o[`download;"Generating URLs"]
  // Data runs from 5pm on Sunday to 5pm on Friday. Files are stored on the gain capital site by the month of the monday in the week      
	sdate:$[not (startdate mod 7) in (0;1);{x-1}/[{2<x mod 7};startdate];{x+1}/[{2>x mod 7};startdate]];
        edate:$[0=(enddate mod 7);enddate-5;not (enddate mod 7)=1;{x-1}/[{2<x mod 7};enddate];{x+1}/[{2>x mod 7};enddate]];
        dates:{x+7}\[`long$(edate-sdate)%7;sdate];
	cpairs:$[any currencypairs=`ALL;`${"_" sv (3#string x;3_string x;"Week")}each allcpairs;`${"_" sv (3#string x;3_string x;"Week")}each currencypairs];
        urls:raze `${"/" sv ("http://ratedata.gaincapital.com";string `year$x;
               raze (1_string 100+`mm$x;"%20";("January";"February";"March";"April";"May";"June";"July";"August";"September";"October";"November";"December") -1+`mm$x);
                raze (string y;first string $[7>`dd$x;1;14>`dd$x;2;21>`dd$x;3;28>`dd$x;4;5];".zip"))}/:[;cpairs]each dates;
	ndates:asc (count urls)#dates;
  // Generate the names each file will be saved as      
	names:hsym `$({(-7#-10_x) except "_"}each string urls),'{raze ("." vs x),".zip"}each string ndates;
        .lg.o[`download;"Downloading files"]
  // Check if files table exists; if not, create      
	if[0=count key files;files set ([]names:();urls:();size:();downloadtime:())];
	scount:count get files;
  // Download any available files not already downloaded in the date range      
	{if[not x in (get files)[`names];
                .lg.o[`download;"Downloading ",1_string x];x 1:.Q.hg y;$[2000<hcount x;files upsert (x;y;hcount x;.z.p);hdel x]]}'[names;hsym urls];
	ecount:count get files;
        .lg.o[`download;"Finished downloading"]
  // Check if new files have been downloaded, if there are new files, send an email to a list of users 
	$[ecount>scount;[newfiles::(neg ecount-scount)#(get files)[`names];
		// .email.senddefault[`to`subject`body!(`$"test@aquaq.co.uk";"New FX files available";("The following files are now available:";string newfiles))]
		];];
        }

// Download all historical data if initialrun enabled
$[1b=initialrun;download[2016.11.28;.z.d;`ALL];]

// Run the download function with the current date at a specified time each day
.timer.rep[.proc.cd[]+runtime;0W;1D;(`download;.proc.cd[];.proc.cd[];`ALL);0h;"Download function";0b]
