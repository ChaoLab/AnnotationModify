#!/usr/bin/perl

use strict;
use warnings;

my $input = "All_faa.total";

my %h = ();
open IN, "$input";
while (<IN>){
	chomp;
	if (/>/){
		my ($head1,$head2,$head3) = $_ =~ /^(.+?)\s\[(.+?)\]\s\[(.+?)\]$/;
		my $tmp = $head1."\t".$head2."\t".$head3;
		$h{$tmp} = 1;
	}
}
close IN;

open OUT, ">$input.GenBank.annotations";
foreach my $key (sort keys %h){
	print OUT "$key\n";
}
close OUT;
