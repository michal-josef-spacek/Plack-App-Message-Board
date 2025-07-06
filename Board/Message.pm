package Plack::App::Message::Board::Message;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Data::Message::Board;
use Data::Message::Board::Comment;
use DateTime;
use List::Util 1.33 qw(any);
use Plack::App::Message::Board::Utils qw(add_message);
use Plack::Request;
use Plack::Response;
use Plack::Session;
use Plack::Util::Accessor qw(app_author cb_add_comment cb_add_message_board cb_message_board
	footer lang redirect_message_board_save);
use Readonly;
use Tags::HTML::Container;
use Tags::HTML::Footer 0.03;
use Tags::HTML::Messages;
use Tags::HTML::Message::Board;
use Tags::HTML::Message::Board::Blank;
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.11;

sub _cleanup {
	my ($self, $env) = @_;

	$self->{'_tags_container'}->cleanup;
	if (defined $self->footer) {
		$self->{'_tags_footer'}->cleanup;
	}
	$self->{'_tags_messages'}->cleanup;
	$self->{'_tags_message_board'}->cleanup;
	$self->{'_tags_message_board_blank'}->cleanup;

	delete $self->{'_blank'};

	return;
}

sub _css {
	my ($self, $env) = @_;

	$self->{'_tags_container'}->process_css;
	if (defined $self->footer) {
		$self->{'_tags_footer'}->process_css;
	}
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
			'error_no_cb_comment_adding' => decode_utf8('Není callack pro přidání komentáře.'),
			'error_no_cb_fetch_message_board' => decode_utf8('Není callback pro získání nástěnky.'),
			'error_no_cb_message_board_adding' => decode_utf8('Není callback pro přidání nástěnky.'),
			'error_no_comment_message' => decode_utf8('Není komentář.'),
			'error_no_message_board' => decode_utf8('Nástěnka nenalezena.'),
		},
		'eng' => {
			'error_no_cb_comment_adding' => 'No callback for message board comment adding.',
			'error_no_cb_fetch_message_board' => 'No callback for fetch message board.',
			'error_no_cb_message_board_adding' => 'No callback for message board adding.',
			'error_no_comment_message' => 'No comment message.',
			'error_no_message_board' => 'Cannot found message board.',
		},
	};

	return $self->{'_lang'}->{$self->lang}->{$key};
}

sub _lang_blank {
	my $self = shift;

	my $lang_hr = {
		'cze' => {
			'add_message_board' => decode_utf8('Přidat nástěnku'),
			'save' => decode_utf8('Uložit'),
		},
		'eng' => {
			'add_message_board' => 'Add message board',
			'save' => 'Save',
		},
	};

	return $lang_hr;
}

sub _lang_board {
	my $self = shift;

	my $lang_hr = {
		'cze' => {
			'add_comment' => decode_utf8('Přidat komentář'),
			'author' => 'Autor',
			'date' => 'Datum',
			'save' => decode_utf8('Uložit'),
		},
		'eng' => {
			'add_comment' => 'Add comment',
			'author' => 'Author',
			'date' => 'Date',
			'save' => 'Save',
		},
	};

	return $lang_hr;
}

sub _prepare_app {
	my $self = shift;

	# Inherite defaults.
	$self->SUPER::_prepare_app;

	if (! defined $self->lang) {
		$self->lang('eng');
	}

	my %p = (
		'css' => $self->css,
		'tags' => $self->tags,
	);
	$self->{'_tags_container'} = Tags::HTML::Container->new(%p,
		'height' => '1%',
		'padding' => '0.5em',
		'vert_align' => 'top',
	);
	$self->_prepare_lang;
	$self->{'_tags_messages'} = Tags::HTML::Messages->new(%p,
		'flag_no_messages' => 0,
	);
	if (defined $self->footer) {
		$self->{'_tags_footer'} = Tags::HTML::Footer->new(%p);
	}

	return;
}

sub _prepare_lang {
	my $self = shift;

	my %p = (
		'css' => $self->css,
		'tags' => $self->tags,
	);
	$self->{'_tags_message_board'} = Tags::HTML::Message::Board->new(%p,
		'lang' => $self->lang,
		'text' => $self->_lang_board,
	);
	$self->{'_tags_message_board_blank'} = Tags::HTML::Message::Board::Blank->new(%p,
		'lang' => $self->lang,
		'text' => $self->_lang_blank,
	);

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	my $req = Plack::Request->new($env);

	# Message board id.
	my $id = $req->parameters->{'id'};

	# Message board lang.
	my $lang = $req->parameters->{'lang'};
	if (defined $lang && any { $lang eq $_ } qw(cze eng)) {
		$self->lang($lang);
		$self->_prepare_lang;
	}

	# Process form.
	my $action = $req->parameters->{'action'};
	if (defined $action && $action eq 'add_message_board') {
		if (defined $self->cb_add_message_board) {
			my $message_board_message = decode_utf8($req->parameters->{'message_board_message'});
			$id = $self->cb_add_message_board->($self, Data::Message::Board->new(
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
				$self->_lang('error_no_cb_message_board_adding'),
			);
		}
	} elsif (defined $action && $action eq 'add_message_board_comment') {
		my $message_board_comment_message = decode_utf8($req->parameters->{'message_board_comment_message'});
		if (defined $message_board_comment_message) {
			if (defined $self->cb_add_comment) {
				$self->cb_add_comment->($self, $id, Data::Message::Board::Comment->new(
					'author' => $self->app_author,
					'date' => DateTime->now,
					'message' => $message_board_comment_message,
				));
			} else {
				add_message(
					$env,
					'error',
					$self->_lang('error_no_cb_comment_adding'),
				);
			}
		} else {
			add_message(
				$env,
				'error',
				$self->_lang('error_no_comment_message'),
			);
		}
	}

	# Fetch mesaage board.
	$self->{'_blank'} = 1;
	if (defined $id) {
		if (! defined $self->cb_message_board) {
			add_message(
				$env,
				'error',
				$self->_lang('error_no_cb_fetch_message_board'),
			);
		} else {
			my $message_board = $self->cb_message_board->($self, $id);
			if (! defined $message_board) {
				add_message(
					$env,
					'error',
					$self->_lang('error_no_message_board'),
				);
			} else {
				$self->{'_tags_message_board'}->init($message_board);
				$self->{'_blank'} = 0;
			}
		}
	}

	if (defined $self->footer) {
		$self->{'_tags_footer'}->init($self->footer);
	}

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

	if (defined $self->footer) {
		$self->{'_tags_footer'}->process;
	}

	return;
}

1;

__END__
