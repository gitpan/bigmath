package Math::GoldenBigMath;

use strict;
use warnings;

our $VERSION = '0.09';

# stop calculation of division if digit count >= $_maxDivDigits
our $_maxDivDigits = 100000;
# our $maxDivDigits = 100;

# --- overloads ------------------- sub ----------------------------------------

# define usual mathematic operators
use overload
    '+'   => \&Addition,		# sub 
    '-'   => \&Subtraction,		# sub 
    '*'   => \&Multiplication,		# sub 
    '/'   => \&Division,		# sub 
    '%'   => \&DivisionModulus,		# sub 
    '=='  => \&CompareEqual,		# sub 
    '>'   => \&Greater,			# sub 
    '<'   => \&Smaller,			# sub 
    '>='  => \&GreaterEqual,		# sub 
    '<='  => \&SmallerEqual,		# sub 
    '<=>' => \&CompareOperator;		# sub 

# --- creating, getting and setting sub (s) ------------------------------------

sub new {
    my $self = shift;

    my $type = ref($self)  ||  $self;
    my $number = shift;
    $number = "0" unless $number;
    my $elem = bless {}, $type; 
    $elem->SetValue($number); 
    return $elem;
}

# stop calculation of division if digit count >= $self->{'_maxDivideDigits'}
sub SetMaxDivideDigits {
    my $self = shift;
    $self->{'_maxDivideDigits'} = shift;
}

# stop calculation of division if digit count >= $self->{'_maxDivideDigits'}
sub GetMaxDivideDigits {
    my $self = shift;

    my $maxDivDigits = $self->{'_maxDivideDigits'};
    $maxDivDigits = $_maxDivDigits unless defined $maxDivDigits;

    return $maxDivDigits;
}

# return value of GBM as string
sub GetValue {
    my $self = shift;
    my $digits = shift; # nbr of minimum string length for result
    my $val = $self->{'_val'};
    if (defined $digits  &&  $digits > 0) {
	if (length($val) < $digits) {
	    $val = ' ' x ($digits - length($val)) . $val;
	}
    }

    $val .= '0' unless $val =~ /\d/;

    return $val;
}

sub SetValue {
    my $self = shift;
    $self->_setValueNoSplit(shift);
    $self->SplitUp();
}

sub _setValueNoSplit {
    my $self = shift;
    $self->{'_val'} = shift;
}

sub GetSign {
    my $self = shift;
    return ${$self->{'_sign'}};
}

sub GetZ {
    my $self = shift;
    return ${$self->{'_z'}};
}

sub GetF {
    my $self = shift;
    return ${$self->{'_f'}};
}

sub GetExponent {
    my $self = shift;
    return ${$self->{'_exp'}};
}

sub GetExponentSign {
    my $self = shift;
    return ${$self->{'_expSign'}};
}

sub _setSign {
    my $self = shift;
    my $s = shift;
    $self->{'_sign'} = \$s;
}

sub _setZ {
    my $self = shift;
    my $z = shift;
    $self->{'_z'} = \$z;
}

sub _setF {
    my $self = shift;
    my $f = shift;
    $self->{'_f'} = \$f;
}

sub _setExponent {
    my $self = shift;
    my $exp = shift;
    $self->{'_exp'} = \$exp;
}

sub _setExponentSign {
    my $self = shift;
    my $s = shift;
    $self->{'_expSign'} = \$s;
}

# FB-EXP-Split ## Aufsplitten in Zahl und Exponent
sub SplitUp {
    my $self = shift;
    my $val = $self->{'_val'};
    my $sign;
    my $z;
    my $f;
    my $expSign;
    my $exp;

    ($z,       $exp) = &ExtractExponent($self->{'_val'});
    ($sign,    $z)   = &ExtractSign($z);
    ($z,       $f)   = &SplitPoint($z);
    ($expSign, $exp) = &ExtractSign($exp);

    $self->{'_sign'}    = \$sign;
    $self->{'_z'}       = \$z;
    $self->{'_f'}       = \$f;
    $self->{'_exp'}     = \$exp;
    $self->{'_expSign'} = \$expSign;
    return $self;
}

sub ExtractSign {
    my $z = shift;
    my $sign = '+';
    if ($z =~ /[\+\-]/o) {
	if ($z =~ /^\s*([\+\-])(.*)/o) {
	    $sign = $1;
	    $z = $2;
	}
	else {
	    die ('Sign found at wrong position: ' . $z);
	}
    }
    return $sign, $z;
}

