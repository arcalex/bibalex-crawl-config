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

trim-transient.pl - trim initial transient and identify where steady state starts

=head1 SYNOPSIS

B<trim-transient.pl> [I<FILE>]...

=head1 DESCRIPTION

Given a list of numerical values as input, trim the initial transient
period and report where the steady-state period starts.

This is useful when inspecting crawl throughput over time.

See "3.2. Modified Conway Rule or Backward Data Interval Rule" in "The
Problem of the Initial Transient: Techniques for Estimating the
Warm-up Period for Discrete-Event Simulation Models" by Stewart
Robinson and Agis Ioannou:

http://www2.warwick.ac.uk/fac/soc/wbs/projects/autosimoa/warmupreviewsimulation.doc

=head1 AUTHOR

Written by Mahmoud Mubarak, editing by Youssef Eldakar.

=cut

BEGIN {
  $min = $F[0];
  $max = $F[0];
}

if ($F[0] < $min) {
  $min = $F[0];
} elsif ($F[0] > $max) {
  $max = $F[0];
} else {
  print "Steady state starts at line $.";
  exit 0;
}
