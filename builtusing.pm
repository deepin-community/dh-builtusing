# dh_builtusing - set dpkg-gencontrol substitution variables for the Built-Using field
# Insert dh_builtusing into the dh sequence.

use strict;
use warnings;
insert_before( 'dh_gencontrol', 'dh_builtusing' );
1;
