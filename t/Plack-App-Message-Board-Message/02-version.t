use strict;
use warnings;

use Plack::App::Message::Board::Message;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::Message::Board::Message::VERSION, 0.08, 'Version.');
