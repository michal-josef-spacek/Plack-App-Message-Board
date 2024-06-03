package Plack::App::Message::Board::Utils;

use base qw(Exporter);
use strict;
use warnings;

use Data::Message::Simple;
use Plack::Session;
use Readonly;

Readonly::Array our @EXPORT_OK => qw(add_message);

our $VERSION = 0.01;

sub add_message {
	my ($self, $env, $message_type, $message) = @_;

	my $session = Plack::Session->new($env);
	my $m = Data::Message::Simple->new(
		'text' => $message,
		'type' => $message_type,
	);
	my $messages_ar = $session->get('messages');
	if (defined $messages_ar) {
		push @{$messages_ar}, $m;
	} else {
		$session->set('messages', [$m]);
	}

	return;
}

1;
