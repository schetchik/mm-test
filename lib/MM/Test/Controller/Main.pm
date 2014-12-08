use strict;
use warnings;
use v5.10;
use utf8;


package MM::Test::Controller::Main;

use Data::Dumper;
use Encode 'decode', 'encode';

use MM::Test::Response;
use MM::Test::Model::User;

sub new {
    my ( $class, %options ) = @_;
    $options{response} = MM::Test::Response->new() unless $options{response};
    return bless \%options, $class;
}


sub run {
    my ( $self ) = @_;
    $self->action( 'index' ) if ( !$self->action || !$self->can( $self->action ) );
    my $action = $self->action;
    return $self->$action;
}

sub index {
    my ( $self ) = @_;
    if ( $self->registered ) {
        my $user = MM::Test::Model::User->new( dbh => $self->app->dbh );
        $self->response->template( 'user_list' );
        $self->response->template_params( { users => $user->list } );
    } else {
        $self->response->template( 'registration_form' );
    }
    return $self->response;
}

sub registered {
    my ( $self ) = @_;
    return $self->request->cookies->{user_name} && Encode::decode( "utf8", $self->request->cookies->{user_name} ) =~ /^\w+$/;
}

sub registration {
    my ( $self ) = @_;

    if ( $self->request->method eq 'POST' ){
        my $registration_form = $self->_make_form( 'registration' );
        if ( $self->registration_form_valid( $registration_form ) ) {
            my $user = MM::Test::Model::User->new(
                %$registration_form,
                dbh => $self->app->dbh,
            );
            $user->save;
            $self->response->cookies->{user_name} = $user->{name};
        } else {
            $self->response->template( 'registration_form' );
            $self->response->template_params( {
                %$registration_form,
                error => 'Invalid params',
            } );

            return $self->response;
        }
    }

    $self->response->redirect( '/' );
    return $self->response;

}

sub _make_form {
    my ( $self, $form ) = @_;
    my $form_data = {};
    if ( $form eq 'registration' ) {
        for ( qw/email name/ ){
            $form_data->{ $_ } = $self->request->param( $_ );
        }
    }
    return $form_data;
}

sub logout {
    my ( $self ) = @_;
    if ( $self->registered ) {
        my $user = MM::Test::Model::User->new(
                dbh => $self->app->dbh,
                name => $self->request->cookies->{user_name},
        );
        my $rc = $user->delete();
        if ( $rc ) {
            $self->response->cookies->{user_name} = {
                value => "",
                expire => 0
            };
        }
    }
    $self->response->redirect( '/' );
    return $self->response;
}


sub registration_form_valid {
    my ( $self, $form ) = @_;
    return Encode::decode( "utf8", $form->{name} ) =~ /^\w+$/
        && Encode::decode( "utf8", $form->{email} ) =~ /^\w+\@\w+\.\w+$/
}


sub request {
    my ( $self, $request ) = @_;

    $self->{request} = $request if defined $request;

    return $self->{request};
}

sub response {
    my ( $self, $response ) = @_;

    $self->{response} = $response if defined $response;

    return $self->{response};
}

sub action {
    my ( $self, $action ) = @_;

    $self->{action} = $action if defined $action;

    return $self->{action};
}

sub app {
    my ( $self ) = @_;
    return $self->{app};
}


1;