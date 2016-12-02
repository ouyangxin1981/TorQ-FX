lg:{-1(string .z.p)," ",x}

download:{[startdate;enddate]
  // Need kdb+ version 3.4,2016.05.12 or later
        lg"Checking version...";
        $[.z.K<3.4;{-2 "Error: Need version 3.4 or later";exit 1}[];.z.k>2016.05.12;;{-2 "Error: Need release date 2016.05.12 or later";exit 1}[]];
        lg"Generating URLS...";
  // Data runs from 5pm on Sunday to 5pm on Friday. Files are stored on the gain capital site by the month of the monday in the week      
	sdate:$[not (startdate mod 7) in (0;1);{x-1}/[{2<x mod 7};startdate];{x+1}/[{2>x mod 7};startdate]];
        edate:$[0=(enddate mod 7);enddate-5;not (enddate mod 7)=1;{x-1}/[{2<x mod 7};enddate];{x+1}/[{2>x mod 7};enddate]];
        dates:{x+7}\[`long$(edate-sdate)%7;sdate];
        d2::(1+til 12)!("January";"February";"March";"April";"May";"June";"July";"August";"September";"October";"November";"December");
        urls:{"/" sv ("http://ratedata.gaincapital.com";string `year$x;
                ($[1=count 5_string `month$x;"0",5_string `month$x;5_string `month$x],"%20",d2[$["0"=first 5_string `month$x;
                "I"$6_string `month$x;"I"$5_string `month$x]]);
                raze ("currencypair";first string $[7>"I"$8_string x;1;14>"I"$8_string x;2;21>"I"$8_string x;3;28>"I"$8_string x;4;5];".zip"))}each dates;
        GBPUSD:{ssr[x;"currencypair";"GBP_USD_Week"]}each urls;
        GBPAUD:{ssr[x;"currencypair";"GBP_AUD_Week"]}each urls;
        GBPJPY:{ssr[x;"currencypair";"GBP_JPY_Week"]}each urls;
        allurls:GBPUSD,GBPAUD,GBPJPY;
        ndates:(3*count dates)#dates;
        names:hsym `$({-8#-9_x}each allurls),'{raze ("." vs x),".zip"}each string ndates;

        lg"Downloading files...";
  // Check if files table exists; if not, create      
	if[0=count key hsym `:files;`:files set ([]names:())];
        newfiles::();
  // Download any available files not already downloaded in the date range      
	{if[not x in get `:files;
                lg("Downloading ",1_ string x);x 1:.Q.hg y;`:files upsert x;newfiles::newfiles,x]}'[names;hsym `$allurls];
        lg"Done";
        }

filecheck:{[date]
        lg"Checking version...";
        $[.z.K<3.4;{-2 "Error: Need version 3.4 or later";exit 1}[];.z.k>2016.05.12;;{-2 "Error: Need release date 2016.05.12 or later";exit 1}[]];
        lg"Generating URLS";
        sdate:$[not (date mod 7) in (0;1);{x-1}/[{2<x mod 7};date];{x+1}/[{2>x mod 7};date]];
        d2::(1+til 12)!("January";"February";"March";"April";"May";"June";"July";"August";"September";"October";"November";"December");
        url:{"/" sv ("http://ratedata.gaincapital.com";string `year$x;
                ($[1=count 5_string `month$x;"0",5_string `month$x;5_string `month$x],"%20",d2[$["0"=first 5_string `month$x;
                "I"$6_string `month$x;"I"$5_string `month$x]]);
                raze ("GBP_AUD_Week";first string $[7>"I"$8_string x;1;14>"I"$8_string x;2;21>"I"$8_string x;3;28>"I"$8_string x;4;5];".zip"))}[sdate];
        name:hsym `$(-8#-9_url),(raze "." vs string sdate),".zip";
        lg"Checking for files";
  // Check if filename in files table; if not then check size of downloaded file to see whether file available     
	 $[name in get `:files;-1 "No new files";
                $[10000>count .Q.hg hsym `$url;-1 "No new files";-1 "New files available"]];}

