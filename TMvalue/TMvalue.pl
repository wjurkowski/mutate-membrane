#!/usr/bin/perl -w
use strict;
use warnings;

#Two files are needed: 1) list of variations 2) uniprotKB features (output of upanno.pl)
if ($#ARGV != 1) {die "Program used with parameters [list of variations] [uniprot features]\n";}


#parse_variations
my @variations=open_file($ARGV[0]);
my(@variat, %allvarAA, %uniSNV);

for(my $i=0;$i<$#variations+1;$i++){#TODO: uproscic  - zostawic tylko to co potrzebne
	my @tab = split(/\t/,$variations[$i]);#GVkey, Symbol, Entrez,  Uniprot AC, Uniprot ID, Ref AA, Position, Var AA, disease
	push (@{$variat[$i]}, @tab);
	my $waryjat=$variat[$i][3]."_".$variat[$i][5].$variat[$i][6];
	$allvarAA{$waryjat}=$i;
	$uniSNV{$variat[$i][3]}++;#hash counting number of GV in protein
}	

#read uniprot features
my @features=open_files($ARGV[1]);
for(my $i=0;$i<$#features+1;$i++){
#get TM segments

}




sub open_file{
        my ($file_name)=@_;
        open(INP1, "< $file_name") or die "Can not open an input file: $!";
        my @file1=<INP1>;
        close (INP1);
        chomp @file1;
        return @file1;
}		
		
