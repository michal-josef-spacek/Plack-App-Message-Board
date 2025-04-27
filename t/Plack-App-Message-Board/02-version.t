use strict;
use warnings;

use Plack::App::Message::Board;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::Message::Board::VERSION, 0.1, 'Version.');
