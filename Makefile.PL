use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::ReadmeMarkdownFromPod;

name 'DBIx-Inspector';
all_from 'lib/DBIx/Inspector.pm';
readme_markdown_from 'lib/DBIx/Inspector.pm';

requires 'DBI';
requires "Class::Accessor::Lite";
requires 'Module::Load';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.98; # done_testing, subtest
test_requires 'Test::Requires';
author_tests('xt');
WriteAll;
