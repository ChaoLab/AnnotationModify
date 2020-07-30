#!/usr/bin/perl -w

###parse KO from many annotation files: "GhostKoala", "KAAS", "EggNOG emapper"
###order to keep: 1. GhostKoal KO 2. KAAS KO 3. EggNOG emapper KO 4. EggNOG emapper COG
open IN, "/mnt/storage2/zhouzhichao/BinProject/KEGG_KO_Map/ko2cog.txt";
%hash = ();
while (<IN>)
{
	chomp;
	unless (/\#/)
	{
		my @tmp = split (/\t/, $_);
		my @tmp2 = split (/\s/, $tmp[1]);
		foreach (@tmp2) 
		{
			if (/(COG\d{4})/)
			{
				$hash{$1} = $tmp[0];
			}
		}
	}
}
close IN;

open IN, "All_faa.total_GhostKoala_KO.txt";
%hash2 = ();
while (<IN>)
{
	chomp;
	my @tmp = split (/\t/, $_);
	if (exists $tmp[1] and !exists $hash2{$tmp[0]} )
	{
		$hash2{$tmp[0]} = $tmp[1];
	}else
	{
		$hash2{$tmp[0]} = "";
	}
}
close IN;

open IN, "All_faa.total_KAAS_KO.txt";
%hash3 = ();
while (<IN>)
{
	chomp;
	my @tmp = split (/\t/, $_);
	if (exists $tmp[1])
	{
		$hash3{$tmp[0]} = $tmp[1];
	}else
	{
		$hash3{$tmp[0]} = "";
	}
}
close IN;

open IN, "All_faa.total.emapper.annotations";
%hash4 = ();
while (<IN>)
{
	chomp;
	my @tmp = split (/\t/, $_);
	if (exists $tmp[6] and $tmp[6] =~ /K/)
	{
		my ($ko_hit) = $tmp[6] =~ /^(K\d{5})/;
		$hash4{$tmp[0]}[0] = $ko_hit;
	}else
	{
		$hash4{$tmp[0]}[0] = "";
	}
	if (exists $tmp[9])
	{
		my @tmp2 = split (/\,/,$tmp[9]);
		foreach (@tmp2) 
		{
				if (/(COG\d{4})\@NOG/)
				{
					$hash4{$tmp[0]}[1] = $1;
				}else
				{
					$hash4{$tmp[0]}[1] = "";
				}
		}
		#change cog to ko according to %hash
		if (exists $hash{$hash4{$tmp[0]}[1]})
		{
			$hash4{$tmp[0]}[1] = $hash{$hash4{$tmp[0]}[1]};
		}else 
		{
			$hash4{$tmp[0]}[1] = "";
		}	
	}else 
	{
		$hash4{$tmp[0]}[1] = "";
	}
}
close IN;

foreach my $key (sort keys %hash2)
{	
	unless (exists $hash4{$key})
	{
		$hash4{$key}[0] = "";
		$hash4{$key}[1] = "";
	}
}

%hash5 = ();
foreach my $key (sort keys %hash2)
{
	if ($hash2{$key} ne "")
	{
		$hash5{$key} = $hash2{$key};
	}elsif (($hash2{$key} eq "") and ($hash3{$key} ne ""))
	{
		$hash5{$key} = $hash3{$key};
	}elsif (($hash2{$key} eq "") and ($hash3{$key} eq "") and ($hash4{$key}[0] ne ""))
	{
		$hash5{$key} = $hash4{$key}[0];
	}elsif (($hash2{$key} eq "") and ($hash3{$key} eq "") and ($hash4{$key}[0] eq "") and ($hash4{$key}[1] ne ""))
	{
		$hash5{$key} = $hash4{$key}[1];
	}else
	{
		$hash5{$key} = "";
	}
	
}
open OUT, ">All_faa.total.KO.in_total.txt";
foreach my $key ( sort keys %hash5)
{
	print OUT "$key\t$hash2{$key}\t$hash3{$key}\t$hash4{$key}[0]\t$hash4{$key}[1]\t$hash5{$key}\n";
}
close OUT;
