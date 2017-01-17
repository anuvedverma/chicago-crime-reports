# Table of Contents

1. [Overview] (README.md#overview)
2. [Instructions] (README.md#instructions)


## Overview
The goal of this project was to analyze Chicago's historical crime data (from Jan. 1st 2011 to present day) to determine the most frequent types of locations that various crimes occur. For example, where do most homicides occur? In apartments? On the streets? In schools? This project aims to shed light on these type of questions, using Big Data practices and the Nathan Marz's Lambda Architecture.


Historical crime data was gathered from the City of Chicago Data Portal (https://data.cityofchicago.org), using a subset of their `Crimes - 2001 to present` dataset to get crime data from 2011 onwards. Present-day crime data is included in the analysis, using incoming data in real-time from http://104.197.248.161/anuvedverma/submit-crime.html.


Data was stored in Hadoop's HDFS for the batch layer, and HBase for the serving layer. Pig was used to compute and store the tables of interest into HBase. The speed layer used a combination of Kafka and HBase.
The front-end for the crime report analysis was mostly developed in Python, using the `happybase` module to access HBase. Python was also used for the speed layer to access Kafka (using the `kafka-python` module), parse the real-time messages, and update HBase accordingly.
The front-end for new crime report submissions used Perl to read input data from the UI form, and produce a new message accordingly to the appropriate Kafka topic.




## Instructions

Live demos of the project can be viewed at the following URLs:
* http://104.197.248.161/anuvedverma/crime-report.html to view analysis of crime reports
* http://104.197.248.161/anuvedverma/submit-crime.html to submit a new crime report to be included in the analysis



To reproduce this project on the cluster, do the following:
1. On the `hdp-m` cluster, run the `step1-crimes.pig` script provided under the `crime-web-app/hdp-m/` directory. This script uses `anuvedverma_chicago_crimes.csv`, located in the `/inputs` directory of `hdp-m`'s hadoop cluster.
2. On `hdp-m`, run the following commands in HBase to create the appropriate tables:
	* `create 'anuvedverma_crimes_by_type', 'crime_type:count'`
	* `create 'anuvedverma_crimes_by_street', 'crime_street:count'`
	* `create 'anuvedverma_crimes_by_location_type', 'crime_location_type:count'`
	* `create 'anuvedverma_crimes_by_type_and_loctype', 'crime_type_loctype:count'`
3. On `hdp-m`, run the `chicago_crimes.pig` script provided under the `crime-web-app/hdp-m/` directory.
4. Place all the files provided under the `crimes-web-app/webserver/cgi-bin` directory onto the `webserver` cluster, under `/usr/lib/cgi-bin/anuvedverma`.
5. Place all the files provided under the `crimes-web-app/webserver/html` directory onto the `webserver` cluster, under `/var/www/html/anuvedverma`.
6. On `hdp-m`, create the appropriate Kafka topic with the following command: `kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic anuvedverma-crime-event`
7. On `webserver`, run the following command: `nohup python /usr/lib/cgi-bin/anuvedverma/consume-kafka.py &`. This sets up Python script to run in the background and listening for new Kafka messages in our topic.