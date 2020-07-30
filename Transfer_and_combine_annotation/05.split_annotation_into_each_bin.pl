#!/usr/bin/perl -w 

my %bin = ();
open IN, "All_faa.total";
while (<IN>){
	chomp;
	if (/>/){
		my ($tmp) = $_ =~ /^>(.+?)\|/; #grep and store the bin name
		$bin{$tmp} = 1;
	}
}
close IN;

foreach my $key (sort keys %bin){
	open IN, "All_faa.total.annotation.txt";
	my %hash = ();
	while (<IN>){
		chomp;
		my $line = $_;
		my ($bin_name) = $_ =~ /^(.+?)\|/;  
		if ($key eq $bin_name){
			$hash{$line} = 1;
		}
	}
	close IN;
	open OUT, ">$key.annotation.txt";
	foreach my $item (sort keys %hash){
		print OUT "$item\n";
	}
	close OUT;
}

