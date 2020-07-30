#!/usr/bin/perl

use strict;
use warnings;

my %Unique = (); # acc => $anno [0], $tax [1]
open IN, "All_faa.total_blast_result_col2_unique_grep_nr_remove_SOH";
while(<IN>){
	chomp;
	my $line = $_;
	my $acc = my $anno = my $tax = "";
	if($line =~ /MULTISPECIES\:/){
		($acc,$anno,$tax) = $line =~ /^>(.+?)\sMULTISPECIES\:\s(.+?)\s\[(.+)\]$/;  
	}else{
		($acc,$anno,$tax) = $line =~ /^>(.+?)\s(.+?)\s\[(.+)\]$/;
	}
}
close IN;

my %All_top_hits = (); #gene => acc [0], iden [1], e-value [2], bitscore [3], origin [4]
my $gene_top1 = ""; # the gene id of the top 1 hits
open IN, "All_faa.total_blast_result.txt";
while (<IN>){
	chomp;
	my $acc = my $iden = my $e = my $bitscore = "";
	my $origin = "";
	my @tmp = split (/\t/);
	if ($gene_top1 ne $tmp[0]){
		$gene_top1 = $tmp[0];
		$acc = $tmp[1];
		$iden = $tmp[2];
		$e = $tmp[-2];
		$bitscore = $tmp[-1];
		$All_top_hits{$gene_top1}[0] = $acc;
		$All_top_hits{$gene_top1}[1] = $iden;
		$All_top_hits{$gene_top1}[2] = $e;
		$All_top_hits{$gene_top1}[3] = $bitscore;		
		$origin = "original protein hit";
		$All_top_hits{$gene_top1}[4] = $origin;
		
	}else{
		if ($Unique{$acc}[0] eq "hypothetical protein"){
			$gene_top1 = $tmp[0];
			$acc = $tmp[1];
			$iden = $tmp[2];
			$e = $tmp[-2];
			$bitscore = $tmp[-1];
			$All_top_hits{$gene_top1}[0] = $acc;
			$All_top_hits{$gene_top1}[1] = $iden;
			$All_top_hits{$gene_top1}[2] = $e;
			$All_top_hits{$gene_top1}[3] = $bitscore;	
			$origin = "non hypothetical protein hit";
			$All_top_hits{$gene_top1}[4] = $origin;
		}else{
			next;
		}
	}
}
close IN;

my %All_top_hits2 = (); #gene => acc [0], iden [1], e-value [2], bitscore [3], origin [4]; only include the top hit with hypothetical protein
$gene_top1 = ""; # the gene id of the top 1 hits
open IN, "All_faa.total_blast_result.txt";
while (<IN>){
	chomp;
	my $acc = my $iden = my $e = my $bitscore = "";
	my $origin = "";
	my @tmp = split (/\t/);
	if ($gene_top1 ne $tmp[0] and $Unique{$tmp[1]}[0] eq "hypothetical protein"){
		$gene_top1 = $tmp[0];
		$acc = $tmp[1];
		$iden = $tmp[2];
		$e = $tmp[-2];
		$bitscore = $tmp[-1];
		$All_top_hits2{$gene_top1}[0] = $acc;
		$All_top_hits2{$gene_top1}[1] = $iden;
		$All_top_hits2{$gene_top1}[2] = $e;
		$All_top_hits2{$gene_top1}[3] = $bitscore;		
		$origin = "original protein hit";
		$All_top_hits2{$gene_top1}[4] = $origin;	
	}
}
close IN;

foreach my $gene (sort keys %All_top_hits){
	if ($Unique{$All_top_hits{$gene}[0]}[0] eq  "hypothetical protein"){
		$All_top_hits{$gene}[0] =  $All_top_hits2{$gene}[0];
		$All_top_hits{$gene}[1] =  $All_top_hits2{$gene}[1];
		$All_top_hits{$gene}[2] =  $All_top_hits2{$gene}[2];
		$All_top_hits{$gene}[3] =  $All_top_hits2{$gene}[3];
		$All_top_hits{$gene}[4] =  $All_top_hits2{$gene}[4];
	}
}


open OUT, ">All_faa.total_blast_result_parsed.txt_blastp_new_nr_tophit.txt.test";
print OUT "query\taccession\tproduct\ttaxonomy\ttophit\tidentity\tevalue\tbitscore\n";
foreach my $gene (sort keys %All_top_hits){
	my $acc = $All_top_hits{$gene}[0];
	my $iden = $All_top_hits{$gene}[1];
	my $e = $All_top_hits{$gene_top1}[2];
	my $bitscore = $All_top_hits{$gene_top1}[3];
	my $origin = $All_top_hits{$gene_top1}[4];
	my $anno = $Unique{$acc}[0];
	my $tax = $Unique{$acc}[1];
	print OUT "$gene\t$acc\t$anno\t$tax\t$origin\t$iden\t$e\t$bitscore\n";
}
close OUT;