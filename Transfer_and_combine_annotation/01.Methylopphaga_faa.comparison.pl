#!/usr/bin/perl

use strict;
use warnings;

my %IMGSeq = (); my $head = ();
open IN, "3300001302.a.faa.txt";
while (<IN>){
	chomp;
	if (/>/){
		$head = $_;
		$IMGSeq{$head} = "";
	}else{
		$IMGSeq{$head} .= $_;
	}
}
close IN;

my %GnSeq = (); my $head2 = ();
open IN, "Methylophaga_aminisulfidivorans_SZUA-1124.protein";
while (<IN>){
	chomp;
	if (/>/){
		my ($tmp) = $_ =~ /\|(SZU.+?)\s/;
		$head2 = $tmp;
		$GnSeq{$head2} = "";
	}else{
		$GnSeq{$head2} .= $_;
	}
}
close IN;

my %hOUT = ();
foreach my $k1 (sort keys %IMGSeq){
	foreach my $k2 (sort keys %GnSeq){
		if ($IMGSeq{$k1} eq $GnSeq{$k2}){
			if (!exists $hOUT{$k1}){
				$hOUT{$k1} = $k2;
			}else{
				$hOUT{$k1} .= "\t".$k2;
			}
		}
	}
}

open OUT, ">Methylophaga_protein_ID_comparison.txt";
foreach my $key (sort keys %hOUT){
	print OUT "$key\t$hOUT{$key}\n";
}
close OUT;