package Plack::App::Message::Board::Message;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Plack::App::Message::Board::Utils qw(add_message);
use Plack::Request;
use Plack::Session;
use Plack::Util::Accessor qw(data footer lang);
use Readonly;
use Tags::HTML::Container;
use Tags::HTML::Footer;
use Tags::HTML::Messages;
use Tags::HTML::Message::Board;

our $VERSION = 0.01;

sub _cleanup {
	my ($self, $env) = @_;

	$self->{'_tags_container'}->cleanup;
	$self->{'_tags_footer'}->cleanup;
	$self->{'_tags_messages'}->cleanup;
	$self->{'_tags_message_board'}->cleanup;

	return;
}

sub _css {
	my ($self, $env) = @_;

	$self->{'_tags_container'}->process_css;
	$self->{'_tags_footer'}->process_css;
	$self->{'_tags_messages'}->process_css({
		'error' => 'red',
		'info' => 'green',
	});
	$self->{'_tags_message_board'}->process_css;

	return;
}

sub _lang {
	my ($self, $key) = @_;

	$self->{'_lang'} = {
		'cze' => {
			'version' => 'Verze',
		},
		'eng' => {
			'version' => 'Version',
		},
	};

	return $self->{'_lang'}->{$self->lang}->{$key};
}

sub _prepare_app {
	my $self = shift;

	# Inherite defaults.
	$self->SUPER::_prepare_app;

	my %p = (
		'css' => $self->css,
		'tags' => $self->tags,
	);
	$self->{'_tags_container'} = Tags::HTML::Container->new(%p,
		'height' => '1%',
		'padding' => '0.5em',
		'vert_align' => 'top',
	);
	$self->{'_tags_message_board'} = Tags::HTML::Message::Board->new(%p);
	$self->{'_tags_messages'} = Tags::HTML::Messages->new(%p,
		'flag_no_messages' => 0,
	);
	$self->{'_tags_footer'} = Tags::HTML::Footer->new(%p);

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	my $req = Plack::Request->new($env);

	# TODO Process form.

	# Get mesaage board.
	my $id = $req->parameters->{'id'};
	if (defined $id) {
		my ($message_board) = grep { $_->id eq $id } @{$self->data};
		if (! defined $message_board) {
			add_message(
				$self,
				$env,
				'error',
				'Cannot found message board.',
			);
		} else {
			$self->{'_tags_message_board'}->init($message_board);
		}
	}

	$self->{'_tags_footer'}->init($self->footer);

	return;
}

sub _tags_middle {
	my ($self, $env) = @_;

	# Process messages.
	my $messages_ar = [];
	if (exists $env->{'psgix.session'}) {
		my $session = Plack::Session->new($env);
		$messages_ar = $session->get('messages');
		$session->set('messages', []);
	}
	$self->{'_tags_container'}->process(
		sub {
			$self->{'_tags_messages'}->process($messages_ar);
		},
	);

	# Main.
	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'id', 'main'],
	);
	$self->{'_tags_message_board'}->process;
	$self->{'tags'}->put(
		['e', 'div'],
	);

	$self->{'_tags_footer'}->process;

	return;
}

1;

__END__
