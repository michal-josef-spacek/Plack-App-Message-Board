use strict;
use warnings;

use Plack::App::Message::Board;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
my $obj = Plack::App::Message::Board->new;
isa_ok($obj, 'Plack::App::Message::Board');
