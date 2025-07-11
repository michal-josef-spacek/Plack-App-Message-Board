package Plack::App::Message::Board::List;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Data::HTML::Element::A;
use List::Util 1.33 qw(any);
use Plack::App::Message::Board::Utils qw(add_message);
use Plack::Request;
use Plack::Session;
use Plack::Util::Accessor qw(cb_message_boards footer lang);
use Readonly;
use Tags::HTML::Container;
use Tags::HTML::Footer 0.03;
use Tags::HTML::Messages;
use Tags::HTML::Table::View;
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.12;

sub _cleanup {
	my ($self, $env) = @_;

	$self->{'_tags_container'}->cleanup;
	if (defined $self->footer) {
		$self->{'_tags_footer'}->cleanup;
	}
	$self->{'_tags_messages'}->cleanup;
	$self->{'_tags_table'}->cleanup;

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
	$self->{'_tags_table'}->process_css;

	$self->{'css'}->put(
		['s', '#main'],
		['d', 'margin', '1em'],
		['d', 'font-family', 'Arial, Helvetica, sans-serif'],
		['e'],

		['s', '.links'],
		['d', 'margin-bottom', '1em'],
		['e'],
	);

	return;
}

sub _lang {
	my ($self, $key) = @_;

	$self->{'_lang'} = {
		'cze' => {
			'add_new_message' => decode_utf8('Přidej novou zprávu'),
			'author' => 'Autor',
			'date' => 'Datum',
			'error_no_cb_meassage_board_list' => decode_utf8('Není callback pro seznam nástěnek.'),
			'id' => 'Id',
			'message' => decode_utf8('Zpráva'),
			'no_message_boards' => decode_utf8('Nejsou nástěnky'),
			'number_of_comments' => decode_utf8('Počet komentářů'),
		},
		'eng' => {
			'add_new_message' => 'Add new message',
			'author' => 'Author',
			'date' => 'Date',
			'error_no_cb_meassage_board_list' => 'No callback for message board list.',
			'id' => 'Id',
			'message' => 'Message',
			'no_message_boards' => 'No message boards.',
			'number_of_comments' => 'Number of comments',
		},
	};

	return $self->{'_lang'}->{$self->lang}->{$key};
}

sub _prepare_app {
	my $self = shift;

	# Inherite defaults.
	$self->SUPER::_prepare_app;

	if (! defined $self->lang) {
		$self->lang('eng');
	}
	$self->{'_app_default_lang'} = $self->lang;

	my %p = (
		'css' => $self->css,
		'tags' => $self->tags,
	);
	$self->{'_tags_container'} = Tags::HTML::Container->new(%p,
		'height' => '1%',
		'padding' => '0.5em',
		'vert_align' => 'top',
	);
	$self->{'_tags_messages'} = Tags::HTML::Messages->new(%p,
		'flag_no_messages' => 0,
	);
	$self->{'_tags_table'} = Tags::HTML::Table::View->new(%p);
	if (defined $self->footer) {
		$self->{'_tags_footer'} = Tags::HTML::Footer->new(%p);
	}

	$self->{'_link'}->{'message'} = '/message';

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	my $req = Plack::Request->new($env);

	# Message board lang.
	my $lang = $req->parameters->{'lang'};
	if (defined $lang && any { $lang eq $_ } qw(cze eng)) {
		$self->lang($lang);
		$self->{'_link'}->{'message'} = '/message?lang='.$lang;
	} else {
		$self->lang($self->{'_app_default_lang'});
		$self->{'_link'}->{'message'} = '/message';
	}

	# Process table data.
	$self->{'_table_data'} = [];
	push @{$self->{'_table_data'}}, [
		$self->_lang('id'),
		$self->_lang('author'),
		$self->_lang('date'),
		$self->_lang('message'),
		$self->_lang('number_of_comments'),
	];
	if (defined $self->cb_message_boards) {
		my @message_boards = $self->cb_message_boards->();
		foreach my $mb (@message_boards) {

			my $url;
			if ($self->{'_link'}->{'message'} =~ m/\?/ms) {
				$url = $self->{'_link'}->{'message'}.'&';
			} else {
				$url = $self->{'_link'}->{'message'}.'?';
			}
			$url .= 'id='.$mb->id;

			push @{$self->{'_table_data'}}, [
				Data::HTML::Element::A->new(
					'data' => [$mb->id],
					'url' => $url,
				),
				$mb->author->name,
				$mb->date->ymd.' '.$mb->date->hms,
				$mb->message,
				scalar @{$mb->comments},
			],
		}
	} else {
		add_message(
			$env,
			'error',
			$self->_lang('error_no_cb_meassage_board_list'),
		);
	}

	if (defined $self->footer) {
		$self->{'_tags_footer'}->init($self->footer);
	}
	$self->{'_tags_table'}->init($self->{'_table_data'}, $self->_lang('no_message_boards'));

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

		# Add new message.
		['b', 'div'],
		['a', 'class', 'links'],
		['b', 'a'],
		['a', 'href', $self->{'_link'}->{'message'}],
		['d', $self->_lang('add_new_message')],
		['e', 'a'],
		['e', 'div'],
	);
	$self->{'_tags_table'}->process;
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