sub ExtractExponent {
    my $z = shift;
    my $exp = '0';
    if ($z =~ /[Ee]/o) {
	if ($z =~ /^\s*([\+\-\d\.]+)[Ee]([\+\-\d]+)\s*$/o) {
	    $z = $1;
	    $exp = $2;
	}
	else {
	    die ('More than one "e" found in real number: ' . $z);
	}
    }
    return $z, $exp;
}

sub SplitPoint {
    my $z = shift;
    my $f = '0';
    if ($z =~ /\./o) {
	if ($z =~ /^\s*(\d+)\.(\d*)\s*$/o) {
	    $z = $1;
	    $f = $2;
	    $f = 0 unless $f;
	}
	else {
	    die ('More than one "." found in real number: ' . $z);
	}
    }
    return $z, $f;
}

# print out value formatted
sub SPrint {
    my $self = shift;
    my $digits = shift;  # nbr of digits to print in a row, optional
    my $string = $self->GetValue($digits);
    
    if (defined($digits)  &&  length($string) > $digits) {
	while (length($string) > $digits) {
	    print substr($string, 0, $digits) , "\n";
	    $string = substr($string, $digits);
	}
    }
    return $string;
}

sub Print {
    my $self = shift;
    
    print $self->SPrint(@_)."\n";
}

sub _setZ1 {
    my $self = shift;
    $self->{'_z1'} = shift;
}

sub GetZ1 {
    my $self = shift;
    return $self->{'_z1'};
}

sub _setZ2 {
    my $self = shift;
    $self->{'_z2'} = shift;
}

sub GetZ2 {
    my $self = shift;
    return $self->{'_z2'};
}

sub _storeU {
    my $self = shift;
    $self->{'_u'} = shift;
}

sub GetU {
    my $self = shift;
    return $self->{'_u'};
}

sub _setMulTab {
    my $self = shift;
    $self->{'_mulTab'} = shift;
}

sub GetMulTab {
    my $self = shift;
    return $self->{'_mulTab'};
}

sub _storeOperatorName {
    my $self = shift;
    $self->{'_operatorName'} = shift;
}

sub GetOperatorName {
    my $self = shift;
    return $self->{'_operatorName'};
}

sub _storeOperator {
    my $self = shift;
    $self->{'_operator'} = shift;
}

sub GetOperator {
    my $self = shift;
    return $self->{'_operator'};
}

# --- printing sub (s) ---------------------------------------------------------
# --- print operation, that created the number ----
sub PrintCreatorOperation {
    my $self = shift;

    my $op = $self->GetOperator();

    if (defined $op)
    {
	my $resultLength = length($self->GetValue());
	$resultLength++;
	my $result = $self->GetValue();
	$result = '0' x ($resultLength - length($result)) . $result;
	print " -- " . $self->GetOperator() . " -- \n" .
	    $self->GetZ1()->GetValue($resultLength) . "\n" .
	    $self->GetZ2()->GetValue($resultLength) . "\n" .
	    '-' x $resultLength . "\n" .
	    ' ' . $self->GetU() . "\n" .
	    '=' x $resultLength . "\n" .
	    ' ' . $self->GetValue() . "\n\n";
    }
    else {
	print " ?? noOp ?? \n" .
	    $self->GetValue() . "\n\n";
    }
}

sub PrintDebug {
    my $self = shift;
    print "#------------------------------------------------------------------------------\n";
    print $self->{'_val'}."\n";
    print $self->GetSign().$self->GetZ().'.'.$self->GetF()
	."E".$self->GetExponentSign().$self->GetExponent()."\n";
    foreach my $key (sort(keys(%$self))) {
	next if $key eq '_val';
	my $val = $self->{$key};
	unless (ref $val) {
	    # make ref if value is no ref
	    print "$key:\t\t$val\n";
	}
	else {
	    print "$key:\t\t$$val\n";
	}
    }
    return $self;
}

# --- helping sub (s) ----

# add leading zeros for easy adding and subtracting for z
sub AddLeadingZerosNumber {
    my $self = shift;
    my $bm1  = $self;
    my $bm2  = shift;

    my ($z1Ref, $z2Ref) = &AddLeadingZeros(\$bm1->GetZ(), \$bm2->GetZ());

    # put number strings back into instances
    $bm1->_setZ($$z1Ref);
    $bm1->BuildValue();
    $bm2->_setZ($$z2Ref);
    $bm2->BuildValue();
}

