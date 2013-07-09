requires 'Class::Accessor::Lite';
requires 'DBI';
requires 'Module::Load';
requires 'perl', '5.008001';

on build => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Requires';
};
