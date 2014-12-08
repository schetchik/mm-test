use strict;
use warnings;
use v5.10;

use FindBin;

use lib "$FindBin::Bin/lib";
use MM::Test::App;
use Plack::Builder;


my $app = sub {
    my $mm_app = MM::Test::App->new();
    return $mm_app->run( @_ );
};

builder {
    enable "Plack::Middleware::Static",
        path => qr{^/(static|js)/}, root => '.';
    $app;
};


