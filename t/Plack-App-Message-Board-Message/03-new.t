use strict;
use warnings;

use Plack::App::Message::Board::Message;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
my $obj = Plack::App::Message::Board::Message->new;
isa_ok($obj, 'Plack::App::Message::Board::Message');
