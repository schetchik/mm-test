use strict;
use warnings;
use v5.10;
use utf8;

package MM::Test::App;

use Template;
use Plack::Request;
use Plack::Response;

use Data::Dumper;

use MM::Test::Controller::Main;


sub new {
    return bless {}, shift;
}

sub run {
    my ( $self, $env ) = @_;

    my $controller = $self->route( $env );
    return $self->render_404 if !$controller;

    my $response = eval {
        $controller->run();
    };
    if ( $@ ) {
        return $self->render_500
    }

    return $self->render( $response );
}

sub route {
    my ( $self, $env ) = @_;

    my $request = $self->_make_request( $env );
    $self->request( $request );

    my ( $action ) = $self->request->path_info =~ qr{^/(\w+)/?};


    return MM::Test::Controller::Main->new(
        request => $self->request,
        action => $action,
        app => $self,
    );
}

sub render {
    my ( $self, $response ) = @_;

    $response->status( 200 ) unless $response->status;
    $response->content_type( 'text/html;charset=utf8' ) unless $response->content_type;

    my $body = [];
    if ( $response->template ) {
        my $tt = Template->new(
            {
                INCLUDE_PATH => 'template',
                OUTPUT => $body,
            }
        );
        $tt->process(
            $response->template . ".tt",
            $response->template_params || {},
            $body
        );

        $response->body( $body );
    }

    return $response->finalize();
}

sub render_404 {
    my ( $self ) = @_;
    my $response = MM::Test::Response->new( 404 );
    $response->template( '404' );
    return $self->render( $response );
}

sub render_500 {
    my ( $self ) = @_;
    my $response = MM::Test::Response->new( 500 );
    $response->template( '500' );
    return $self->render( $response );
}

sub _make_request {
    my ( $self, $env ) = @_;
    return Plack::Request->new( $env )
}

sub request {
    my ( $self, $request ) = @_;

    $self->{request} = $request if defined $request;

    return $self->{request};
}

sub dbh {
    my ( $self ) = @_;

    if ( !defined $self->{dbh} ) {
        require DBI;
        $self->{dbh} = DBI->connect("dbi:SQLite:dbname=db/mm.db","","");
    }

    return $self->{dbh};
}

1;