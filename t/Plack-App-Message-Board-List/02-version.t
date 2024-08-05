use strict;
use warnings;

use Plack::App::Message::Board::List;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::Message::Board::List::VERSION, 0.07, 'Version.');
