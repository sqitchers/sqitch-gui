use strict;
use warnings;
use Test::More;

use DateTime::TimeZone::Local;

ok my $tz = DateTime::TimeZone::Local->TimeZone()->name;
diag "TZ: $tz";
isnt $tz, '', 'have a time zone';

done_testing;
