use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::ReadmeMarkdownFromPod;

name 'DBIx-Inspector';
all_from 'lib/DBIx/Inspector.pm';
readme_markdown_from 'lib/DBIx/Inspector.pm';

requires 'DBI';
requires "Class::Accessor::Lite";

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
author_tests('xt');
WriteAll;
