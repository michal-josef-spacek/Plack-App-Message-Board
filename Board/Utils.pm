package Plack::App::Message::Board::Utils;

use base qw(Exporter);
use strict;
use warnings;

use Data::Message::Simple;
use Plack::Session;
use Readonly;

Readonly::Array our @EXPORT_OK => qw(add_message);

our $VERSION = 0.07;

sub add_message {
	my ($env, $message_type, $message) = @_;

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

__END__

=pod

=encoding utf8

=head1 NAME

Plack::App::Message::Board::Utils - Utilities for Plack::App::Message::Board.

=head1 SYNOPSIS

 use Plack::App::Message::Board::Utils qw(add_message);

 add_message($env, $message_type, $message);

=head1 SUBROUTINES

=head2 C<add_message>

 add_message($env, $message_type, $message);

Add message to L<Plack::Session> defined by L<Plack> C<$env> variable.

Possible C<$message_type> values are:

=over

=item info

For info messages. This is default in case that C<$message_type> is undef.

=item error

For error messages.

=back

Message defined by C<$message> could be 4096 characters long.

Returns undef.

=head1 ERRORS

 add_message():
         From Data::Message::Simple->new():
                 Parameter 'text' has length greater than '4096'.
                         Value: %s
                 Parameter 'text' is required.
                         Value: %s
                 Parameter 'type' must be one of defined strings.
                         String: %s
                         Possible strings: %s

=head1 EXAMPLE1

=for comment filename=add_message_example.pl

 use strict;
 use warnings;

 use Data::Printer;
 use Plack::App::Message::Board::Utils qw(add_message);

 # Plack env variable.
 my $env = {
        'psgix.session' => {
                'messages' => [],
        },
 };

 # Add message.
 add_message($env, 'error', 'This is error message.');

 # Dump env variable.
 p $env;

 # Output like:
 # {
 #     psgix.session   {
 #         messages   [
 #             [0] Data::Message::Simple  {
 #                     parents: Mo::Object
 #                     public methods (6):
 #                         BUILD
 #                         Mo::utils:
 #                             check_length, check_required, check_strings
 #                         Mo::utils::Language:
 #                             check_language_639_1
 #                         Readonly:
 #                             Readonly
 #                     private methods (0)
 #                     internals: {
 #                         text   "This is error message.",
 #                         type   "error"
 #                     }
 #                 }
 #         ]
 #     }
 # }

=head1 DEPENDENCIES

L<Data::Message::Simple>,
L<Exporter>,
L<Plack::Session>,
L<Readonly>.

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/Plack-App-Message-Board>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2024 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.07

=cut
