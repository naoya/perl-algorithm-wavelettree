package Algorithm::WaveletTree::Code;
use strict;
use warnings;

use constant CODE => 0;
use constant LEN  => 1;

sub new  {  bless $_[1] || [], $_[0] }
sub code       : lvalue { shift->[CODE] }
sub bit_length : lvalue { shift->[LEN] }

1;
