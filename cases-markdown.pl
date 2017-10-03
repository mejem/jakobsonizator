#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my %paradigm;
while (<>) {
    chomp;
    s/\[edit\]//;
    my $line = $_;
    next if /^-/;
    my @field = split(/\t/);
    if (defined $field[0] && $field[0] =~ /^[NAGIDLV]$/) {
        $paradigm{"$field[0]"."s"} = $field[1];
        $paradigm{"$field[0]"."d"} = $field[2];
        $paradigm{"$field[0]"."p"} = $field[3];
    } else {
        if (defined $paradigm{Ns}) {
            say 'Singular';
            say "$paradigm{Ns}" . " | " . "$paradigm{As}" . " | " . "$paradigm{Gs}";
            say "$paradigm{Is}" . " | " . "$paradigm{Ds}" . " | " . "$paradigm{Ls}";
            say 'Dual';
            say "$paradigm{Nd}" . " | " . "$paradigm{Ad}" . " | " . "$paradigm{Gd}";
            say "$paradigm{Id}" . " | " . "$paradigm{Dd}" . " | " . "$paradigm{Ld}";
            say 'Plural';
            say "$paradigm{Np}" . " | " . "$paradigm{Ap}" . " | " . "$paradigm{Gp}";
            say "$paradigm{Ip}" . " | " . "$paradigm{Dp}" . " | " . "$paradigm{Lp}";
        }
        say $line;
        undef %paradigm;
    }
#    print Dumper %paradigm;
#    print;

}
