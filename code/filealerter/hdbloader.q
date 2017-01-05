unzipfile:{[path;file]
        `:test.dat set path, "   ", file;
        //unzip file into csv directory
        system "unzip -oj ", path, file, " -d ", path,"../csv";
         //move the zip file to processed zip directory
        system "mv ", path, file, " ",  path,"../proczip";
        }

loadfxdata:{[path;file]
        unzipfile[path;file];

        //set path and file to be relevant to the csv file
        path:path,"../csv";
        file:f where (f:key (hsym `$path)) like "*.csv";
        
	//load csv file into on disk hdb
        .loader.loadallfiles[`headers`types`separator`tablename`dbdir`partitioncol!(`lTid`cDealable`CurrencyPair`RateDateTime`RateBid`RateAsk;"JCSZFF";enlist",";`gainfx;`:fxhdb;`RateDateTime); `$path];

        //Send reload message to each hdb
        dis:exec hpup from .servers.SERVERS where proctype = `discovery;
        h:hopen `$raze (string dis),(":admin:admin");
        ports:h"exec hpup from .servers.SERVERS where proctype = `hdb";
        hclose h;
        {[port] h:hopen `$raze (string port),(":admin:admin"); h"reload[]";hclose h} each ports;

        hdel hsym `$(raze path,"/",(string file));
        }
