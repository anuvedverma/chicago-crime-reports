#!/usr/bin/python

import happybase
import cgi
import cgitb
from html import HTML

cgitb.enable()

############################## HEADER #######################################

# Start HTML #
print 'Content-type:text/html'
print '\n'

html = HTML('html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US"')

# Start Header #
header = html.head
header.title('Crime Reports')
header.link(rel="stylesheet", type="text/css", href="/anuvedverma/table.css")
header.meta(http_equiv="Content-Type", content="text/html; charset=iso-8859-1")
# End Header #

# Start Body #
body = html.body


#############################################################################

############################### BODY ########################################

# Connect to HBase
hbase = happybase.Connection('hdp-m')
hbase.open()

# Get data from form
form = cgi.FieldStorage()

# Loop through all checked crime_type boxes
crime_types = form.getlist('crime_type')
for crime_type in crime_types:
	
	############### GATHER HBASE DATA ##################
	table = hbase.table('anuvedverma_crimes_by_type_and_loctype')

	records = table.scan(row_prefix = crime_type)

	total = 0
	loctypes = [] # location type (ie. street, school, apartment, etc.)
	for row in records:
		loctype = row[0].split('|')[1]
		loctype_count = int((row[1])['crime_type_loctype:count'])
		loctypes.append((loctype, loctype_count))
		total += loctype_count

	loctypes.sort(key=lambda x: x[1], reverse=True)

	# Delete redundant 'OTHER' (gets calculated later anyways)
	for loctype in loctypes[:5]:
		if loctype[0] == 'OTHER':
			loctypes.remove(loctype)
		

	################## TABLE DATA ######################

	p = body.p(style='bottom-margin:10px').text('')

	# Table #
	title = body.h4(str(crime_type))
	table = body.table(klass='CSS_Table_Example', style='style="width:100%;margin:auto;" align="center"')

	row_head = table.tr
	row_head.td(loctypes[0][0])
	row_head.td(loctypes[1][0])
	row_head.td(loctypes[2][0])
	row_head.td(loctypes[3][0])
	row_head.td(loctypes[4][0])
	row_head.td('OTHER')
	row_head.td('Total (2011 - present)')

	#row_head.td('Streets/Alleys')
	#row_head.td('Residential')
	#row_head.td('School')
	#row_head.td('Bar/Tavern')
	#row_head.td('Other')
	#row_head.td('Total')

	row = table.tr
	percent_0 = (float(loctypes[0][1])/total)*100
	percent_1 = (float(loctypes[1][1])/total)*100
	percent_2 = (float(loctypes[2][1])/total)*100
	percent_3 = (float(loctypes[3][1])/total)*100
	percent_4 = (float(loctypes[4][1])/total)*100
	percent_other = (float(100 - (percent_0 + percent_1 + percent_2 + percent_3 + percent_4)))

	row.td("{:.2f}%".format(percent_0))
	row.td("{:.2f}%".format(percent_1))
	row.td("{:.2f}%".format(percent_2))
	row.td("{:.2f}%".format(percent_3))
	row.td("{:.2f}%".format(percent_4))
	row.td("{:.2f}%".format(percent_other))
	row.td(str(total))
	# End Table #

	p = body.p(style='bottom-margin:10px').text('')
	body.br

# End Body #

#############################################################################

############################### CLOSE########################################
print html # End HTML

hbase.close()
