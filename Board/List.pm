package Plack::App::Message::Board::List;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Data::HTML::Element::A;
use Plack::App::Message::Board::Utils qw(add_message);
use Plack::Request;
use Plack::Session;
use Plack::Util::Accessor qw(footer lang message_boards_cb);
use Readonly;
use Tags::HTML::Container;
use Tags::HTML::Footer 0.03;
use Tags::HTML::Messages;
use Tags::HTML::Table::View;

our $VERSION = 0.05;

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
	$self->{'_tags_messages'} = Tags::HTML::Messages->new(%p,
		'flag_no_messages' => 0,
	);
	$self->{'_tags_table'} = Tags::HTML::Table::View->new(%p);
	if (defined $self->footer) {
		$self->{'_tags_footer'} = Tags::HTML::Footer->new(%p);
	}

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	# Process table data.
	$self->{'_table_data'} = [];
	push @{$self->{'_table_data'}}, [
		'Id',
		'Author',
		'Date',
		'Message',
		'Number of comments',
	];
	if (defined $self->message_boards_cb) {
		my @message_boards = $self->message_boards_cb->();
		foreach my $mb (@message_boards) {
			push @{$self->{'_table_data'}}, [
				Data::HTML::Element::A->new(
					'data' => [$mb->id],
					'url' => '/message?id='.$mb->id,
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
			'No callback for message board list.',
		);
	}

	if (defined $self->footer) {
		$self->{'_tags_footer'}->init($self->footer);
	}
	$self->{'_tags_table'}->init($self->{'_table_data'}, 'No messages.');

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
		['a', 'href', '/message'],
		['d', 'Add new message'],
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
