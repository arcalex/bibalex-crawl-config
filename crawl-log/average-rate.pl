#!/usr/bin/perl -anl

# Copyright (C) 2010 Bibliotheca Alexandrina <www.bibalex.org>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 NAME

average-rate.pl - calculate average download rate in Mb/s at each crawl log line

=head1 SYNOPSIS

B<average-rate.pl> [B<-t> I<interval>] [I<FILE>]...

=head1 DESCRIPTION

Given a crawl log, report the average download rate in megabits per
second at the specified interval in seconds (default: 3600 seconds).

=head1 AUTHOR

Written by Mahmoud Mubarak, editing by Youssef Eldakar.

=cut

use Getopt::Std;
use Class::Date;

BEGIN {
  getopts("t:", \%opts);

  $opts{t} = 3600 unless defined $opts{t};

  $ref = 0;
  $sum = 0;

  $| = 1;  # Hot piping
}

next unless ($F[1] == 200);

$F[0] =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/; 
$t = Class::Date->new([$1, $2, $3, $4, $5, $6])->epoch;

if ($ref == 0) {
  $ref = $t;
  $sum += $F[2];
} elsif ($t - $ref < $opts{t}) {
  $sum += $F[2];
} else {
  printf("%0.5f MB/s\n", $sum * 0.000008 / $opts{t});

  $sum = $F[2];
  $ref = $t;
}

END {
  printf("%0.5f MB/s\n", $sum * 0.000008 / $opts{t}) unless ! defined $t;
}
