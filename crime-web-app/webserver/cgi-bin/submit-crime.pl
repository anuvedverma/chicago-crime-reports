#!/usr/bin/perl -w
# Program: cass_sample.pl
# Note: includes bug fixes for Net::Async::CassandraCQL 0.11 version

use strict;
use warnings;
use 5.10.0;
use FindBin;

use Scalar::Util qw(
        blessed
    );
use Try::Tiny;

use Kafka::Connection;
use Kafka::Producer;

use Data::Dumper;
use CGI qw/:standard/, 'Vars';

my $type = uc param('crime_type');
my $street = uc param('crime_street');
my $location_type = uc param('crime_location_type');

if(!$type or !$street or !$location_type) {
    exit;
}

my ( $connection, $producer );
try {
    #-- Connection
    $connection = Kafka::Connection->new( host => 'hdp-m.c.mpcs53013-2016.internal', port => 6667 );

    #-- Producer
    $producer = Kafka::Producer->new( Connection => $connection );
    # Only put in the district_id, crime, and arrest, because those are the only ones we care about
    my $message = $type."|".$street."|".$location_type;
    # my $message = "<crime_event><type>".$type."</type><street>.$street.</street><location_type>.$location_type.</location_type><crime_event>";

    # Sending a single message
    my $response = $producer->send(
	'anuvedverma-crime-event',         # topic
	0,                                 # partition
	$message                           # message
        );
} catch {
    if ( blessed( $_ ) && $_->isa( 'Kafka::Exception' ) ) {
	warn 'Error: (', $_->code, ') ',  $_->message, "\n";
	exit;
    } else {
	die $_;
    }
};

# Closes the producer and cleans up
undef $producer;
undef $connection;

print header, start_html(-title=>'Submit a Crime Event',-head=>Link({-rel=>'stylesheet',-href=>'/anuvedverma/table.css',-type=>'text/css'}));
print table({-class=>'CSS_Table_Example', -style=>'width:80%;'},
            caption('Crime Event Submitted'),
	    Tr([th(["Crime Type", "Street", "Location Type"]),
	        td([$type, $street, $location_type])]));

#print $protocol->getTransport->getBuffer;
print end_html;
