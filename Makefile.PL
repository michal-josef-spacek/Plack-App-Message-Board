use lib '.';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'Plack application for message board.';
author 'Michal Josef Spacek <skim@cpan.org>';
author_requires 'English' => 0;
author_requires 'File::Object' => 0;
author_requires 'Test::More' => 0;
author_requires 'Test::NoWarnings' => 0;
author_requires 'Test::Pod' => 0;
author_requires 'Test::Pod::Coverage' => 0;
license 'bsd';
name 'Plack-App-Message-Board';
perl_version 5.008;
readme_from 'Board.pm';
recursive_author_tests('xt');
requires 'Data::HTML::Element::A' => 0;
requires 'Data::HTML::Footer' => 0;
requires 'Data::Message::Simple' => 0;
requires 'Exporter' => 0;
requires 'Plack::App::CPAN::Changes' => 0;
requires 'Plack::App::URLMap' => 0;
requires 'Plack::Component' => 0;
requires 'Plack::Component::Tags::HTML' => 0.15;
requires 'Plack::Request' => 0;
requires 'Plack::Session' => 0;
requires 'Plack::Util::Accessor' => 0;
requires 'Readonly' => 0;
requires 'Tags::HTML::Container' => 0;
requires 'Tags::HTML::Footer' => 0;
requires 'Tags::HTML::Messages' => 0;
requires 'Tags::HTML::Message::Board' => 0;
requires 'Tags::HTML::Table::View' => 0;
requires 'Unicode::UTF8' => 0;
resources 'bugtracker' => 'https://github.com/michal-josef-spacek/Plack-App-Message-Board/issues';
resources 'homepage' => 'https://github.com/michal-josef-spacek/Plack-App-Message-Board';
resources 'repository' => 'git://github.com/michal-josef-spacek/Plack-App-Message-Board';
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