# add leading zeros for easy adding and subtracting for exponent
sub AddLeadingZerosExponent {
    my $self = shift;
    my $bm1  = $self;
    my $bm2  = shift;

    #TODO: später entfernen
    $bm1->Normalize();
    $bm2->Normalize();

    my ($exp1Ref, $exp2Ref) = &AddLeadingZeros(\$bm1->GetExponent(), \$bm2->GetExponent());

    # put number strings back into instances
    $bm1->_setExponent($$exp1Ref);
    $bm1->BuildValue();
    $bm2->_setExponent($$exp2Ref);
    $bm2->BuildValue();
}

# add leading zeros for easy adding and subtracting
sub AddLeadingZeros {
    my $z1Ref = shift;
    my $z2Ref = shift;

    # find out shorter number string and max and min lengths
    my $max = length($$z1Ref);
    my $min = $max;

    my $l2 = length($$z2Ref);
    my $smallerRef = $z2Ref;

    if ($l2 > $max) {
	$max = $l2;
	$smallerRef = $z1Ref;
    }
    else {
	$min = $l2;
    }

    # add leading zeroes to shorter number string
    $$smallerRef = '0' x ($max - $min) . $$smallerRef if $max > $min;

    # additional zero in front makes handling of last carry easy
    $$z1Ref = '0' . $$z1Ref;
    $$z2Ref = '0' . $$z2Ref;

    return $z1Ref, $z2Ref;
}

# create multiplication table for fast multiplication and division
sub BuildMultiplicationTableAsString {
    my $self = shift;
    my $z = shift;

    my @mulTab;
    my $mulZ = Math::GoldenBigMath->new($z->GetValue());
    $mulTab[9] = 0;
    $mulTab[0] = 0;
    $mulTab[1] = $mulZ->GetValue();
    foreach my $i (2..9) {
	$mulZ = $mulZ + $z;
	$mulTab[$i] = $mulZ->GetValue();
    }

    $self->_setMulTab(\@mulTab);
}

# Convert strings of multiplication table to Math::GoldenBigMath
sub ConvertMultiplicationTableToMath::GoldenBigMath {
    my $self = shift;

    my @mulTab;
    my $mulTabRef = $self->GetMulTab();
    my $i = 0;
    foreach $i (1..9) {
	$mulTab[$i] = Math::GoldenBigMath->new($mulTabRef->[$i]);
    }

    return @mulTab;
}

# create random number with given count ($digitCount) of digits
sub GenRand {
    my $self = shift;
    my $digitCount = shift; # maximum number of digits for result
    my $add = shift;        # add value at end

    $add = 0 unless $add;

    my $val = '';

    my $z = $digitCount;
    while ($z > 8) {
	$val .= int(rand()*100000000);
	$z -= 8;
    }
    my $mul = '1'.'0' x $z;
    $val .= int(rand()*$mul) + $add;
    $self->SetValue($val);
    $self->Normalize();
}



#=== Calculation sub (s) =======================================================

# --- comparison sub (s) -------------------------------------------------------

sub CompareEqual {
    my $self = shift;
    my $bm2  = shift;

    $self->Normalize();
    $bm2->Normalize();
    return $self->GetValue() eq $bm2->GetValue() ? 1: 0;
}

sub Greater {
    my $self = shift;
    my $bm2  = shift;

    my $result = ($self <=> $bm2) > 0 ? 1 : 0;
    return $result;
}

sub Smaller {
    my $self = shift;
    my $bm2  = shift;
    my $result = ($self <=> $bm2) < 0 ? 1 : 0;
    return $result;
}

sub GreaterEqual {
    my $self = shift;
    my $bm2  = shift;

    my $result = ($self <=> $bm2) >= 0 ? 1 : 0;
    return $result;
}

sub SmallerEqual {
    my $self = shift;
    my $bm2  = shift;
    my $result = ($self <=> $bm2) <= 0 ? 1 : 0;
    return $result;
}

# --- FB-* sub (s) -------------------------------------------------------

# FB-SPEZ ## Spezialwerte behandeln (0 und 1)
sub HandleSpecialValuesAddition { }
sub HandleSpecialValuesSubtraction { }
sub HandleSpecialValuesMultiplication { }
sub HandleSpecialValuesDivision { }
sub HandleSpecialValuesModulus { }

# FB-VZ-BEST ## Vorzeichen bestimmen über Tabelle
sub DetermineSignMulDiv { }

# FB-OP-BEST ## Operator bestimmen: für + - eventuell vertauschen
sub DetermineOperator { }
# sub Calculation { }

# FB-VZ-SET ## Vorzeichen setzen
sub SetSign {
    my $self = shift;
    $self->_setSign(@_);
    $self->BuildValue();
}

# FB-EXP-Join
sub JoinExponent { }

