package Plack::App::Message::Board;

use base qw(Plack::Component);
use strict;
use warnings;

use Data::HTML::Footer;
use List::Util qw(max min);
use Plack::App::CPAN::Changes 0.03;
use Plack::App::Message::Board::List;
use Plack::App::Message::Board::Message;
use Plack::App::URLMap;
use Plack::Session;
use Plack::Util::Accessor qw(add_comment_cb add_message_board_cb app_author changes css images
	lang message_board_cb message_boards_cb redirect_message_board_save tags);
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.08;

sub call {
	my ($self, $env) = @_;

	my $session = Plack::Session->new($env);

	# Main application.
	return $self->{'_urlmap'}->to_app->($env);
}

sub prepare_app {
	my $self = shift;

	my %p = (
		'css' => $self->css,
		'lang' => 'cze',
		'tags' => $self->tags,
	);

	my ($version, $copyright_years);
	if (defined $self->changes) {
		$version = ($self->changes->releases)[-1]->version;
		my @years = map { $_->date =~ m/^(\d{4})/ms; defined $1 ? $1 : () }
			grep { defined $_ && defined $_->date }
			$self->changes->releases;
		my $year_from = min(@years);
		my $year_to = max(@years);
		if (defined $year_from) {
			$copyright_years = $year_from;
			if ($year_from != $year_to) {
				$copyright_years .= '-'.$year_to;
			}
		}
	}

	my $changes_url = '/changes';
	my $footer = Data::HTML::Footer->new(
		'author' => decode_utf8('Michal Josef Špaček'),
		'author_url' => 'https://skim.cz',
		'copyright_years' => $copyright_years,
		'height' => '40px',
		defined $version ? (
			'version' => $version,
		) : (),
		defined $self->changes ? (
			'version_url' => $changes_url,
		) : (),
	);
	my %common_params = (
		%p,
		'footer' => $footer,
	);

	my $app_list = Plack::App::Message::Board::List->new(
		%common_params,
		'message_boards_cb' => $self->message_boards_cb,
	)->to_app;
	my $app_message = Plack::App::Message::Board::Message->new(
		%common_params,
		'add_comment_cb' => $self->add_comment_cb,
		'add_message_board_cb' => $self->add_message_board_cb,
		'app_author' => $self->app_author,
		'message_board_cb' => $self->message_board_cb,
		'redirect_message_board_save' => $self->redirect_message_board_save,
	)->to_app;
	my $app_changes;
	if (defined $self->changes) {
		$app_changes = Plack::App::CPAN::Changes->new(
			%p,
			'changes' => $self->changes,
		)->to_app;
	}

	$self->{'_urlmap'} = Plack::App::URLMap->new;
	$self->{'_urlmap'}->map('/' => $app_list);
	$self->{'_urlmap'}->map('/message' => $app_message);
	if (defined $self->changes) {
		$self->{'_urlmap'}->map($changes_url => $app_changes);
	}

	return;
}

1;

__END__
