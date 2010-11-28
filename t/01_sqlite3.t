use strict;
use warnings;
use Test::More;
use Test::Requires 'DBD::SQLite';
use DBIx::Inspector;

my $dbh = DBI->connect('dbi:SQLite:', '', '', {RaiseError => 1}) or die;
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
is(join(",", sort $inspector->tables), 'post,user');
is(join(',', sort $inspector->columns_for('post')), 'body,post_id,user_id');
is(join(',', sort $inspector->pk_for('post')), 'post_id');

done_testing;

