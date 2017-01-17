-------------------------- LOAD CRIMES-- ------------------------------------------

CRIMES = LOAD '/inputs/anuvedverma_chicago_crimes' USING PigStorage(',')
AS (id, date, street, type, description, location_type, arrest);

-------------------------- BY CRIME TYPE ------------------------------------------

BY_TYPE = GROUP CRIMES BY (type);
BY_TYPE_CLEAN = FILTER BY_TYPE BY (group neq '');
TYPE_COUNTS = FOREACH BY_TYPE_CLEAN GENERATE
	group AS type,
	COUNT(CRIMES) AS count;

STORE TYPE_COUNTS INTO 'hbase://anuvedverma_crimes_by_type'
  USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
    'crime_type:count');

-----------------------------------------------------------------------------------

-------------------------- BY CRIME STREET-- --------------------------------------

BY_STREET = GROUP CRIMES BY (street);
BY_STREET_CLEAN = FILTER BY_STREET BY (group neq '');
STREET_COUNTS = FOREACH BY_STREET_CLEAN GENERATE
	group AS street,
	COUNT(CRIMES) AS count;

STORE STREET_COUNTS INTO 'hbase://anuvedverma_crimes_by_street'
  USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
    'crime_street:count');

-----------------------------------------------------------------------------------

-------------------------- BY CRIME LOCATION TYPE---------------------------------

BY_LOCATION_TYPE = GROUP CRIMES BY (location_type);
BY_LOCATION_TYPE_CLEAN = FILTER BY_LOCATION_TYPE BY (group neq '');
LOCATION_TYPE_COUNTS = FOREACH BY_LOCATION_TYPE_CLEAN
	GENERATE
	group AS location_type,
	COUNT(CRIMES) AS count;

STORE LOCATION_TYPE_COUNTS INTO 'hbase://anuvedverma_crimes_by_location_type'
  USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
    'crime_location_type:count');

-----------------------------------------------------------------------------------

-------------------------- BY CRIME TYPE AND LOCTYPE STREET------------------------

BY_TYPE_AND_LOCTYPE = GROUP CRIMES BY (type, location_type);
BY_TYPE_AND_LOCTYPE_CLEAN = FILTER BY_TYPE_AND_LOCTYPE BY (group.type neq '') AND (group.location_type neq '');
TYPE_AND_LOCTYPE_COUNTS = FOREACH BY_TYPE_AND_LOCTYPE_CLEAN
	GENERATE
	CONCAT(group.type, '|', group.location_type) AS type_loctype,
	COUNT(CRIMES) AS count;

STORE TYPE_AND_LOCTYPE_COUNTS INTO 'hbase://anuvedverma_crimes_by_type_and_loctype'
  USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
    'crime_type_loctype:count');

