-- Import the CSVLoader plugin (available from the 3rd party piggybank modules collection)
register /usr/local/mpcs53013/piggybank.jar;

-- Load our collected SFPD data from HDFS
RAW_CRIME_DATA = LOAD '/inputs/anuvedverma_chicago_crimes.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'NOCHANGE', 'SKIP_INPUT_HEADER'); 

-- Select the fields we're interested in
CRIME_DATA = FOREACH RAW_CRIME_DATA GENERATE $0 AS id, $2 AS date, SUBSTRING($3, 6, (int)SIZE($3)) AS street, $5 AS type, $6 AS description, $7 AS location_type, $8 AS arrest;

-- Store the resulting data into HDFS as a CSV file
STORE CRIME_DATA INTO '/inputs/anuvedverma_chicago_crimes/' USING PigStorage(',');