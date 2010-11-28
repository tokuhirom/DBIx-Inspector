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
CREATE TABLE artist(
    artistid    INTEGER PRIMARY KEY, 
    artistname  TEXT
);
});
$dbh->do(q{
CREATE TABLE track(
    trackid     INTEGER,
    trackname   TEXT, 
    trackartist INTEGER,    -- Must map to an artist.artistid!
    FOREIGN KEY(trackartist) REFERENCES artist(artistid)
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
is(join(",", sort map { $_->name } @tables), 'artist,mk,post,track,user');
my ($post) = $inspector->tables('post');
ok $post;
is(join(',', sort map { $_->name } $post->columns), 'body,post_id,user_id');
is(join(',', sort map { $_->name } $post->primary_key), 'post_id');
subtest 'columns' => sub {
    subtest 'body' => sub {
        my $col = $post->column('body');
        is $col->data_type, undef;
        is $col->type_name, 'varchar';
        is $col->column_size, 255;
        is $col->column_def, undef;
    };
    subtest 'user_id' => sub {
        my $col = $post->column('user_id');
        is $col->data_type, undef;
        is $col->type_name, 'int';
        is $col->column_size, undef;
        is $col->column_def, undef;
    };
};

subtest 'multiple pk' => sub {
    my $mk = $inspector->table('mk');
    ok $mk;
    is(join(',', sort map { $_->name } $mk->primary_key), 'k1,k2');
};

done_testing;