# FB-IST-NULL ## Für 0.0 Exponent auf 0 setzen
sub IsZero {
    my $self = shift;
    
    unless ($self->GetZ()) {
	unless ($self->GetF()) {
	    $self->_setSign('+');
	    $self->_setExponent('0');
	    $self->_setExponentSign('+');
	    return 'true';
	}
    }
    return '';
}

# FB-VGL-VZ ## Vorzeichen vergleichen
sub CompareSigns {
    my $bm1  = shift;
    my $bm2  = shift;

    if ($bm1->GetSign() ne $bm2->GetSign()) {
	return $bm1->GetSign() eq '+' ? 1: -1;
    }

    return 0;
}

sub CompareExponentSigns {
    my $bm1  = shift;
    my $bm2  = shift;

    if ($bm1->GetExponentSign() ne $bm2->GetExponentSign()) {
	return $bm1->GetExponentSign() eq '+' ? 1: -1;
    }

    return 0;
}

# FB-KOM<-- ## Komma nach links herausschieben, Exponent anpassen
sub MovePointOutsideLeft {
    my $self = shift;

    my $z = $self->GetZ();
    my $expAdd = 0;
    if ($z > 0) {
	$expAdd = length($z);
	$self->_setExponent($expAdd + $self->GetExponent());
	$self->_setZ(0);
	$self->_setF($z.$self->GetF());
    }
    $self->BuildValue();
}

# FB-KOM--> ## Komma nach rechts herausschieben, Exponent anpassen
sub MovePointOutsideRight {
    my $self = shift;

    my $f = $self->GetF();
    my $expSubtract;
    if ($f) {
	$self->MovePointRight(length($f))
    }
}

# Point (Komma) um $digitsMoveRight Stellen nach rechts schieben
sub MovePointRight {
    my $self            = shift;
    my $digitsMoveRight = shift; # normal number! Could not be greater!!

    my $fRef = \$self->GetF();
    my $lengthF = length($$fRef);

    # Calc new exponent
    my $expSubtract = Math::GoldenBigMath->new($digitsMoveRight);
    my $exponentSelf  = Math::GoldenBigMath->new($self->GetExponent());
    $exponentSelf->SetSign($self->GetExponentSign());

    my $newExponent = $exponentSelf - $expSubtract;
    $newExponent->Normalize();
    $self->_setExponent($newExponent->GetZ());

    # Now move point
    if ($lengthF > $digitsMoveRight) {
	$self->_setZ($self->GetZ(). substr($$fRef, 0, $digitsMoveRight));
	$self->_setF(substr($$fRef, $digitsMoveRight));
    }
    else {
	my $zAdd = $$fRef . '0' x  ($digitsMoveRight - $lengthF);
	$self->_setF(0);
	$self->_setZ($self->GetZ().$zAdd);
    }

    $self->BuildValue();

}

# FB-VGL ## Ganze Zahlen vergleichen
sub CompareNumbers {
    my $z1 = shift;
    my $z2 = shift;

    my $l1 = length($z1);
    my $l2 = length($z2);
    if ($l1 == $l2) {
	return $z1 cmp $z2;
    }
    return $l1 > $l2 ? 1:-1;
}

# FB-VGL-ST ## Anzahl der Stellen vergleichen
# wird nicht benötigt!!
# ü+äpöv           sub CompareDigitCounter {}

# FB-VGL-ZIF ## Ziffern vergleichen von links nach rechts
#            ## Anzahl d. Ziffern muss NICHT identisch sein,
#            ## fehlende Ziffern als 0 ergänzen
sub CompareDigits {
    my $z1Ref = shift;
    my $z2Ref = shift;

    my $i = 0;
    my $lenZ1 = length($$z1Ref);
    my $lenZ2 = length($$z2Ref);
    my $result = 0;
    my $c1;
    my $c2;

    while (!$result  &&  ($i < $lenZ1  ||  $i < $lenZ2)) {
	$c1 = $i < $lenZ1 ? substr($$z1Ref, $i, 1) : 0;
	$c2 = $i < $lenZ2 ? substr($$z2Ref, $i, 1) : 0;
	$result = ($c1 <=> $c2);
	if ($result) {
	    return $result;
	}
	$i++;
    }

    return 0;
}

