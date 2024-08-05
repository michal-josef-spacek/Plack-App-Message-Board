use strict;
use warnings;

use Plack::App::Message::Board::Utils;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::Message::Board::Utils::VERSION, 0.05, 'Version.');
