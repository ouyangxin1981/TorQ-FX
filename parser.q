\c 61 240

//
// Prints the argument to console, prepended with the current timestamp.
//
// @param x: The string to output to console.
//
lg:{
   -1( string .z.p ), " ", x;
   }  

//
// Given a filename for a csv file with data in the format JCSZFF, reads the data from the
// file into a table in memory.
//
// @param file: The file to read the data from.
// @return A table with the data from the file.
//
parseCsv:{
   [ file ]

   // there is problem here because not all the csv files are of the same format.
   // it will be necessary to detect the format or call with different format strings based
   // on the date of the historical data file.

   //fileData: ( "JCSZFF"; enlist "," ) 0: hsym file;
   //`date`time xcols delete RateDateTime from update date:`date$RateDateTime, time: `time$RateDateTime from fileData
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
   {
      [ dTable; d ]
      saveFH: ` sv .Q.par[ hdbFH; `$string d; tableName ], `;
      saveFH upsert .Q.en[ hdbFH; select time, lTid, cDealable, CurrencyPair, RateBid, RateAsk from dTable where date = d ];
      }[ dataTable ]each dates;
   
   }

//
// Extracts the files in zippedFile (by issuing a system call) and returns a list of new
// files in the directory after unzipping. The system call depends on the OS.
//
// param zippedFile: The file to unzip.
// return: Empty symbol list if zippedFile is not of the format *.zip, otherwise returns a
// symbol list of names of new files.
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
      // check empty list returned when newCurrentFiles and currentFiles are the same:
      :newCurrentFiles where not newCurrentFiles in currentFiles
      ];
   // else if .z.o == w32 or w64:
      // windows system call to unzip. unzip.exe?
   // else if .z.o == s32 or s64:
      // solaris system call to unzip?
   }



// The file handle to the root directory of the hdb.
hdbFH: `:hdb;
tableName: `gcTable;

//
// This is the function that should be called by filealerter when a new file is found.
// (if we are looking for csv files with filealerter then call loadCsvFile instead.)
//
// param filename: The .zip file to load.
//
loadFile:{
   [ filename ]
   show filename;

   // extract csv file/s from the zip file:
   unzippedFiles: unzipFile[ filename ];
   $[
      0 <> count unzippedFiles;
      [
         lg "extracted new files: ", " " sv string each unzippedFiles;
         loadCsvFile each unzippedFiles
         ];
      lg "no new csv files found."
      // reload the hdb:
      //\l .
      ];



   }

//
// Loads the csv file by parsing it and saving it to disk.
//
// param csvFile: A symbol atom containing the name of the csv file to load.
//
loadCsvFile:{
   [ csvFile ]

   // parse csv file to load data into memory:
   data: parseCsv[ csvFile ];
   show select [ 0 10 ] from data;

   // write to hdb:
   //writeToDisk[ data ];
   // move/delete zip file if everything has gone correctly.
   }

//loadFile[ "AUD_CAD_Week1.zip" ]
