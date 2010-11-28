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
is(join(",", sort $inspector->tables), 'post,user');
is(join(',', sort $inspector->columns_for('post')), 'body,post_id,user_id');
is(join(',', sort $inspector->pk_for('post')), 'post_id');

done_testing;

