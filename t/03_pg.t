use strict;
use warnings;
use Test::More;
use Test::Requires 'Test::postgresql', 'DBD::Pg';
use DBIx::Inspector;

push @Test::postgresql::SEARCH_PATHS, '/Library/PostgreSQL/9.0/';

my $pgsql = Test::postgresql->new()
    or plan skip_all => $Test::postgresql::errstr;

my $dbh = DBI->connect($pgsql->dsn, undef, undef, {Warn => 0, RaiseError => 1}) or die;
$dbh->do(q{
    create table post (
        post_id int8 not null primary key,
        user_id int8,
        body varchar(255)
    );
});
$dbh->do(q{
    create table usr (
        user_id int8 not null primary key,
        name varchar(255)
    );
});
my $inspector = DBIx::Inspector->new(dbh => $dbh);
my @tables = $inspector->tables;
is(join(",", sort map { $_->name } @tables), 'post,usr');
my ($post) = grep { $_->name eq 'post' } @tables;
isa_ok $post, 'DBIx::Inspector::Table';
ok $post;
is $post->schema, 'public';
is $post->type, 'TABLE';
is(join(',', sort map { $_->name } $post->columns), 'body,post_id,user_id');
is(join(',', sort map { $_->name } $post->primary_key), 'post_id');

done_testing;

