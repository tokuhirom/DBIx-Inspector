use strict;
use warnings;
use Test::More;
use Test::Requires 'DBD::SQLite';
use DBIx::Inspector;

my $dbh = DBI->connect('dbi:SQLite:', '', '', {RaiseError => 1}) or die;
$dbh->do(q{
    create table mk (
        k1 int,
        k2 int,
        PRIMARY KEY(k1, k2)
    );
});
$dbh->do(q{
    create table post (
        post_id int unsigned not null primary key,
        user_id int,
        body varchar(255)
    );
});
$dbh->do(q{
    create table user (
        user_id int unsigned not null,
        name varchar(255)
    );
});
$dbh->do(q{
    CREATE TEMPORARY TABLE t1 (a,b);
});
$dbh->do(q{
    CREATE VIEW t2 AS SELECT * FROM user;
});
my $inspector = DBIx::Inspector->new(dbh => $dbh);
my @tables = $inspector->tables();
is(join(",", sort map { $_->name } @tables), 'mk,post,user');
my ($post) = grep { $_->name eq 'post' } @tables;
ok $post;
is(join(',', sort map { $_->name } $post->columns), 'body,post_id,user_id');
is(join(',', sort map { $_->name } $post->primary_key), 'post_id');

my ($mk) = grep { $_->name eq 'mk' } @tables;
ok $mk;
is(join(',', sort map { $_->name } $mk->primary_key), 'k1,k2');

done_testing;

