unzipFile:{[path;file]
        system "unzip -oj ", file;
        system "mv ", (-4_file) ,".csv " , path,"/fxdata";
        hdel hsym `$path,file
   	}

loadfxdata:{[path;file]
        .loader.loadallfiles[`headers`types`separator`tablename`dbdir`partitioncol!(`lTid`cDealable`CurrencyPair`RateDateTime`RateBid`RateAsk;"JCSZFF";enlist",";`gainfx;`:fxhdb;`RateDateTime); `$path];
        dis:exec hpup from .servers.SERVERS where proctype = `discovery;
	h:hopen `$raze (string dis),(":admin:admin");
	ports:h"exec hpup from .servers.SERVERS where proctype = `hdb";
	hclose h;
	{[port] h:hopen `$raze (string port),(":admin:admin"); h"reload[]";hclose h} each ports;
	}
