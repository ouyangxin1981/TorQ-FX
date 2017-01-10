unzipfile:{[path;file]
        //unzip file into csv directory
        system "unzip -oj ", path, file, " -d ", getenv[`KDBCSV];
         //move the zip file to processed zip directory
        system "mv ", path, file, " ", getenv[`PROCZIP];
        }

loadfxdata:{[path;file]
        unzipfile[path;file];
	
	date:"D"$-4_6_file;

        //set path and file to be relative to the csv file
        path:getenv[`KDBCSV];
        file:f where (f:key (hsym `$path)) like "*.csv";

        //load csv file into on disk hdb
        $[date<=2008.01.19;
	
	/if data before specified date above add header column to csv then load into on disk hdb
	(system "sed -i 1i\"lTid,CurrencyPair,RateDateTime,RateBid,RateAsk,cDealable\" " ,raze path,"/",(string file);
	.loader.loadallfiles[`headers`types`separator`tablename`dbdir`partitioncol!(`lTid`CurrencyPair`RateDateTime`RateBid`RateAsk`cDealable;"JSPFFC";enlist",";`gainfx;`$":",getenv[`KDBHDB];`RateDateTime); `$path]);
	
	/else load data into on disk hdb
	.loader.loadallfiles[`headers`types`separator`tablename`dbdir`partitioncol!(`lTid`cDealable`CurrencyPair`RateDateTime`RateBid`RateAsk;"JCSPFF";enlist",";`gainfx;`$":",getenv[`KDBHDB];`RateDateTime); `$path]];
	
	/Send reload message to each HDB process
	{x"reload[]"} each exec w from .servers.getservers[`proctype;`hdb;()!();1b;0b];

	/Delete csv files
	hdel hsym `$(raze path,"/",(string file));
        }