# FB-EXP= ## Exponenten der beiden Zahlen angleichen,
#         ## Komma weiter nach rechts herausschieben
sub AlignExponents {
    my $self = shift;
    my $bm1 = $self;
    my $bm2 = shift;

    my $exp1 = Math::GoldenBigMath->new($bm1->GetExponent());
    $exp1->SetSign($bm1->GetExponentSign());
    my $exp2 = Math::GoldenBigMath->new($bm2->GetExponent());
    $exp2->SetSign($bm2->GetExponentSign());

    my $result = ($exp1 <=> $exp2);

    return if ($result == 0);
    
    if ($result < 0) {
	my $h = $bm2;
	$bm2  = $bm1;
	$bm1  = $h;

	$h    = $exp1;
	$exp1 = $exp2;
	$exp2 = $h;
    }

    my $diffBm = $exp1 - $exp2;
    $diffBm->BuildValue();
    $diffBm->MovePointOutsideRight();
    $diffBm->BuildValue();
    $diffBm->Normalize();

    my $diff = $diffBm->GetZ();
    if ($diffBm->GetSign() eq '-') {
	$bm2->MovePointRight($diff);
    }
    else {
	$bm1->MovePointRight($diff);
    }
}

# FB-Normalisierung ## Zahlen und Exponenten normalisieren 
sub Normalize {
    my $self = shift;
    
    $self->_setZ(&NormalizeNumber($self->GetZ()));
    $self->_setF(&NormalizeFraction($self->GetF()));
    $self->_setExponent(&NormalizeNumber($self->GetExponent()));

    $self->BuildValue();

    return $self;
}

sub BuildValue {
    my $self = shift;
    my $value = "";
    
    if ($self->GetSign() eq "-") {
	$value = $self->GetSign();
    }
    $value .= $self->GetZ();
    if ($self->GetF()  ||  $self->GetExponent()) {
	$value .= '.'.$self->GetF();
    }
    if ($self->GetExponent()) {
	$value .= "E".$self->GetExponentSign().$self->GetExponent();
    }

    $self->_setValueNoSplit($value);
    return $self;
}

# FB-EXP-Norm ## Exponenten normalisieren
# FB-Zahl-Norm ## Zahlen normalisieren
sub NormalizeNumber {
    my $z = shift;
    $z =~ s/^[\s0]*//og;
    $z = 0 if $z !~ /\d/;
    return $z;
}

sub NormalizeFraction {
    my $f = shift;
    $f =~ s/[\s0]*$//og;
    $f = 0 if $f !~ /\d/;
    return $f;
}

# FB-EXP-Calc ## Exponenten E3 bestimmen nach Division
sub CalcDivisionExponent { }

# FB-KURZ ## Erweitern/Kürzen bis E1 == 0, E2 == 0
sub ReduceExponentsToZero { }

# FB-ADD
sub Addition {
    my $bm1 = shift;
    my $bm2 = shift;

    $bm1->Normalize();
    $bm2->Normalize();

    $bm1->MovePointOutsideRight();
    $bm2->MovePointOutsideRight();

    $bm1->AlignExponents($bm2);
    $bm1->AddLeadingZerosNumber($bm2);
    # both strings have the same length now

    # use string references for faster access
    my $z1Ref = \$bm1->GetZ();
    my $z2Ref = \$bm2->GetZ();

    my ($result, $uStr) = &AdditionWithoutSignPointAndExponent($z1Ref, $z2Ref);

    # --- create and fill result object ----------------------------------------
    my $resultObj = Math::GoldenBigMath->new($result);
    $resultObj->_setExponent($bm1->GetExponent());
    $resultObj->_storeOperator('+');
    $resultObj->_storeOperatorName("add string");
    $resultObj->_storeU($uStr);
    $resultObj->_setZ1($bm1); #TODO: clean up storage??
    $resultObj->_setZ2($bm2); #TODO: clean up storage??
    $resultObj->BuildValue();

    return $resultObj;
}

# FB-SUB
sub Subtraction {
    my $bm1 = shift;
    my $bm2 = shift;

    $bm1->Normalize();
    $bm2->Normalize();

    my $vz1 = $bm1->GetSign();
    my $vz2 = $bm2->GetSign();
    my $bm3;

    $bm1->SetSign("+");
    $bm2->SetSign("+");

    if ($vz1 eq $vz2) {
        $bm3 = $bm1->SubtractionWithoutSignPointAndExponent($bm2);
	$bm3->SetSign($vz1); # TODO: Vorzeichen behandeln
    }
    else {
	$bm3 = $bm1 + $bm2;
	$bm3->SetSign($vz1);  # TODO: Vorzeichen behandeln
    }
}

# FB-DIV
sub Division {
    my $self = shift;
    return $self->DivisionWithoutSignPointAndExponent(@_);
}

# FB-MOD
sub DivisionModulus {
    my $self = shift;
    return $self->DivisionModulusWithoutSignPointAndExponent(@_);
}

