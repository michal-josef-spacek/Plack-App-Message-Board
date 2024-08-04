package Plack::App::Message::Board::Message;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Data::Message::Board;
use Data::Message::Board::Comment;
use DateTime;
use Plack::App::Message::Board::Utils qw(add_message);
use Plack::Request;
use Plack::Response;
use Plack::Session;
use Plack::Util::Accessor qw(add_comment_cb add_message_board_cb app_author footer lang
	message_board_cb redirect_message_board_save);
use Readonly;
use Tags::HTML::Container;
use Tags::HTML::Footer;
use Tags::HTML::Messages;
use Tags::HTML::Message::Board;
use Tags::HTML::Message::Board::Blank;

our $VERSION = 0.01;

sub _cleanup {
	my ($self, $env) = @_;

	$self->{'_tags_container'}->cleanup;
	$self->{'_tags_footer'}->cleanup;
	$self->{'_tags_messages'}->cleanup;
	$self->{'_tags_message_board'}->cleanup;
	$self->{'_tags_message_board_blank'}->cleanup;

	delete $self->{'_blank'};

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
	$self->{'_tags_message_board_blank'}->process_css;

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
	$self->{'_tags_message_board_blank'} = Tags::HTML::Message::Board::Blank->new(%p);
	$self->{'_tags_messages'} = Tags::HTML::Messages->new(%p,
		'flag_no_messages' => 0,
	);
	$self->{'_tags_footer'} = Tags::HTML::Footer->new(%p);

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	my $req = Plack::Request->new($env);

	# Message board id.
	my $id = $req->parameters->{'id'};

	# Process form.
	my $action = $req->parameters->{'action'};
	if (defined $action && $action eq 'add_message_board') {
		if (defined $self->add_message_board_cb) {
			my $message_board_message = $req->parameters->{'message_board_message'};
			$id = $self->add_message_board_cb->($self, Data::Message::Board->new(
				'author' => $self->app_author,
				'date' => DateTime->now,
				'message' => $message_board_message,
			));
			if (defined $self->redirect_message_board_save) {
				my $res = Plack::Response->new;
				my $redirect_message_board_save = $self->redirect_message_board_save;
				$res->redirect(sprintf $redirect_message_board_save, $id);
				$self->psgi_app($res->finalize);
			}
		} else {
			add_message(
				$env,
				'error',
				'No callback for message board adding.',
			);
		}
	} elsif (defined $action && $action eq 'add_message_board_comment') {
		my $message_board_comment_message = $req->parameters->{'message_board_comment_message'};
		if (defined $message_board_comment_message) {
			if (defined $self->add_comment_cb) {
				$self->add_comment_cb->($self, $id, Data::Message::Board::Comment->new(
					'author' => $self->app_author,
					'date' => DateTime->now,
					'message' => $message_board_comment_message,
				));
			} else {
				add_message(
					$env,
					'error',
					'No callback for message board comment adding.',
				);
			}
		} else {
			add_message(
				$env,
				'error',
				'No comment message.',
			);
		}
	}

	# Fetch mesaage board.
	$self->{'_blank'} = 1;
	if (defined $id) {
		if (! defined $self->message_board_cb) {
			add_message(
				$env,
				'error',
				'No callback for fetch message board.',
			);
		} else {
			my $message_board = $self->message_board_cb->($self, $id);
			if (! defined $message_board) {
				add_message(
					$env,
					'error',
					'Cannot found message board.',
				);
			} else {
				$self->{'_tags_message_board'}->init($message_board);
				$self->{'_blank'} = 0;
			}
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
	if ($self->{'_blank'}) {
		$self->{'_tags_message_board_blank'}->process;
	} else {
		$self->{'_tags_message_board'}->process;
	}
	$self->{'tags'}->put(
		['e', 'div'],
	);

	$self->{'_tags_footer'}->process;

	return;
}

1;

__END__
