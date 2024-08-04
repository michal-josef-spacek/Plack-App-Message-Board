use strict;
use warnings;

use Plack::App::Message::Board::Utils qw(add_message);
use Test::More 'tests' => 4;
use Test::NoWarnings;

# Test.
my $env = {
	'psgix.session' => {
		'messages' => [],
	},
};
add_message($env, 'error', 'Error');
my $message = $env->{'psgix.session'}->{'messages'}->[0];
isa_ok($message, 'Data::Message::Simple');
is($message->type, 'error', 'Get message type (error).');
is($message->text, 'Error', 'Get message text (Error).');
