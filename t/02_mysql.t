use strict;
use warnings;
use Test::More;
use Test::Requires 'Test::mysqld', 'DBD::mysql';
use DBIx::Inspector;

my $mysqld = Test::mysqld->new(
    my_cnf => {
        'skip-networking' => '',    # no TCP socket
    }
) or plan skip_all => $Test::mysqld::errstr;
my $dbh = DBI->connect($mysqld->dsn(dbname => 'test')) or die;
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
my $inspector = DBIx::Inspector->new(dbh => $dbh);
my @tables = $inspector->tables;
is(join(",", sort map { $_->name } @tables), 'post,user');
my ($post) = grep { $_->name eq 'post' } @tables;
isa_ok $post, 'DBIx::Inspector::Table';
ok $post;
is(join(',', sort map { $_->name } $post->columns), 'body,post_id,user_id');
is(join(',', sort map { $_->name } $post->primary_key), 'post_id');

done_testing;

