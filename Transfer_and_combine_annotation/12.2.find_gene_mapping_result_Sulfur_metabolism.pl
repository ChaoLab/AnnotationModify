#!/usr/bin/perl

use strict;
use warnings;

my %hMetaT = (); my @head = (); my @head_num = (); 
open IN,"MetaT.RPKM.txt";
while (<IN>){
	chomp;
	if (/^Head/){
		my @tmp = split (/\t/);
		@head = @tmp;
		for(my $i=0; $i<=$#head; $i++){
			if ($head[$i] ne "Head"){
				push @head_num,$i;
			}
		}
	}else{
		my @tmp = split (/\t/);
		foreach my $i (@head_num){
			$hMetaT{$tmp[0]}{$head[$i]} = $tmp[$i]; # $hMetaT{ protein id } {Sample}
		}
	}	
}
close IN;

my @Sample = qw/CymD.C.HRP CymD.C.MRP CymD.C.LRP CymD.C.HB CymD.C.LB CymS.C.HRP.1 CymS.C.HRP.2 CymS.C.LRP.1 CymS.C.LRP.2 CymS.C.B CymS.C.NBB.1 CymS.C.NBB.2 GyBn.C.NBP GyBn.C.APB/;

open INN,"ls *.Sulfur_metabolism.result.txt | ";
while (<INN>){
	chomp;
	my $input = $_;
	my ($name) = $input =~ /^(.+?)\.annotation\.txt/;
	my %hIDtoProID = (); #"C1-01" => Methylococcales_bacterium_SZUA-1314|SZUA-1314_00880
	my %IDs = ();
	open IN, "$input";
	while (<IN>){
		chomp;
		if (!/^#/){
			my @tmp = split (/\t/);
			if (scalar @tmp == 3){
				$IDs{$tmp[2]} = 1;
			}else{
				$IDs{$tmp[2]} = 1;
				my @pros = ();
				for(my $i=3; $i<=$#tmp; $i++){
					push @pros,$tmp[$i];
				}
				if (! exists $hIDtoProID{$tmp[2]}){
					$hIDtoProID{$tmp[2]} = join("\t",@pros); 
				}else{
					$hIDtoProID{$tmp[2]} .= "\t".join("\t",@pros);
				}
			}
		
		}
	}
	close IN;
	
	my %hID2Sample2MetaT = ();
	foreach my $ID (sort keys %hIDtoProID){
		my @ProIDs = split(/\t/,$hIDtoProID{$ID}); 
		foreach my $k1 (@ProIDs){
			foreach my $k2 (@Sample){
				if (!exists $hID2Sample2MetaT{$ID}{$k2}){
					$hID2Sample2MetaT{$ID}{$k2} = $hMetaT{$k1}{$k2};
				}else{
					$hID2Sample2MetaT{$ID}{$k2} += $hMetaT{$k1}{$k2}; 
				}
			}
		}
		
	}
	
	open OUT, ">${name}_MetaT_result.txt";
	my $row=join("\t", @Sample);
	print OUT "Head\t$row\n";
	foreach my $tmp1 (sort keys %IDs)
	{
        print OUT $tmp1."\t";
        my @tmp = ();
        foreach my $tmp2 (@Sample)
        {
                if (exists $hID2Sample2MetaT{$tmp1}{$tmp2})
                {
                        push @tmp, $hID2Sample2MetaT{$tmp1}{$tmp2};
                }
                else
                {
                        push @tmp,"0"
                }
        }
        print OUT join("\t",@tmp)."\n";
	}
	close OUT;
}
close INN;
