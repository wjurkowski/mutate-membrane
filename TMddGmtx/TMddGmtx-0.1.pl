#!/usr/bin/perl -w
use strict;
use warnings;
use List::Util qw( min max );

#Two files are needed: 1) list of variations 2) uniprotKB features (output of upanno.pl)
if ($#ARGV != 1) {die "Program used with parameters [list of variations] [uniprot features]\n";}

#read uniprot features
#AA ranges: TM and IM segments
#uniprotAC;uniprotID;TRANSMEM;INTRAMEM
my @features=open_files($ARGV[1]);
for(my $i=0;$i<$#features+1;$i++){
my $row=$funcaarange[$i];
  my @prot=split(/\t/,$row);
  $uniID=$prot[0];
  $uniAC=$prot[1];
  $transmem{$uniAC}=$prot[2];
  $intramem{$uniAC}=$prot[3];
}

#read variants and compare with annotation
open (OUT, ">Annotated_TM.txt"); 
#open (OUT1, ">Annotated_AA.txt"); 
#open (OUT2, ">Annotated_AApairs.txt"); 
#open (OUT3, ">Annotated_AAranges.txt"); 
printf OUT1 "uniprotAC\twtAA\tAApos\tmtAA\ttype\tInsertion_ddG\tclass\n";
my @variants=open_file($ARGV[0]);
for (my $i=1;$i<=$#variants;$i++){#GVkey, Symbol, Entrez,  Uniprot AC, Uniprot ID, Ref AA, Position, Var AA, disease
  my ($r1, $r2);
  $r1 = $r2 = 0;
  my $type="NA";
  my @aa=split(/\t/,$variants[$i]);
  my $wt=$aa[5];
  my $pos=$aa[6];
  my $mt=$aa[7];
  my $uniAC=$aa[3];
  #test AA ranges
  unless($transmem{$uniAC} eq "NA"){$r1=testAArange($pos,$transmem{$uniAC});}
  unless($intramem{$uniAC} eq "NA"){$r2=testAArange($pos,$intramem{$uniAC});}
  if($r1 == 1 or $r2 == 1){
    if($r1 == 1){$type = "TRANSMEM";}
    elsif($r2 == 1){$type = "INTRAMEM";}
    #apply new substitution matrix and get classification of variant
    my $del=TMddG($pos);
    printf OUT1 "$uniAC\t$wt\t$pos\t$mt\t$type\t$del\n";
  }
}


#functions=============================================================
#get ddG scores for insertion of helix into the membrane
sub TMddG{
 
  #read in data table
  my @mtx=open_file($ARGV[2]);
  #define indexes
  my (%index);
  @head=split(/\t/,$mtx[0]);
  shift @head;
  for(my $k=0;$k<=$#head;$k++){
    $index{$head[$k]}=$k;
  }
  #get matrix
  for (my $i=1;$i<=$#mtx;$i++){
    my @row=split(/\t/,$mtx[$i]);
    shift @row;
    my $idx= $i - 1;#to have same $k and $i indexing start
    for (my $k=0;$k<=$#row;$k++){
      $mat[$idx][$k] = $row[$k];
    }
  }

  #get z-values

  #interpolate ddG for given z-value
  if($z > 0){
    
  }
  elsif($z < 0){
  }
	
  #calculate substitution score
  my $wt = shift;
  my $pos = shift;
  my $mt = shift;
  my $del = 0;
  my $i = $index{$wt};
  my $k = $index{$mt};
  $ddG=$matrix[$z][$k]-$matrix[$z][$i];
  #calculate if the change is significant:
  #	- if the difference is negative its OK, if positive and higher than 5% its deleterious
  #	- compare with distribution of values: z-value (taking all differences on all positions)
  #	- 
  if($ddG > 0){$del =1;}
  return $del;
}

#classify according to TMddG
sub class_ddG{
  my ($val,@classes)=@_;
  if($val <= ){}
}



#OTHER:
#check specific TM residues
#TM seq alignment
#find conserved residues
#check within radius of 5A


sub testAArange{
	my ($pos,$string)=@_;
	my $match = 0;
	my @values=split(/\,/,$string);
	foreach my $val(@values){
		my @range = split(/-/,$val);
		if($pos >= $range[0] and $pos <= $range[1]){$match=1;} 
	}
	return $match;
}

sub open_file{
        my ($file_name)=@_;
        open(INP1, "< $file_name") or die "Can not open an input file: $!";
        my @file1=<INP1>;
        close (INP1);
        chomp @file1;
        return @file1;
}		
