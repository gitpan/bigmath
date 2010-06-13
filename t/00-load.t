#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Math::GoldenBigMath' ) || print "Bail out!
";
}

diag( "Testing Math::GoldenBigMath $Math::GoldenBigMath::VERSION, Perl $], $^X" );
