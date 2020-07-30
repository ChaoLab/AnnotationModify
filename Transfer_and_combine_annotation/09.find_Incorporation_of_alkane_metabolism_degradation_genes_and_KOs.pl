#!/usr/bin/perl

use strict;
use warnings;

my %nums = ();my %hGnPnt = ();
open INN,"ls *.annotation.txt | grep -v 'All_faa.total'|";
while (<INN>){
	chomp;
	my $input = $_;
	my %hInputAnno = ();
	open IN, $input;
	while (<IN>){
		chomp;
		my @tmp = split(/\t/);
		$hInputAnno{$tmp[0]} = $tmp[1];
	}
	close IN;
	
	open OUT, ">$input.Incorporation_of_alkane_metabolism.result.txt"; 
	open IN, "Incorporation_of_alkane_metabolism.txt";
	while (<IN>){
		chomp;
		if (/^\#/){
			print OUT "$_\n";
		}else{
			print OUT "$_";
			my @tmp = split (/\t/);
			my $KO = $tmp[0]; my $num = $tmp[2]; $nums{$num} = 1;
			foreach my $k (sort keys %hInputAnno){
				if ($KO eq $hInputAnno{$k}){
					print OUT "\t".$k; $hGnPnt{$input}{$num} = 1;
				}
			}
			print OUT "\n";
		}
	}
	close IN;
}
close INN;

open OUT, ">Incorporation_of_alkane_metabolism.stat.txt";
my $row=join("\t", sort keys %nums);
print OUT "Head\t$row\n";
foreach my $tmp1 (sort keys %hGnPnt)
{
        print OUT $tmp1."\t";
        my @tmp = ();
        foreach my $tmp2 (sort keys %nums)
        {
                if (exists $hGnPnt{$tmp1}{$tmp2})
                {
                        push @tmp, $hGnPnt{$tmp1}{$tmp2};
                }
                else
                {
                        push @tmp,"0"
                }
        }
        print OUT join("\t",@tmp)."\n";
}
close OUT;