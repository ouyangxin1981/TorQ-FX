unzipfile:{[path;file]
        //unzip file into csv directory
	system "unzip -oj ", path,"/", file, " -d ", csvp:getenv[`KDBCSV],"/",(-4_file),"/";	

        //move the zip file to processed zip directory
        system "mv ", path,"/", file, " ", getenv[`PROCZIP];
	:csvp;
        }

loadfxdata:{[path;file]
        date:"D"$-4_6_file;
	
	//unzip file and pass path back
	path:unzipfile[path;file];
	
        //set path to be relative to the csv file
	file:f where ((f:key (hsym `$path)) like "*.csv") or (f:key (hsym `$path)) like "*.CSV";
		
	{[path;file;date]
	//Get and check the file encoding. Convert to ASCII if  utf.
	enc:3# first system "file -i ",raze path,"/",(string file), " | cut -f 2 -d\";\" | cut -f 2 -d\"=\"";
	if[enc ~ "utf";
	system "iconv -f UTF-16 -t ascii " ,raze path,"/", (string file),"> temp.tmp && mv temp.tmp " ,raze path,"/",(string file)];

	//If using old schema, rearrange columns to match current schema
        $[date<=2009.11.21;

	.loader.loadallfiles[`headers`types`separator`tablename`dbdir`partitioncol`dataprocessfunc!(`lTid`CurrencyPair`RateDateTime`RateBid`RateAsk`cDealable;"JSPFFC";",";`gainfx;`$":",getenv[`KDBHDB];`RateDateTime;
	{[x;y]`lTid`cDealable`CurrencyPair`RateDateTime`RateBid`RateAsk xcols y; delete from y where RateDateTime = 0Nn}); `$path];	

	//Else load csv files into hdb with current schema
	.loader.loadallfiles[`headers`types`separator`tablename`dbdir`partitioncol!(`lTid`cDealable`CurrencyPair`RateDateTime`RateBid`RateAsk;"JCSPFF";enlist",";`gainfx;`$":",getenv[`KDBHDB];`RateDateTime); `$path]];
	
	//Send reload message to each HDB process
	{x"reload[]"} each exec w from .servers.getservers[`proctype;`hdb;()!();1b;0b];

	//Delete csv files/paths
	system "rm -r ",path;}[path;;date] each file
        }
