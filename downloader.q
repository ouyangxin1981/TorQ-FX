files:`:files
allcpairs:`AUDCAD`AUDCHF`AUDJPY
runtime:17:09:30

lg:{-1(string .z.p)," ",x}
$[.z.K<3.4;{-2 "Error: Need version 3.4 or later";exit 1}[];.z.k>2016.05.12;;{-2 "Error: Need release date 2016.05.12 or later";exit 1}[]]

download:{[startdate;enddate;currencypairs]
        lg"Generating URLS...";
  // Data runs from 5pm on Sunday to 5pm on Friday. Files are stored on the gain capital site by the month of the monday in the week      
	sdate:$[not (startdate mod 7) in (0;1);{x-1}/[{2<x mod 7};startdate];{x+1}/[{2>x mod 7};startdate]];
        edate:$[0=(enddate mod 7);enddate-5;not (enddate mod 7)=1;{x-1}/[{2<x mod 7};enddate];{x+1}/[{2>x mod 7};enddate]];
        dates:{x+7}\[`long$(edate-sdate)%7;sdate];
        d2::(1+til 12)!("January";"February";"March";"April";"May";"June";"July";"August";"September";"October";"November";"December");
        cpairs:$[any currencypairs=`ALL;{"_" sv (3#x;3_x;"Week")}each string allcpairs;{"_" sv (3#x;3_x;"Week")}each string currencypairs];
        urls:raze {"/" sv ("http://ratedata.gaincapital.com";string `year$x;
                ($[1=count 5_string `month$x;"0",5_string `month$x;5_string `month$x],"%20",d2[$["0"=first 5_string `month$x;
                "I"$6_string `month$x;"I"$5_string `month$x]]);
                raze (y;first string $[7>"I"$8_string x;1;14>"I"$8_string x;2;21>"I"$8_string x;3;28>"I"$8_string x;4;5];".zip"))}/:[;cpairs]each dates;
        ndates:asc (count urls)#dates;
        names:hsym `$({(-7#-10_x) except "_"}each urls),'{raze ("." vs x),".zip"}each string ndates;

        lg"Downloading files...";
  // Check if files table exists; if not, create      
	if[0=count key files;files set ([]names:();urls:();size:();downloadtime:())];
	scount:count get files;
  // Download any available files not already downloaded in the date range      
	{if[not x in (get files)[`names];
                lg("Downloading ",1_ string x);x 1:.Q.hg y;$[2000<hcount x;files upsert (x;y;hcount x;.z.p);hdel x]]}'[names;hsym `$urls];
	ecount:count get files;
        lg"Done";
	if[ecount>scount;newfiles::(neg ecount-scount)#(get files)[`names]];
        }


.timer.rep[.proc.cd[]+runtime;0W;1D;(`download;2016.11.28;2016.12.05;`ALL);0h;"Download function";0b]
