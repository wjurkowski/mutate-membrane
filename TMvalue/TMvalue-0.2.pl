#!/usr/bin/perl -w
use strict;
use warnings;
use List::Util qw( min max );

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


#read substitution matrix
my @matrix=open_files($ARGV[1]);
#get vector representing substitutions of given aa (in alphabetical order) 
#A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V  B  Z  X  *
my @head=split(/\t/,$matrix[0]);
my (@mat,@matc);
for(my $i=1;$i<=$#matrix;$i++){
  my @row=split(/\t/,$matrix[$i]);
  my $min = min @row;
  my $max = max @row;
  my $R=$max-$min;
  my $dk=$R/4;
  for(my $k=1;$k<=$#row;$k++){
	$mat[$i][$k] = $row[$k];
	if($row[$k] < ($min+(1*$dk))){$matc[$i][$k]=1;}
	if($row[$k] < ($min+(1*$dk))){$matc[$i][$k]=2;}
	if($row[$k] < ($min+(1*$dk))){$matc[$i][$k]=3;}
	if($row[$k] < ($min+(1*$dk))){$matc[$i][$k]=4;}
  }		
}

#get ddG scores for insertion of helix into the membrane
sub TMddG{
}

#classify according to TMddG
sub class_ddG{
  my ($val,@classes)=@_;
  if($val <= ){}
}

#check specific TM residues
#TM seq alignment
#find conserved residues
#check within radius of 5A

sub open_file{
        my ($file_name)=@_;
        open(INP1, "< $file_name") or die "Can not open an input file: $!";
        my @file1=<INP1>;
        close (INP1);
        chomp @file1;
        return @file1;
}		
		
