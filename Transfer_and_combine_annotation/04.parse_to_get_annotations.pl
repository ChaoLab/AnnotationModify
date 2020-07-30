#!/usr/bin/perl -w

#Store ko2EC
open IN, "/mnt/storage2/zhouzhichao/BinProject/KEGG_KO_Map/ko2EC.txt";
%ko2EC = (); # KO => EC
while (<IN>)
{
	chomp;
	my @tmp = split (/\t/, $_);
	$ko2EC{$tmp[0]} = $tmp[1] or $ko2EC{$tmp[0]} = "";
}
close IN;

#Store ko2geneinfo
open IN, "/mnt/storage2/zhouzhichao/BinProject/KEGG_KO_Map/ko2geneinfo.txt";
%ko2geneinfo = (); # KO => [0] gene id; [1] gene name 
while (<IN>)
{
	chomp;
	my @tmp = split (/\t/, $_);
	$ko2geneinfo{$tmp[0]}[0] = $tmp[1] or $ko2geneinfo{$tmp[0]}[0] = "";
	$ko2geneinfo{$tmp[0]}[1] = $tmp[2] or $ko2geneinfo{$tmp[0]}[1] = "";
}
close IN;

open IN, "All_faa.total.emapper.annotations";
%emapper = (); # query => [0] eggNOG OGs; [1] eggNOG HMM Desc.
while (<IN>)
{
	chomp;
	my @tmp = split (/\t/, $_);
	$emapper{$tmp[0]}[0] = $tmp[9] or $emapper{$tmp[0]}[0] = "";
	$emapper{$tmp[0]}[1] = $tmp[12] or $emapper{$tmp[0]}[1] = "";
}
close IN;

#store KO
open IN, "All_faa.total.KO.in_total.txt";
%KO = (); # query => [0] GhostKOALA; [1] KAAS; [2] eggNOG KO (1st); [3]eggNOG COG transferred KO; [4] KO (4 integrated)
while (<IN>)
{
	chomp;
	my @tmp = split (/\t/, $_);
	$KO{$tmp[0]}[0] = $tmp[1] or $KO{$tmp[0]}[0] = "";
	$KO{$tmp[0]}[1] = $tmp[2] or $KO{$tmp[0]}[1] = "";
	$KO{$tmp[0]}[2] = $tmp[3] or $KO{$tmp[0]}[2] = "";
	$KO{$tmp[0]}[3] = $tmp[4] or $KO{$tmp[0]}[3] = "";
	$KO{$tmp[0]}[4] = $tmp[5] or $KO{$tmp[0]}[4] = "";
}
close IN;

#Store nr blast result
open IN, "blast2nr/All_faa.total_blast_result_parsed.txt_blastp_new_nr_tophit.txt";
%nr = (); # query => [0] nr annotation; [1] nr phylogenetic assignment
while (<IN>)
{
	chomp;
	if (!/query/ and !/DNA-directed_RNA_polymerase_subunit_A|DNA-directed_RNA_polymerase_subunit_B/){
		my (@tmp) = $_ =~ /\"(.+?)\"/g;
		if (!$tmp[1]){
			print "$_\n";
		}
		$nr{$tmp[1]}[0] = $tmp[3] or $nr{$tmp[1]}[0] = ""; 
		$nr{$tmp[1]}[1] = $tmp[4] or $nr{$tmp[1]}[1] = "";
	}
}
close IN;

#Store GenBank annotation
open IN, "All_faa.total.GenBank.annotations";
my %GB = (); # query => [0] positon [1] GenBank annotations
while (<IN>){
	chomp;
	my @tmp = split (/\t/);
	my ($tmp0) = $tmp[0] =~ /^>(.+)/;
	$GB{$tmp0}[0] = $tmp[1];
	$GB{$tmp0}[1] = $tmp[2];
}
close IN;

#store the query
open IN, "All_faa.total";
%faa = ();
while (<IN>)
{
	chomp;
	if (/>/){
		my ($tmp) = $_ =~ /^>(.+?)\s/;
		$faa{$tmp} = 1;
	}
}
close IN;

%anno = ();
foreach my $key (sort keys %faa){
	$anno{$key}[0] = $KO{$key}[4]; #KO
	$anno{$key}[1] = $ko2EC{$KO{$key}[4]} or $anno{$key}[1] = ""; #EC
	$anno{$key}[2] = $ko2geneinfo{$KO{$key}[4]}[0] or $anno{$key}[2] = ""; #KO protein ID
	$anno{$key}[3] = $ko2geneinfo{$KO{$key}[4]}[1] or $anno{$key}[3] = ""; #KO protein name
	$anno{$key}[4] = $emapper{$key}[0] or $anno{$key}[4] = ""; #eggNOG OG
	$anno{$key}[5] = $emapper{$key}[1] or $anno{$key}[5] = ""; #eggNOG HMM Desc.
	$anno{$key}[6] = $nr{$key}[0] or $anno{$key}[6] = ""; #nr annotation
	$anno{$key}[7] = $nr{$key}[1] or $anno{$key}[7] = ""; #nr phylogenetic assignment
	$anno{$key}[8] = $GB{$key}[0]; #GB position 
	$anno{$key}[9] = $GB{$key}[1]; #GB annotations
	$anno{$key}[10] = $KO{$key}[4]; #KO
	$anno{$key}[11] = $KO{$key}[0]; #GhostKOALA KO
	$anno{$key}[12] = $KO{$key}[1]; #KAAS KO
	$anno{$key}[13] = $KO{$key}[2]; #eggNOG KO (1st)
	$anno{$key}[14] = $KO{$key}[3]; #eggNOG COG transferred KO
}

open OUT, ">All_faa.total.annotation.txt";
foreach my $key ( sort keys %anno)
{
	print OUT "$key\t$anno{$key}[0]\t$anno{$key}[1]\t$anno{$key}[2]\t$anno{$key}[3]\t$anno{$key}[4]\t$anno{$key}[5]\t$anno{$key}[6]\t$anno{$key}[7]\t$anno{$key}[8]\t$anno{$key}[9]\t$anno{$key}[10]\t$anno{$key}[11]\t$anno{$key}[12]\t$anno{$key}[13]\t$anno{$key}[14]\n";
}
close OUT;
