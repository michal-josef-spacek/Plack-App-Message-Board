use strict;
use warnings;

use Plack::App::MessageBoard;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::App::MessageBoard::VERSION, 0.01, 'Version.');
