use strict;
use warnings;

use Test::NoWarnings;
use Test::Pod::Coverage 'tests' => 2;

# Test.
pod_coverage_ok('Plack::App::Message::Board::Utils', 'Plack::App::Message::Board::Utils is covered.');
