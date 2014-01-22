#!usr/bin/perl -w

use strict;
use warnings;

my $date;
my @predicted_filenames;
my @file1;
my @file2;
my @directorys;
my @names;
my @result;
my $rsa;
my @naccess;
my $max_naccess;

#program starting time
	chomp($date = `date`);
	print "program for $ARGV[0] started at time $date\n";

	`mkdir $ARGV[0]\_naccess`;

#to the working directory
	chdir "$ARGV[0]"or die "can not change dir to $ARGV[0]:$!";

#read in the file names
	@directorys=`ls`;
	chop @directorys;

	for (my $i=0;$i<scalar(@directorys);$i++){
		if($directorys[$i]=~/DP\_(.+?)-(.+)/){
			$names[$i][0]=$1;#Receptor name
			$names[$i][1]=$2;#ligand name
		}
	}

#for each pair
	for (my $j=0;$j<scalar(@directorys);$j++){
			chdir"$directorys[$j]"or die "can not change to $directorys[$j] : $!";
		#get the max
		#the first file
			`$ENV{NACCESS} pdb$names[$j][0]\_m.pdb`;
			$rsa=`ls *rsa`;
			chomp $rsa;			
			open (NACCESS,"$rsa") or die "can't open: $!";
			@naccess=<NACCESS>;
			close NACCESS;
			foreach(@naccess){
					   	#TOTAL          1160.2        876.1        284.1        559.9        600.3
				if($_ =~/^TOTAL\s{1,20}(\d{1,5}\.\d{1,5}).*/){
				$max_naccess=$1;
				#print "$max_naccess\n";
				
				}
			}
			`rm *rsa *asa *log`;
		#the second file
			`$ENV{NACCESS} pdb$names[$j][1]\_m.pdb`;
			$rsa=`ls *rsa`;
			chomp $rsa;			
			open (NACCESS,"$rsa") or die "can't open: $!";
			@naccess=<NACCESS>;
			close NACCESS;
			foreach(@naccess){
					   	#TOTAL          1160.2        876.1        284.1        559.9        600.3
				if($_ =~/^TOTAL\s{1,20}(\d{1,5}\.\d{1,5}).*/){
				$max_naccess=$max_naccess+$1;
				#print "$max_naccess\n";
				#die;
				}
			}
			`rm *rsa *asa *log`;
		#get the file names
			open (NAME,"file_name") or die "Can't open :$!";	
			@predicted_filenames=<NAME>;
			close NAME;
			chop @predicted_filenames;
		#get the two file together

			#file1
			open (ONE,"pdb$names[$j][0]\_m.pdb") or die "Can't open :$!";
			@file1=<ONE>;
			close ONE;
			
		for(my $i=0;$i<scalar(@predicted_filenames);$i++){
			#file1
			#print "$predicted_filenames[$i]\n";
			open (TWO,"$predicted_filenames[$i]") or die "Can't open :$!";
			@file2=<TWO>;
			close TWO;

			#output
			open (COM,">../../$ARGV[0]\_naccess/$names[$j][0]\-$predicted_filenames[$i]") or die "Can't open :$!";
			print COM @file1;
			print COM @file2;
			
			#naccess work 
			chdir"../../$ARGV[0]\_naccess/"or die "can not change to $ARGV[0]\_naccess : $!";
			`$ENV{NACCESS} $names[$j][0]\-$predicted_filenames[$i]`;
			`rm $names[$j][0]\-$predicted_filenames[$i]`;
			$rsa=`ls *rsa`;
			chomp $rsa;
			#print "$rsa\n";
			#die;
			open (NACCESS,"$rsa") or die "can't open: $!";
			@naccess=<NACCESS>;
			close NACCESS;
			foreach(@naccess){
					   	#TOTAL          1160.2        876.1        284.1        559.9        600.3
				if($_ =~/^TOTAL\s{1,20}(\d{1,5}\.\d{1,5}).*/){
					$result[$i]=$max_naccess-$1;
				}
			}
			#print "$result[$i]\n";
			#die;
			`rm *rsa *asa *log`;
			chdir"../$ARGV[0]/$directorys[$j]";
		}
		#work for others
			open (RESULT,">../../$ARGV[0]\_naccess/$names[$j][0]-$names[$j][1]") or die "Can't open :$!";
				for(my $i=0;$i<scalar(@predicted_filenames);$i++){
					print RESULT "$predicted_filenames[$i]	$result[$i]\n";
				}
			close RESULT;
			chdir"../"or die "can not change to ../ : $!";


	}


