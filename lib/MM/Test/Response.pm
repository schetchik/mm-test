use strict;
use warnings;
use v5.10;


package MM::Test::Response;
use parent 'Plack::Response';

use Encode 'encode';

sub template {
    my ( $self, $template ) = @_;
    $self->{template} = $template if $template;
    return $self->{template};
}

sub template_params {
    my ( $self, $params ) = @_;
    $self->{template_params} = $params if ref $params;
    return $self->{template_params};
}

sub set_cookie {
    my ( $self, $name, $value ) = @_;
    $value = encode( "utf8", $value );
    $self->cookies->{ $name } = $value;
}

1;