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
is(join(",", sort $inspector->tables), 'post,usr');
is(join(',', sort $inspector->columns_for('post')), 'body,post_id,user_id');
is(join(',', sort $inspector->pk_for('post')), 'post_id');

done_testing;

