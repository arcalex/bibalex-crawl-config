#!/usr/bin/perl -wl

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

uri-backtrace.pl - trace a crawl log entry back to seed

=head1 SYNOPSIS

B<uri-backtrace.pl> I<FILE> I<URI>

=head1 DESCRIPTION

Given a crawl log file and URI, trace the URI's discovery path in the
crawl log back to the seed URI.

A version of the crawl log with the lines in reverse order is first
written to a file with the same name as the crawl log file plus a
'.reverse' suffix.  If a file with that name already exists, it is used.

See the following in the documentation of the Heritrix web crawler for
information on the crawl log file:

http://crawler.archive.org/articles/user_manual/analysis.html

See also the following for information on the discovery path field:

http://crawler.archive.org/articles/user_manual/glossary.html#discoverypath

=head1 AUTHOR

Written by Mahmoud Mubarak, editing by Youssef Eldakar.

=cut

use strict;

die "Usage: $0 crawl.log uri" unless @ARGV == 2;

my $log = $ARGV[0] . ".reverse";
my $uri = $ARGV[1];

backtrace ();

sub backtrace {
  my @log_line;
  my $b;

  print STDERR "Writing reverse log file...";
  qx(tac $ARGV[0] > $log) unless -e $log;

  print STDERR "Opening reverse log file...";
  open (LOG, $log);

  print STDERR "Initiating backtrace...";
  while (<LOG>) {
    @log_line = split;
    $b = substr ($log_line[4], -1, 1);  # tail element in discovery path

    if ($b ne "-") {  # if not a seed
      if ($uri eq $log_line[3]) {
        print "$b $log_line[3]";
        $uri = $log_line[5];
      }
    } else {
      print "$log_line[4] $log_line[3]";
      print "DONE";
      last;
    }
  }

  close (LOG);
}