# FB-Subtract-Unsorted
# do subtraction of big numbers
# switch them, if second greater than first one
sub SubtractionWithoutSignPointAndExponent {
    my $z1 = shift;
    my $z2 = shift;

    $z1->MovePointOutsideRight();
    $z2->MovePointOutsideRight();

    if ($z1 >= $z2) {
	return $z1->SubtractionWithoutSignPointAndExponentAndFirstGreater($z2);
    } 

    # $result = $z2 - $z1: # switch numbers
    my $result = $z2->SubtractionWithoutSignPointAndExponentAndFirstGreater($z1);

    # $result = -$result; # set sign
    $result->SetValue("-" . $result->GetValue());

    # switch input vars
    my $z = $result->GetZ1();
    $result->_setZ1($result->GetZ2());
    $result->_setZ2($z);

    return $result;
}

# FB-MUL

sub Multiplication {
    my $self = shift;
    return $self->MultiplicationWithoutSignPointAndExponent(@_);
}

# FB-SCHR/
# Division without exponent, decimal point and sign
sub DivisionWithoutSignPointAndExponent {
    my $self = shift;
    my $z2 = shift;

    $self->_storeOperator('/');

    return $self->CalcDivisionWithoutSignPointAndExponent($z2);
}

# FB-SCHR%
# Division modulo without exponent, decimal point and sign
sub DivisionModulusWithoutSignPointAndExponent {
    my $self = shift;
    my $z2   = shift;

    $self->_storeOperator('%');

    return $self->CalcDivisionWithoutSignPointAndExponent($z2);
}

## FB-Rechnen: FB-SCHR sub (s) =================================================

# FB-SCHR+ =====================================================================
# Addition without exponent, decimal point and sign
sub AdditionWithoutSignPointAndExponent {
    my $z1Ref = shift;
    my $z2Ref = shift;

    my $maxIdx = length($$z1Ref) - 1;
    
    # result variables
    my $result = '';  # result as string
    my $uStr   = '0'; # all carries as string
    my $resultObj;    # result as object

    # index variables
    my $i;     # running index in Math::GoldenBigMath
    my $z;     # next digit  (z for german ziffer)
    my $u = 0; # store carry (u for german uebertrag)

    # --- now calculate sum by schriftliche addition ---------------------------
    for ($i = $maxIdx; $i >= 0; $i--) {
	$z = substr($$z1Ref, $i, 1) + substr($$z2Ref, $i, 1) + $u;
	if ($z > 9) {
	    $u  = 1;  # don't use slow divide or modulo
	    $z -= 10; # don't use slow divide or modulo
	}
	else {
	    $u = 0;
	}
	$uStr   .= $u;   # store carry (u for german uebertrag)
	$result .= $z;   # much faster than $result = $z . $result
    }

    # --- reverse strings to get the highest number at first position
    $uStr   = reverse $uStr;
    $result = reverse $result;

    # --- remove first digit of carry, its zero!!
    $uStr   =~ s/^.//o;
    # replace starting zeroes by ' '
    $result =~ s/^(0+)/' ' x length($1)/eo;

    return $result, $uStr;
}

# FB-SCHR- =====================================================================
# Subtraction without exponent, decimal point and sign
#             and first number is greater than second
sub SubtractionWithoutSignPointAndExponentAndFirstGreater {
    my $self = shift;
    my $z1   = $self; # to get symmetric names
    my $z2   = shift; # to get symmetric names

    $self->AddLeadingZerosNumber($z2);
    # both strings have the same length now

    # use string references for faster access
    my $bm1Ref = \$z1->GetZ();
    my $bm2Ref = \$z2->GetZ();
    my $maxIdx = length($$bm1Ref) - 1;

    # result variables
    my $result = '';  # result as string
    my $uStr   = '0'; # all carries as string
    my $resultObj;    # result as object

    # index variables
    my $i;     # running index in Math::GoldenBigMath
    my $z;     # next digit  (z for german ziffer)
    my $u = 0; # store carry (u for german uebertrag)

    # --- now calculate difference by schriftliche subtraction -----------------
    for ($i = $maxIdx; $i >= 0; $i--) {
	$z = substr($$bm1Ref, $i, 1) - substr($$bm2Ref, $i, 1) - $u;
	if ($z < 0) {
	    $u  = 1;  # don't use slow divide or modulo
	    $z += 10; # don't use slow divide or modulo
	}
	else {
	    $u = 0;
	}
	$uStr   .= $u;   # store carry (u for german uebertrag)
	$result .= $z;   # much faster than $result = $z . $result
    }

    # --- reverse strings to get the highest number at first position
    $uStr   = reverse $uStr;
    $result = reverse $result;

    # --- remove first digit of carry, its zero!!
    $uStr   =~ s/^.//o;
    # replace starting zeroes by ' '
    $result =~ s/^(0+)/' ' x length($1)/eo;

    # --- create and fill result object ----------------------------------------
    $resultObj = Math::GoldenBigMath->new($result);
    $resultObj->_storeOperator('-');
    $resultObj->_storeOperatorName('subtract string');
    $resultObj->_storeU($uStr);
    $resultObj->_setZ1($z1); #TODO: clean up storage??
    $resultObj->_setZ2($z2); #TODO: clean up storage??

    return $resultObj;
}

