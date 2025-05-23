use strict;
use warnings;

use English;
use Error::Pure::Utils qw(clean);
use Plack::App::Message::Board::Utils qw(add_message);
use Test::More 'tests' => 10;
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

# Test.
$env = {
	'psgix.session' => {
		'messages' => [],
	},
};
add_message($env, undef, 'This is info message.');
$message = $env->{'psgix.session'}->{'messages'}->[0];
isa_ok($message, 'Data::Message::Simple');
is($message->type, 'info', 'Get message type (info - default).');
is($message->text, 'This is info message.', 'Get message text (This is info message.).');

# Test.
$env = {
	'psgix.session' => {
		'messages' => [],
	},
};
eval {
	add_message($env, 'error');
};
is($EVAL_ERROR, "Parameter 'text' is required.\n",
	"Parameter 'text' is required.");
clean();

# Test.
$env = {
	'psgix.session' => {
		'messages' => [],
	},
};
eval {
	add_message($env, 'error', 'x' x 5000);
};
is($EVAL_ERROR, "Parameter 'text' has length greater than '4096'.\n",
	"Parameter 'text' has length greater than '4096'.");
clean();

# Test.
$env = {
	'psgix.session' => {
		'messages' => [],
	},
};
eval {
	add_message($env, 'bad', 'Error');
};
is($EVAL_ERROR, "Parameter 'type' must be one of defined strings.\n",
	"Parameter 'type' must be one of defined strings.");
clean();
