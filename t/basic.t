#!perl -T

use Test::More;

use strict;
use warnings;

$|=1;

use Math::GoldenBigMath;

package main;

use vars qw($TestsOk @NotValidTestList);

$TestsOk = 'true';
@NotValidTestList = ();

sub TestNotValid {
    my $message = shift;
    push (@NotValidTestList, $message);
    $TestsOk = '';
    warn $message;
}

sub PrintTestResults {

    diag "======================================================================";

    ok ($TestsOk, "All tests are valid!");
    diag "" . ($#NotValidTestList+1) . " test(s) are not valid:\n\n";
    foreach my $testMessage (@NotValidTestList) {
	diag "$testMessage\n";
    }
}

sub CheckZero {
    my $zero           = shift;
    my $expectedResult = shift;
    my $result = Math::GoldenBigMath->new($zero)->Normalize()->IsZero();

    my $message = "IsZero($zero)";
    if ($expectedResult eq $result) {
	diag "$message  = $result";
    }
    else {
	&TestNotValid ("$message -----------\n"
		       . "\texpected '$expectedResult'\n"
		       . "\tresult   '$result'\n");
    }
}

sub CheckCompare {
    my $bm1            = shift;
    my $bm2            = shift;
    my $expectedResult = shift;

    my $result = ($bm1 <=> $bm2);
    my $message = $bm1->SPrint(40) . "\n" 
	. ($result < 0 ? '<' : ($result > 0 ? '>': "==")) 
	. "\n" . $bm2->SPrint(40). "\n";
    if ($expectedResult == $result) {
	diag $message
	    ."----------------------------------------------------------------------";
    }
    else {
	&TestNotValid ("$message -----------\n"
		       . "\texpected '$expectedResult'\n"
		       . "\tresult   '$result'\n");
    }
}

sub CheckAlignExponents {
    my $bm1            = shift;
    my $bm2            = shift;

    $bm1->AlignExponents($bm2);

    $bm1->Print(40);
    $bm2->Print(40);

    diag "----------------------------------------------------------------------";

    # my $result = ($bm1 <=> $bm2);
    # my $message = $bm1->SPrint(40) . "\n" 
    # 	. ($result < 0 ? '<' : ($result > 0 ? '>': "==")) 
    # 	. "\n" . $bm2->SPrint(40). "\n";
    # if ($expectedResult == $result) {
    # 	diag $message
    # 	    ."----------------------------------------------------------------------\n";
    # }
    # else {
    # 	&TestNotValid ("$message -----------\n"
    # 		       . "\texpected '$expectedResult'\n"
    # 		       . "\tresult   '$result'\n");
    # }
}

my $bm01 = Math::GoldenBigMath->new("0")->SplitUp()->PrintDebug();
eval { my $bm02 = Math::GoldenBigMath->new("0.")->SplitUp()->PrintDebug(); };
eval { my $bm03 = Math::GoldenBigMath->new(".0")->SplitUp()->PrintDebug(); };
eval { my $bm04 = Math::GoldenBigMath->new(".")->SplitUp()->PrintDebug(); };
my $bm1 = Math::GoldenBigMath->new("123987")->SplitUp()->PrintDebug();
my $bm2 = Math::GoldenBigMath->new("+123987")->SplitUp()->PrintDebug();
my $bm3 = Math::GoldenBigMath->new("-123987")->SplitUp()->PrintDebug();
my $bm4 = Math::GoldenBigMath->new("123987.123")->SplitUp()->PrintDebug();
my $bm5 = Math::GoldenBigMath->new("+123987.123456")->SplitUp()->PrintDebug();
my $bm6 = Math::GoldenBigMath->new("-1239871234567890.1234567890")->SplitUp()->PrintDebug();
my $bm11 = Math::GoldenBigMath->new("123987")->SplitUp()->PrintDebug();
my $bm12 = Math::GoldenBigMath->new("+123987")->SplitUp()->PrintDebug();
my $bm13 = Math::GoldenBigMath->new("-123987")->SplitUp()->PrintDebug();
my $bm14 = Math::GoldenBigMath->new("123987.123")->SplitUp()->PrintDebug();
my $bm15 = Math::GoldenBigMath->new("+123987.123456")->SplitUp()->PrintDebug();
my $bm16 = Math::GoldenBigMath->new("-1239871234567890.1234567890")->SplitUp()->PrintDebug();
my $bm21 = Math::GoldenBigMath->new("123987e0")->SplitUp()->PrintDebug();
my $bm22 = Math::GoldenBigMath->new("+123987e-1")->SplitUp()->PrintDebug();
my $bm23 = Math::GoldenBigMath->new("-123987e+4")->SplitUp()->PrintDebug();
my $bm24 = Math::GoldenBigMath->new("123987.123e+1")->SplitUp()->PrintDebug();
my $bm25 = Math::GoldenBigMath->new("+123987.123456e-1")->SplitUp()->PrintDebug();
my $bm26 = Math::GoldenBigMath->new("-1239871234567890.1234567890e123456789012345")->SplitUp()->PrintDebug();
my $bm27 = Math::GoldenBigMath->new("-1239871234567890.12345678901e-123456789012345")->SplitUp()->PrintDebug();
my $bm28 = Math::GoldenBigMath->new("-1239871234567890.12345678901e+123456789012345");
$bm28->SplitUp()->PrintDebug();

diag "====================================";

&CheckZero("0", 'true');
&CheckZero("0.0", 'true');
&CheckZero("0.0E1", 'true');
eval { &CheckZero(".0", 'true'); };
eval { &CheckZero("0.", 'true'); };
&CheckZero("-00.000", 'true');
&CheckZero("-00.000E-001", 'true');
&CheckZero("-00.000E+001", 'true');
&CheckZero("-00.000E001", 'true');
&CheckZero("+00.000E-001", 'true');
&CheckZero("+00.000E+001", 'true');
&CheckZero("+00.000E001", 'true');
&CheckZero("00.000E-001", 'true');
&CheckZero("00.000E+011", 'true');
&CheckZero("00.000E101", 'true');

&CheckZero("01.000E101", '');
&CheckZero("00.001E101", '');
&CheckZero("1", '');
&CheckZero("+1", '');
&CheckZero("-1", '');
&CheckZero("1E101", '');

&CheckCompare($bm22, $bm23, 1);
&CheckCompare($bm23, $bm22, -1);
&CheckCompare($bm22, $bm22, 0);

$bm25->PrintDebug();
$bm25->MovePointOutsideLeft();
$bm25->PrintDebug();
$bm25->MovePointOutsideLeft();
$bm25->PrintDebug();

my $bm30 = Math::GoldenBigMath->new("-1239870000");
my $bm31 = Math::GoldenBigMath->new("-123987e+4");
my $bm32 = Math::GoldenBigMath->new("-12398.7e+5");
my $bm32a = Math::GoldenBigMath->new("-12398.7e-5");
my $bm33 = Math::GoldenBigMath->new("-12398.76543210987654321e+155");
my $bm34 = Math::GoldenBigMath->new("-1239.876543210987654321e+156");
my $bm35 = Math::GoldenBigMath->new("-12398.7654321098765432e+155");
my $bm36 = Math::GoldenBigMath->new("-12398.765432109876543211e+155");
my $bm37 = Math::GoldenBigMath->new("-12398.76543210987654321e+155123456788");
my $bm38 = Math::GoldenBigMath->new("-1239.876543210987654321e+155123456789");
my $bm39 = Math::GoldenBigMath->new("-1239.876543210987654321e+155123456788");
my $bm40 = Math::GoldenBigMath->new("-1239.876543210987654321e+99999999999");

&CheckCompare($bm22, $bm23, 1);
&CheckCompare($bm23, $bm22, -1);
&CheckCompare($bm22, $bm22, 0);

&CheckCompare($bm30, $bm30, 0);
&CheckCompare($bm31, $bm31, 0);
&CheckCompare($bm32, $bm32, 0);

&CheckCompare($bm30, $bm31, 0);
&CheckCompare($bm31, $bm32, 0);
&CheckCompare($bm32, $bm31, 0);
&CheckCompare($bm30, $bm32, 0);
&CheckCompare($bm32, $bm30, 0);

&CheckCompare($bm32, $bm32a, 1);

&CheckCompare($bm33, $bm33, 0);
&CheckCompare($bm33, $bm34, 0);
&CheckCompare($bm33, $bm35, 1);
&CheckCompare($bm33, $bm36, -1);

&CheckCompare($bm34, $bm34, 0);
&CheckCompare($bm34, $bm35, 1);
&CheckCompare($bm34, $bm36, -1);

&CheckCompare($bm35, $bm34, -1);
&CheckCompare($bm35, $bm35, 0);
&CheckCompare($bm35, $bm36, -1);

&CheckCompare($bm36, $bm34, 1);
&CheckCompare($bm36, $bm35, 1);
&CheckCompare($bm36, $bm36, 0);

&CheckCompare($bm37, $bm38, 0);
&CheckCompare($bm38, $bm37, 0);

&CheckCompare($bm39, $bm37, -1);
&CheckCompare($bm39, $bm38, -1);

&CheckCompare($bm40, $bm37, -1);
&CheckCompare($bm40, $bm38, -1);
&CheckCompare($bm40, $bm39, -1);

&CheckAlignExponents($bm30, $bm31);
&CheckAlignExponents($bm38, $bm39);

$bm38->MovePointOutsideRight();
$bm39->MovePointOutsideRight();
&CheckAlignExponents($bm38, $bm39);

&PrintTestResults();

done_testing;