# FB-SCHR* =====================================================================
# Multiplication without exponent, decimal point and sign
sub MultiplicationWithoutSignPointAndExponent {
    my $self = shift;
    my $z1   = $self; # to get symmetric names
    my $z2   = shift; # to get symmetric names

    $z1->prepareMulDiv($z2);

    # use string references for faster access
    my $bm1Ref    = \$z1->GetValue();
    my $mulTabRef = $self->GetMulTab();
    
    # result variables
    my $result    = '';
    my $resultObj = new Math::GoldenBigMath->new(0);

    # index and help variables
    my $i;              # running index in Math::GoldenBigMath
    my $z;              # next digit  (z for german ziffer)
    my $u        = 0;   # store carry (u for german uebertrag)
    my $c        = 1;   # dot counter
    my $addZeros = '';  # store zeros to append to multab value

    # intermediate multiplication values
    my $add;            # Math::GoldenBigMath to be added as
                        # next multiplication by single digit

    # --- now calculate mul by schriftliche multiplication ---------------------

    for ($i = length($$bm1Ref)-1; $i >= 0; $i--) {
	$z = substr($$bm1Ref, $i, 1);
	if ($z != '0') {
	    # --- $add = $z * $z2, much faster is using table as follows
	    $add       = Math::GoldenBigMath->new($mulTabRef->[$z] . $addZeros);

	    # --------   Do addition by Math::GoldenBigMath operator + !!
	    $resultObj = $resultObj + $add;

	    $resultObj->_setZ1('0'); # to delete tmp GoldeBigMath instances
	    $resultObj->_setZ2('0'); # to delete tmp GoldeBigMath instances
	}
	$addZeros .= '0';            # next number position, mulTabRef *= 10;

        # --- print dots (.) to see its still running and not hanging ----------
	# if ($c > 16383) {
	#     print "\n";
	#     $c = 1;
	# }
	# print "." unless $c++ & 127;
    }

    # --- create and fill result object ----------------------------------------

    $z1->Normalize();
    $z2->Normalize();
    $resultObj->Normalize();
    $resultObj->_storeOperator('*');
    $resultObj->_storeOperatorName("mul string");
    $resultObj->_storeU('...'); # no carry used
    $resultObj->_setZ1($z1);
    $resultObj->_setZ2($z2);

    return $resultObj;
 }

