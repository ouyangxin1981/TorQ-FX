//
// This file contains the functions that are used to parse a csv file that is detected by
// the filealerter process. The function that should be called by filealerter is
// 'loadCsvFile' if the file is a csv file, or 'loadFile' if the file is a zip file.
// loadFile will then call loadCsvFile for each csv file extracted. Unzip is currently only
// functional for linux.
//
// @author: Brendan McGrath.
// @date:   11th December 2016.
//

// The file handle to the root directory of the hdb.
hdbFH: `:hdb;

// The name of the table in the hdb.
tableName: `gcTable;

//
// Prints the argument to console, prepended with the current timestamp.
//
// @param x: The string to output to console.
//
lg:{
   -1( string .z.p ), " ", x;
   }  

//
// Given a filename for a csv file with data in the format JCSZFF (with the first line as
// column names) or JSZFFC (with no column names), reads the data from the file into a table
// in memory. The first line with column names should be of the format:
// "lTid,cDealable,CurrencyPair,RateDateTime,RateBid,RateAsk"
//
// @param file:   The file to read the data from.
//
// @returns:      A table with the data from the file.
//
parseCsv:{
   [ file ]
   if[ -11 <> type file; '`typ ];

   // Check if the file has a column heading:
   $[
      "lTid,cDealable,CurrencyPair,RateDateTime,RateBid,RateAsk" ~ first 1#
         @[ read0; hsym file; { [err] 0N! err; '`readError } ];
      fileData: .[ 0:; ( ( "JCSZFF"; enlist "," ); hsym file ); { [err] 0N!err } ];
      fileData: flip (`lTid`CurrencyPair`RateDateTime`RateBid`RateAsk`cDealable)!
         .[ 0:; ( ( "JSZFFC"; "," ); hsym file ); { [err] 0N!err; '`readError } ]
      ];

   // Throw an error if all the data in the table is null. This will happen if the csv file
   // has incorrect character encoding. If not null, rearrange the columns and convert the
   // data types:
   lTids: count select from fileData where not null lTid;
   cPairs: count select from fileData where not null CurrencyPair;
   rDTs: count select from fileData where not null RateDateTime;
   rBs: count select from fileData where not null RateBid;
   rAs: count select from fileData where not null RateAsk;
   cDs: count select from fileData where not null cDealable;
   $[
      not ( not lTids ) and ( not cPairs ) and ( not rDTs ) and ( not rBs ) and ( not rAs ) and not cDs;
      :`date`time`lTid`CurrencyPair`RateBid`RateAsk`cDealable xcols delete RateDateTime from
      update date:`date$RateDateTime, time: `time$RateDateTime from fileData;
      '`encodingError
      ]
   }

//
// Given a table, write that table to disk using the variables hdbFH and tableName. (Since
// we do not alter the table this call should work as pass-by-reference. If not then we
// should operate on the table as a global variable.)
// Creates (or updates) a separate partition for each date in the table.
//
// param dataTable: The table to write to disk.
//
writeToDisk:{
   [ dataTable ]
   dates: exec distinct date from dataTable;
   lg "Writing data to hdb for dates: ", " " sv string dates;
   {
      [ dTable; d ]
      saveFH: ` sv .Q.par[ hdbFH; `$string d; tableName ], `;
      saveFH upsert .Q.en[ hdbFH; select time, lTid, cDealable, CurrencyPair, RateBid, RateAsk from dTable where date = d ];
      lg "Data written for date: ", string d;
      }[ dataTable ]each dates;
   
   }

//
// Extracts the files in zippedFile (by issuing a system call) and returns a list of new
// files in the directory after unzipping. The system call depends on the OS.
//
// param zippedFile: The file to unzip.
//
// returns:          Empty symbol list if zippedFile is not of the format *.zip, otherwise
//                   returns a symbol list of names of new files.
//
unzipFile:{
   [ zippedFile ]
   if[
      not zippedFile like "*.zip";
      :`$()
      ];
   if[
      ( .z.o = `l64 ) or .z.o = `l32;
      lg "unzipping file: ", string zippedFile;
      currentFiles: key `:.;
      system "unzip -oj ",string zippedFile;
      newCurrentFiles: key `:.;
      // Check empty list returned when newCurrentFiles and currentFiles are the same:
      :newCurrentFiles where not newCurrentFiles in currentFiles
      ];
   // else if .z.o == w32 or w64:
      // windows system call to unzip. unzip.exe?
   // else if .z.o == s32 or s64:
      // solaris system call to unzip?
   }

//
// This is the function that should be called by filealerter when a new file is found.
// (if we are looking for csv files with filealerter then call loadCsvFile instead.)
//
// param filename: The .zip file to load.
//
loadFile:{
   [ filename ]
   show filename;

   // Extract csv file/s from the zip file:
   unzippedFiles: unzipFile[ filename ];
   $[
      0 <> count unzippedFiles;
      [
         lg "extracted new files: ", " " sv string each unzippedFiles;
         loadCsvFile each unzippedFiles
         ];
      lg "no new csv files found."
      ];

   }

//
// Loads the csv file by parsing it and saving it to disk.
//
// param csvFile: A symbol atom containing the name of the csv file to load.
//
loadCsvFile:{
   [ csvFile ]
   if[
      ( `l64 = .z.o ) or `l32 = .z.o;
      if[
         first (system "file -bi ", string csvFile) like "*utf-16*";
         show "Warning: attempting to parse utf-16 encoded csv file (", (string csvFile),
         "). Convert to appropriate format first."
         ]
      ];

   // Parse csv file to load data into memory:
   lg "Starting to load the csv file.";
   data: @[
      parseCsv;
      csvFile;
      { [ err ] -1 "Failed to load csvFile"; 0N! err }
      ];

   // Check for error in reading csv file:
   if[
      98 <> type data;
      if[
         ( data like "encodingError" ) or data like "readError";
         : ::
         ]
      ];
   lg (string csvFile), " loaded.";

   // write to hdb:
   //lg "Starting to write table to hdb."
   //writeToDisk[ data ];
   //lg "Data written to hdb."
   // move/delete csv file/s if everything has gone correctly.

   // reload the hdb:
   //\l .
   }
