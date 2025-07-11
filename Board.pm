package Plack::App::Message::Board;

use base qw(Plack::Component);
use strict;
use warnings;

use CPAN::Changes::Utils qw(construct_copyright_years);
use Data::HTML::Footer;
use List::Util qw(max min);
use Plack::App::CPAN::Changes 0.03;
use Plack::App::Message::Board::List;
use Plack::App::Message::Board::Message;
use Plack::App::URLMap;
use Plack::Session;
use Plack::Util::Accessor qw(cb_add_comment cb_add_message_board app_author changes css images
	lang cb_message_board cb_message_boards redirect_message_board_save tags);
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.12;

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
		'lang' => $self->lang,
		'tags' => $self->tags,
	);

	my ($version, $copyright_years);
	if (defined $self->changes) {
		$version = ($self->changes->releases)[-1]->version;
		$copyright_years = construct_copyright_years($self->changes);
	}

	my $changes_url = '/changes';
	my $footer = Data::HTML::Footer->new(
		'author' => decode_utf8('Michal Josef Špaček'),
		'author_url' => 'https://skim.cz',
		defined $copyright_years ? (
			'copyright_years' => $copyright_years,
		) : (),
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
		'cb_message_boards' => $self->cb_message_boards,
	)->to_app;
	my $app_message = Plack::App::Message::Board::Message->new(
		%common_params,
		'cb_add_comment' => $self->cb_add_comment,
		'cb_add_message_board' => $self->cb_add_message_board,
		'app_author' => $self->app_author,
		'cb_message_board' => $self->cb_message_board,
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