# FB-SCHR/ =====================================================================
# FB-SCHR% =====================================================================
# Really calc the division (without exponent, decimal point and sign)
sub CalcDivisionWithoutSignPointAndExponent {
    my $self = shift;
    my $z1   = $self; # to get symmetric names
    my $z2   = shift; # to get symmetric names

    $z1->prepareMulDiv($z2);

    my @mulTab       = $self->ConvertMultiplicationTableToMath::GoldenBigMath();
    my $maxDivDigits = $self->GetMaxDivideDigits();

    # use string references for faster access
    my $bm1Ref = \$z1->GetValue();
    my $bm1Len = length($$bm1Ref);

    # result variables
    my $result    = '';
    my $resultObj = new Math::GoldenBigMath->new(0);

    # index and help variables
    my $i         = 0;      # running index in Math::GoldenBigMath
    my $z;                  # next digit  (z for german ziffer)
    my $u         = 0;      # store carry (u for german uebertrag)
    my $c         = 1;      # dot counter
    my $firstIter = 'true'; # One iteration is needed !!

    # intermediate division values
    my $rest      = '0';    # Residue of actual division step,
                            # but rest is shorter and same in german
    my %restHash = ();      # will actually not be used,
                            # coming later to identify periods

    # --- now calculate div by schriftliche division ---------------------------

    while ($i < $maxDivDigits
	   &&  ($rest != 0  ||  $firstIter  ||  $i <= $bm1Len)) {
	
        $firstIter = '';
	my $bmRest = Math::GoldenBigMath->new($rest); # Rest as Math::GoldenBigMath
	my $z = 0;                              # next digit of result

        # --- find next result digit -------------------------------------------

	unless ($bmRest < $mulTab[1]) {
	    while ($z < 9) {
		if ($mulTab[$z+1] > $bmRest) {
		    last;
		}
		$z++ if $z < 9;
	    }

	    # --- fire exit, should never be reached!! ---
	    if ($mulTab[$z] > $bmRest) {
		print $bmRest->GetValue() . " < " . $mulTab[$z]->GetValue()
		    . "\n";
		die "problem during search for multiplication factor\n";
	    }

	    # --- calc next rest for division ----------------------------------

	    $bmRest = $bmRest - $mulTab[$z];
	}

        # --- add digit found --------------------------------------------------

	$result .= $z;

	# --- Check, if decimal point reached ----------------------------------

	my $lz = '0';
	if ($i < $bm1Len) {
	    $lz = substr($$bm1Ref, $i, 1);
	}
	# --- end of number reached --------------------------------------------
	elsif ($i == $bm1Len) {
	    # --- modulo wanted ? ----------------------------------------------
	    if ($self->GetOperator() eq '%') {
		$result = $bmRest->GetValue();
		last;
	    }

	    # --- add decimal point --------------------------------------------

	    $result .= '.'; 
	}

	# --- Append next digit to rest ----------------------------------------

	$rest = $bmRest->GetValue() . $lz;

        # --- print dots (.) to see its still running and not hanging ----------
	# if ($c > 16383) {
	#     print "\n";
	#     $c = 1;
	# }
	# print "." unless $c++ %127;

	$i++;
    }
    
    # --- create and fill result object ----------------------------------------
    $z1->Normalize();
    $z2->Normalize();
    $resultObj = Math::GoldenBigMath->new($result);
    $resultObj->Normalize();
    $resultObj->_storeOperator($self->GetOperator());
    $resultObj->_storeOperatorName("div string");
    $resultObj->_storeU('...');
    $resultObj->_setZ1($z1); #TODO: clean up storage??
    $resultObj->_setZ2($z2); #TODO: clean up storage??

    return $resultObj;
}

# --- old one sub (s) ----------------------------------------------------------

# FB-COMP-OP ## Vergleichsoperator
sub CompareOperator {
    my $self = shift;
    my $bm1  = Math::GoldenBigMath->new($self->GetValue());
    my $bm2  = Math::GoldenBigMath->new(shift->GetValue());

    $bm1->Normalize();
    $bm2->Normalize();

    # --- both Zero ? ---
    if ($bm1->IsZero()  &&  $bm2->IsZero()) {
	return 0;
    }

    my $result = $bm1->CompareSigns($bm2);
    return $result if $result;

    $bm1->MovePointOutsideLeft();
    $bm2->MovePointOutsideLeft();

    # --- Compare Exponents ---

    # --- Compare Sign of Exponent ---
    if ($bm1->GetExponentSign()  ne  $bm2->GetExponentSign()) {
	return $bm1->GetExponentSign() eq '+' ? 1: -1;
    }

    # --- Compare Exponents ---
    my $exponentDiff = &CompareNumbers($bm1->GetExponent(), $bm2->GetExponent());
    if ($exponentDiff != 0) {
	return $exponentDiff;
    } 

    return &CompareDigits(\$bm1->GetF(), \$bm2->GetF());
}

# prepare operation mul, div or mod
#TODO: remove later
sub prepareMulDiv {
    my $self = shift;
    my $bm1 = $self;
    my $bm2 = shift;

    $bm1->Normalize();
    $bm2->Normalize();

    $self->BuildMultiplicationTableAsString($bm2);
}


1; # End of Math::Math::GoldenBigMath


__END__

=head1 NAME

Math::GoldenBigMath - Math with big numbers in pure perl with no deps

=head1 ABOUT

calc + - * / % with unbounded integers/decimals

+ - * / % == != > < <=> implemented

handling of exponents ([eE][+-]?123456789) and decimal point "[,.]" still missing


=head1 SYNOPSIS

    use Math::GoldenBigMath;
    my $foo = Math::GoldenBigMath->new();
    # ...

=head1 SUBROUTINES/METHODS

=head2 function1

TODO: Document me.

=head1 AUTHOR

Ralf Peine, C<< <ralf.peine at jupiter-program.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-math-goldenbigmath
at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math-GoldenBigMath>.
I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Math::GoldenBigMath

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Math-GoldenBigMath>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Math-GoldenBigMath>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Math-GoldenBigMath>

=item * Search CPAN

L<http://search.cpan.org/dist/Math-GoldenBigMath/>

=back


=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Ralf Peine.

This program is free software; you can redistribute it and/or modify
it under the terms of either: the GNU General Public License as
published by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

