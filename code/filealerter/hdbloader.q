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
	
	//Get and check the file encoding. Convert toASCII if  utf.
	enc:3#raze raze string system "file -i ",raze path,"/",(string file), "| cut -f 2 -d\";\" | cut -f 2 -d\"=\"";
	if[enc ~ "utf";
	system "iconv -f UTF-16 -t ascii " ,raze path,"/",(string file),"> temp.tmp && mv temp.tmp " ,raze path,"/",(string file)];
	
	//If using old schema, add headers and rearrange columns to match current schema
        if[date<=2009.11.21;
	f 0:.h.tx[`csv;`lTid`cDealable`CurrencyPair`RateDateTime`RateBid`RateAsk xcols flip `lTid`CurrencyPair`RateDateTime`RateBid`RateAsk`cDealable!("JSPFFC";",")0: f:hsym `$(raze path,"/",(string file))]];
	
	//Load csv files into hdb
	.loader.loadallfiles[`headers`types`separator`tablename`dbdir`partitioncol!(`lTid`cDealable`CurrencyPair`RateDateTime`RateBid`RateAsk;"JCSPFF";enlist",";`gainfx;`$":",getenv[`KDBHDB];`RateDateTime); `$path];
	
	//Send reload message to each HDB process
	{x"reload[]"} each exec w from .servers.getservers[`proctype;`hdb;()!();1b;0b];

	if[`gainfx in f where (f:key (hsym `$p:"/home/squigley/fx/deploy/fxhdb")) like "gainfx";
	system "rm -r ", getenv[`KDBHDB],"/","gainfx"];

	//Delete csv files
	hdel hsym `$(raze path,"/",(string file));
        }
