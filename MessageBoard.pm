package Plack::App::MessageBoard;

use base qw(Plack::Component::Tags::HTML);
use strict;
use warnings;

use Plack::Util::Accessor qw(css generator images lang tags);

our $VERSION = 0.01;

sub _cleanup {
	my $self = shift;

	return;
}

sub _css {
	my $self = shift;

	return;
}

sub _prepare_app {
	my $self = shift;

	return;
}

sub _process_actions {
	my ($self, $env) = @_;

	return;
}

sub _tags_middle {
	my $self = shift;

	return;
}

1;

__END__
