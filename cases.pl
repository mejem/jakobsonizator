#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my @colors = ("#ffad82", "#ffec82", "#b5ff96", "#9effe3", "#deafff", "#ffa8a8");

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

sub equiv_add {
    my $equiv_arr_ref = shift;
    my $paradigm_hash_ref = shift;
    my $case_to_add = shift;
    my @equiv = @$equiv_arr_ref;
    my %paradigm = %$paradigm_hash_ref;

    my $added = 0;
    for my $class_of_eq (@equiv) {
        for my $elem (@$class_of_eq) {
            if ($paradigm{$elem} eq $paradigm{$case_to_add}) {
                push @$class_of_eq, $case_to_add;
                $added = 1;
                last;
            }
        last if $added;
        }
    }
    if (!$added) {
        my @new_class_of_eq;
        push @new_class_of_eq, $case_to_add;
        my $arr_ref = \@new_class_of_eq;
        push @equiv, $arr_ref;
    }
    return @equiv;
}

sub equiv_find {
    my $equiv_arr_ref = shift;
    my $case_to_find = shift;
    my @equiv = @$equiv_arr_ref;

    if (@equiv < 1) {
        return -2;
    }
    for (my $i = 0; $i <= $#equiv; $i++) {
        for my $elem (@{$equiv[$i]}) {
            if ($elem eq $case_to_find) {
                return $i;
            }
        }
    }
    return -1;
}

sub equiv_del_single {
    my $equiv_arr_ref = shift;
    my @equiv = @$equiv_arr_ref;

    for (my $i = 0; $i <= $#equiv; $i++) {
        if (@{$equiv[$i]} < 2) {
            splice @equiv, $i;
        }
    }
    return @equiv;
}

sub print_head {
    my $head = << 'END';
<!DOCTYPE html>
<html lang="cs">
  <head>
    <meta charset="utf-8">
    <title>Vzory</title>
    <link rel="stylesheet" href="style.css">
  </head>
  <body>
END
    print $head;
}

sub print_info_table {
    say "<table class='bordered'>";
    say '<tr><th>Tense';
    say "<tr><td>Nominative<td>Accusative<td>Genitive";
    say "<tr><td>Instrumental<td>Dative<td>Locative";
    say "</table>";
}

sub print_table_row {
    my $equiv_arr_ref = shift;
    my $paradigm_hash_ref = shift;
    my $tense = shift;
    my @row_cases = @_;

    print "<tr>";
    for my $case (@row_cases) {
        my $class_of_eq = equiv_find($equiv_arr_ref, $case . $tense);
        if ($class_of_eq >= 0) {
            print "<td bgcolor=$colors[$class_of_eq]>";
        } else {
            print "<td>";
        }
        print $paradigm_hash_ref->{$case . $tense};
    }
    say "";
}

sub print_table {
    my $equiv_arr_ref = shift;
    my $paradigm_hash_ref = shift;
    my $tense = shift;

    my %tense_str = (
        "s" => "Singular",
        "d" => "Dual",
        "p" => "Plural"
    );
    say "<table class='bordered'>";
    say '<tr><th>' . $tense_str{$tense};
    print_table_row($equiv_arr_ref, $paradigm_hash_ref, $tense, "N", "A", "G");
    print_table_row($equiv_arr_ref, $paradigm_hash_ref, $tense, "I", "D", "L");
    say "</table>";
}

print_head();
print_info_table();
my %paradigm;
my (@equiv_sg, @equiv_du, @equiv_pl);
while (<>) {
    chomp;
    s/\[edit\]//;
    my $line = $_;
    next if /^-/;
    my @field = split(/\t/);
    if (defined $field[0] && $field[0] =~ /^[NAGIDLV]$/) {
        $paradigm{"$field[0]"."s"} = trim($field[1]);
        $paradigm{"$field[0]"."d"} = trim($field[2]);
        $paradigm{"$field[0]"."p"} = trim($field[3]);
        @equiv_sg = equiv_add(\@equiv_sg, \%paradigm, "$field[0]"."s");
        @equiv_du = equiv_add(\@equiv_du, \%paradigm, "$field[0]"."d");
        @equiv_pl = equiv_add(\@equiv_pl, \%paradigm, "$field[0]"."p");
    } else {
        if (defined $paradigm{Ns}) {
            @equiv_sg = equiv_del_single(\@equiv_sg);
            @equiv_du = equiv_del_single(\@equiv_du);
            @equiv_pl = equiv_del_single(\@equiv_pl);

            print_table(\@equiv_sg, \%paradigm, "s");
            print_table(\@equiv_du, \%paradigm, "d") if $paradigm{Nd} ne "-";
            print_table(\@equiv_pl, \%paradigm, "p") if $paradigm{Np} ne "-";
        }
        if ($line =~ /\S/) {
            say "<h3>" . $line . "</h3>" if $line =~ /\S/;
        } else {
            say "";
        }
        undef %paradigm;
        undef @equiv_sg;
        undef @equiv_du;
        undef @equiv_pl;
    }
}
say "</body></html>";
