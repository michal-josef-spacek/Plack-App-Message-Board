#!/usr/bin/env perl

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