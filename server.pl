#use Modern::Perl;
use strict;
use Data::Dumper;

use DBI;
use Template;


use HTTP::Server::PSGI;


my $app = sub {
    my $env = shift;
    my ( $status, $headers, $body );
    $status = 200;
    $headers = [ 'Content-Type' => 'text/html;charset=utf-8' ];
    my @body = ();

    my $dbh = DBI->connect("dbi:SQLite:dbname=db/mm.db","","");
    my $tt = Template->new( {
    	INCLUDE_PATH => 'template',
#    	ENCODING => 'utf8',
    } );

    if ( $env->{REQUEST_METHOD} ) {
    	#$body = [ "Add User\n" ];
    	my $list = $dbh->selectall_arrayref( 'select * from user', { Slice => {} } );
    	warn Dumper $list;
    	#push @$body, map{ %$_ } @$list;
    	$tt->process( 'user_list.tt', { users => $list }, \@body );
    	use Encode;
    	for ( @$body ){
    		$_ = Encode::encode( "utf8", $_ )
    	}
    	warn Dumper \@body;
    } else  {
    	$body = [ "List Users" ];
    	#$dbh->sql
    }

    return [ $status, $headers, \@body ];
};
my $server = HTTP::Server::PSGI->new(
    host => "127.0.0.1",
    port => 9091,
    timeout => 120,
);

$server->run($app);