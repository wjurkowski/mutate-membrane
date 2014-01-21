#1usr/bin/perl -w

use strict;
use warnings;
use lib './Modules';
use flying_mouse;
use Parallel::ForkManager;

my $run_dir=$ARGV[0];#run dir
my $range=$ARGV[1];#range for interface defination
my $MAX_THREAD=$ARGV[2];
my @directorys;
my @names;
my $date;
my @native_R;
my @native_L;
my @submit;
my @predicted_filenames;
my @temp;
my @whysky_first;
my @whysky_second;


#program starting time
	chomp($date = `date`);
	print "program for $ARGV[0] started at time $date\n";

#result place
	`mkdir $ARGV[0]\_topcon`;

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
#for each pairs

for (my $j=0;$j<scalar(@directorys);$j++){
		chdir"$directorys[$j]"or die "can not change to $directorys[$j] : $!";
		#get the model result
		@native_R=get_file("../../seq-fasta/pdb$names[$j][0]\-AA\.fasta");
		@native_L=get_file("../../seq-fasta/pdb$names[$j][1]\-AA\.fasta");
		my @TransM_R=topcons(@native_R);
		my @TransM_L=topcons(@native_L);
		#filter it with surface calculator naccess
		my @suf_R=naccess("pdb$names[$j][0]");
		my @suf_L=naccess("pdb$names[$j][1]");
		my $n_Trans_R=scalar(@TransM_R);
		my $n_Trans_L=scalar(@TransM_L);
		my $n_suf_R=scalar(@suf_R);
		my $n_suf_L=scalar(@suf_L);
		@TransM_R=surface_filter(\@suf_R,\@TransM_R,$n_suf_R,$n_Trans_R);
		@TransM_L=surface_filter(\@suf_L,\@TransM_L,$n_suf_L,$n_Trans_L);
		#foreach(@TransM_L){print "$_\n";}die;
		#get the file names
			@predicted_filenames=get_file("file_name");
			chomp @predicted_filenames;
			
			open OUT,">../../$ARGV[0]\_topcon/$names[$j][0]\-$names[$j][1]"or die "hell:$!";
		#get the result
			my $pm = new Parallel::ForkManager($MAX_THREAD);
			#my @pdb_one=get_file("pdb$names[$j][0]\_m.pdb");
			for(my $i=0;$i<scalar(@predicted_filenames);$i++){
				#my @pdb_two=get_file("$predicted_filenames[$i]");
				#my @pdb=(@pdb_one,@pdb_two);
				#my @interface=get_interface($range,@pdb);
				my $pid = $pm->start and next;
				my @interface=cmapper_interface($range,"pdb$names[$j][0]\_m.pdb",$predicted_filenames[$i]);
				#print @interface;print "\n";next;
				my $topcon_first=scalar(@TransM_R);
				#print "$topcon_first\n";
				my $topcon_second=scalar(@TransM_L);
				my $interface=scalar(@interface);
				my @result=percent($topcon_first,$topcon_second,$interface,\@TransM_R,\@TransM_L,\@interface);
				printf OUT "%s\t%2.2f\t%2.2f\n",$predicted_filenames[$i],$result[0],$result[1];
				print"$i\n";
				$pm->finish; # Terminates the child process

			}
			close OUT;
		chdir"../"or die"$!";
}
