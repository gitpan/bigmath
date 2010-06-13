use inc::Module::Install;

name     'Math-GoldenBigMath';
all_from 'lib/Math/GoldenBigMath.pm';
author   q{Ralf Peine <ralf.peine@jupiter-program.de>};
license  'perl';

# this line in turn will need Module::Install::AuthorRequires
author_requires 'Module::Install::AuthorTests';

author_tests('xt');
test_requires 'Test::More' => 0.88;

auto_install;

WriteAll;

