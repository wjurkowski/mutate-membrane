package flying_mouse;

require Exporter;
use strict;
use warnings;
use ParsePDB;
use LWP::UserAgent;
use HTTP::Response;
use URI;

use vars qw(@ISA @EXPORT $VERSION);
our @ISA = qw(Exporter);
our @EXPORT = qw(read_names distance residue whyscy get_interface get_file get_pdb percent topcons naccess surface_filter cmapper_interface);
$VERSION=1.0;

sub read_names{
	my ($list_name,@bla)=@_;
	my @names;
	my $loops;
	my @submit;
	#get the  list
	open LIST, "<$list_name" or die "can not open";
	my @list=<LIST>;
	chop @list;
	
	for (my $i=0;$i<scalar(@list);$i++){
		if($list[$i]=~/(.{4})\_(.{1})-(.{4})\_(.{1}).*/){
			#die;
			$names[$i][0]=$1;#ID
			$names[$i][1]=$2;#Chain
			$names[$i][2]=$3;#ID
			$names[$i][3]=$4;#Chain
			#print "$names[$i][0]	$names[$i][1]	$names[$i][2]	$names[$i][3]\n";
		}
	}
	#format the list
	$loops=scalar(@list)*2;
	#print "$loops\n";
	for(my $i=0;$i<$loops;$i=$i+2){
		my $j=$i/2;
		$submit[$i][0]="$names[$j][0]";
		$submit[$i][1]="$names[$j][1]";
		$submit[$i+1][0]="$names[$j][2]";
		$submit[$i+1][1]="$names[$j][3]";
	}
	return @submit;
	}
sub get_file{
		my ($path,@bla)=@_;
		open TEMP,"<$path" or warn "can not open $path :$!";
		my @result=<TEMP>;
		close TEMP;
		return @result;
	}
sub whyscy {
		my ($file,$ID,$chain,$cut_off,@bla)=@_;
		my $download;
		my @result;
		my @final;
		my $temp_name;
		my $success="Y";
		my $count=0;
		#open STDOUT,">log" or die;
		my $browser=LWP::UserAgent->new;
		push @{$browser->requests_redirectable}, 'POST';
		my $url='http://www.nmr.chem.uu.nl/cgi-bin/whiscy_server.cgi';
			my $response=$browser->post($url,[
				'PDB_file'=>$file,
				'PDB_format'=>'PDBfile',
				'PDB_IDnumber'=>'',
				'selected_chain'=>$chain,
				'format_alignment'=>'HSSPID',
				'alignment_file'=>'',
				'HSSP_ID'=>$ID,
				'alignmenttype'=>'invalid',
				'use_prop'=>'on',
				'use_smooth'=>'on',
				'Submit'=>'Do your prediction!',
				],
				'Content_Type' => 'form-data',
				);

		#request# GET http://nmr.chem.uu.nl/favicon.ico
	
		#get the link
		my $html=$response->content;
		my @temp=split(/\n/,$html);

		#test success reply or not
		foreach(@temp){
			if($_=~/.*?(Fail).*?/){$success="N";print "error!!  $success\n\n\n";}
		}
		#if success, get the result..
		if($success eq "Y"){
			foreach(@temp){
				if($_=~/.*?(ftp.*?\.scores).*?/){$download=$1;}
			}
			system"wget -q $download";
			$temp_name=$ID."\_".$chain;
			`mv .scores* $temp_name`;
			@result=get_file($temp_name);
			chomp @result;
			`rm $temp_name`;
			for(my $i=0;$i<scalar(@result);$i++){
				if($result[$i]=~/(.*?\d) [A-Z]{1}(.*)/){
					if($1>$cut_off){push @final,$2;$count++;}
				}
			}
			if($count==0){$final[0]=0;}
		}
		elsif(1){$final[0]="error";	}
		#print "$final[0]\n";die;
		#close STDOUT;
		return @final;
	}


sub get_interface{
	my ($range,@native)= @_;
	my @native_one;
	my @native_two;
	my @predict_one;
	my @predict_two;
	my @temp1;
	my $count;
	my $chain="RANDOM";
	my $num;
	my $miss;
	my $mark;
	my $date;
	chomp($date = `date`);
	print"$date\n";
	#read in file
	@temp1=grep{/^ATOM.*?/} @native;

	#store the files as 2D matrix
	$count=0;
	$miss=0;
	for(my $i=0;$i<scalar(@temp1);$i++){
		if($temp1[$i]=~/^ATOM.*?/){
			$count++;
			#mark first res
			if($count == 1){
				$chain=substr($temp1[$i],23,3);
				$mark=1;
			}
			#Chain One
			if($chain eq substr($temp1[$i],23,3) && $count <30 && $mark==1){
				if($temp1[$i]=~/^.{21}(.{1}).{1}(.{3}).{6}(.{6}).{2}(.{6}).{2}(.{6}).*?/){
				$native_one[$i-$miss][0]=$2;#res number
				$native_one[$i-$miss][1]=$1;#Chain ID
				$native_one[$i-$miss][2]=$3;#X
				$native_one[$i-$miss][3]=$4;#Y
				$native_one[$i-$miss][4]=$5;#Z
				$native_one[$i-$miss][5]=$i+1;#line number
				$num=scalar(@native_one);
				}
			}
			if($chain ne substr($temp1[$i],23,3) && $count >1 && $mark==1){
			
				if($temp1[$i]=~/^.{21}(.{1}).{1}(.{3}).{6}(.{6}).{2}(.{6}).{2}(.{6}).*?/){
				$native_one[$i-$miss][0]=$2;#res number
				$native_one[$i-$miss][1]=$1;#Chain ID
				$native_one[$i-$miss][2]=$3;#X
				$native_one[$i-$miss][3]=$4;#Y
				$native_one[$i-$miss][4]=$5;#Z
				$native_one[$i-$miss][5]=$i+1;#line number
				$num=scalar(@native_one);
				}
			}
			#Chain Two
			if($count > 30 && $chain eq substr($temp1[$i],23,3)){
				$mark=2;
			}
			if($count >30 && $mark==2){
				if($temp1[$i]=~/^.{21}(.{1}).{1}(.{3}).{6}(.{6}).{2}(.{6}).{2}(.{6}).*?/){
				$native_two[$i-$num-$miss][0]=$2;#res number
				$native_two[$i-$num-$miss][1]=$1;#Chain ID
				$native_two[$i-$num-$miss][2]=$3;#X
				$native_two[$i-$num-$miss][3]=$4;#Y
				$native_two[$i-$num-$miss][4]=$5;#Z
				$native_two[$i-$num-$miss][5]=$i+1;#line number
				}
			}
		}
		else{
			$miss++;		
		}	
		
	}

	#get the line numbers for calculation
	my $num1=scalar(@native_one);
	my $num2=scalar(@native_two);
	#for(my $i=0;$i<@native_one;$i++){print "$native_one[$i][0]\n"};die;
	#print "$num1	$num2 $range\n";die;

	my @residue=residue(\@native_one,\@native_two,$num1,$num2,$range);
	return @residue;
}
#calculate the distance and find the residues
	sub residue{
		my($first,$second,$num1,$num2,$range)=@_;
		my $distance;
		my @result_first;
		my @result_second;		
		for(my $i=0;$i<$num1;$i++){
			for(my $j=0;$j<$num2;$j++){
				$distance=sqrt(($$first[$i][2]-$$second[$j][2])**2+($$first[$i][3]-$$second[$j][3])**2+($$first[$i][4]-$$second[$j][4])**2);
				if($distance <= $range){
					push @result_first,$$first[$i][0];
					push @result_second,$$second[$j][0];
				}
			}

		}
		#delete the reduntant residues
		my %hash=();
		my @result1 = grep{$hash{$_}++ <1} @result_first;
		my %hash2=();
		my @result2 = grep{$hash2{$_}++ <1} @result_second;
		my @result_final=(@result1,"divide",@result2);
		return @result_final;
	}



#Function for distance
	sub distance{
    return sqrt(($_[0] - $_[3])**2 + ($_[1] - $_[4])**2 + ($_[2] -$_[5])**2);
	}
#get the pdb file
sub get_pdb{
		my ($path,@bla)=@_;
		my $PDB = ParsePDB->new (FileName => $path);
		$PDB->Parse;
		my @label=$PDB->IdentifyChainLabels;
		$PDB->RenumberResidues (ResidueStart => '1');
		my @result=$PDB->Get (ChainLabel => $label[0]);
		my $final="";
		for(my $i=0;$i<scalar(@result);$i++){
			$final.=$result[$i];
		}
		return $final;
}
#get the percentage
sub percent{
			my($num_f,$num_s,$num_i,$first_pdb,$second_pdb,$interface)=@_;
			my $count_f=0;
			my $count_i=0;
			my $count_s=0;
			my $mark=1;
			my $middle_count=0;
			my @result;
			for(my $i=0;$i<$num_i;$i++){
				if($$interface[$i] ne "divide" && $mark==1){
					for(my $j=0;$j<($num_f);$j++){						
						if($$interface[$i]==$$first_pdb[$j]){ $count_f++; }
					}
				}
				elsif($$interface[$i] eq "divide"){ $mark=2;}
				elsif($$interface[$i] ne "divide" && $mark==2){
					for(my $j=0;$j<($num_s);$j++){						
						if($$interface[$i]==$$second_pdb[$j]){ $count_s++; }
					}

				}
			}
			#in case of no match
			if($count_f ==0){	$result[0]=0;}
			else{	$result[0]=($count_f/$num_f)*100;}
			if($count_s ==0){	$result[1]=0;}
			else{	$result[1]=($count_s/$num_s)*100;}

			return @result;
}
sub topcons{
		my @fasta=@_;
		my $submit=$fasta[0].$fasta[1];
		my $browser=LWP::UserAgent->new;
		my $html;
		my $download;
		my $name;
		my @SCAMPI_seq;
		my @SCAMPI_msa;
		my @PRODIV;
		my @PRO;
		my @OCTOPUS;
		my @TOPCONS;
		my @lines;
		my @return;
		push @{$browser->requests_redirectable}, 'POST';
		my $url='http://www.topcons.net/';
		my $response=$browser->post($url,[
			'sequence'=>$submit,
			'seq_file'=>'',
			'do'=>'Submit',
		],
			'Content_Type' => 'form-data',
		);
		#get the link and file name
		$html=$response->content;
		my @temp=split(/\n/,$html);
		foreach(@temp){
			if($_=~/.*?a href=\"(.*?(topcons.txt))\".*?/){$download=$1;$name=$2;}
		}
	if($download){
		$download="http://www.topcons.net/".$download;
		#get the result;
		#$name=$name.$$;
		`wget -q $download`;
		my @files=get_file($name);
		#chomp @files;
		`rm $name`;
		#print @files;die;
		for(my $i=0;$i<scalar(@files);$i++){
			#SCAMPI-seq
			if($files[$i]=~/^SCAMPI-seq .*?/){
				push @SCAMPI_seq,$files[$i];
				for(my $j=1;$j<100;$j++){
					if($files[$i+$j]=~/^[\*\n].*?/){last;}
					push @SCAMPI_seq,$files[$i+$j];					
				}
			}
			#SCAMPI-msa
			if($files[$i]=~/^SCAMPI-msa .*?/){
				push @SCAMPI_msa,$files[$i];
				for(my $j=1;$j<100;$j++){
					if($files[$i+$j]=~/^[[\*\n].*?/){last;}
					push @SCAMPI_msa,$files[$i+$j];					
				}
			}
			#PRODIV
			if($files[$i]=~/^PRODIV .*?/){
				push @PRODIV,$files[$i];
				for(my $j=1;$j<100;$j++){
					if($files[$i+$j]=~/^[\*\n].*?/){last;}
					push @PRODIV,$files[$i+$j];
				}
			}
			#PRO
			if($files[$i]=~/^PRO .*?/){
				push @PRO,$files[$i];
				for(my $j=1;$j<100;$j++){
					if($files[$i+$j]=~/^[\*\n].*?/){last;}
					push @PRO,$files[$i+$j];

				}
			}
			#OCTOPUS
			if($files[$i]=~/^OCTOPUS .*?/){
				push @OCTOPUS,$files[$i];
				for(my $j=1;$j<100;$j++){
					if($files[$i+$j]=~/^[\*\n].*?/){last;}
					push @OCTOPUS,$files[$i+$j];
				}
			}
			#TOPCONS
			if($files[$i]=~/^TOPCONS predicted.*?/){
				push @TOPCONS,$files[$i];
				for(my $j=1;$j<100;$j++){
					if($files[$i+$j]=~/^[\*\n].*?/){last;}
					push @TOPCONS,$files[$i+$j];
				}
			}
		}
		#choose one
		for(my $i=0;$i<6;$i++){
			if($TOPCONS[1] && $i==0 ){@lines=@TOPCONS;}
			if($SCAMPI_seq[1] && $i==1 ){@lines=@SCAMPI_seq;}
			if($SCAMPI_msa[1] && $i==2 ){@lines=@SCAMPI_msa;}
			if($PRODIV[1] && $i==3 ){@lines=@PRODIV;}
			if($PRO[1] && $i==4 ){@lines=@PRO;}
			if($OCTOPUS[1] && $i==5 ){@lines=@OCTOPUS;}
		
		}
		#if(@lines){print @lines;}die;
		# i/o/m each line
		##################################HERE @lines is the input
		my $temp="";
		for(my $i=1;$i<scalar(@lines);$i++){
				$temp.=$lines[$i];
			}
		my @result=split(//,$temp);
		
		for(my $i=0;$i<scalar(@result);$i++){
			if($result[$i]=~/M.*/){
				my $line=$i+1;
				push @return,$line;				
			}

		}
	}
		if(!@return){$return[0]=0;}
		return @return;
}
sub naccess{
		my ($name,@bla)=@_;
		`$ENV{NACCESS} $name\.pdb`;
		my @rsa=get_file("$name\.rsa");
		my @result;
		foreach(@rsa){
			if($_=~/^RES [A-Z]{3} [A-Z][ ]{1,4}([\d]{1,4})[ ]{2,6}(.*?) .*/){
				if($2>0){push @result,$1;}
			}
		}
		`rm $name\.rsa $name\.asa $name\.log`;
		return @result;
}

sub surface_filter{
		my($surface,$membrane,$num_s,$num_m)=@_;
		my @result;
			for(my $i=0;$i<$num_s;$i++){
				for(my $j=0;$j<$num_m;$j++){
					if($$surface[$i] == $$membrane[$j]){push @result,$$membrane[$j];}
				}
			}
		if(!@result){$result[0]=0;}
		return @result;
}

sub cmapper_interface{
		my ($range,$receptor,$ligand)=@_;
		my @return_r;
		my @return_l;
		my $temp;
		`cmapper $receptor 40 $range $ligand`;
		#get the result
		my @map=get_file("$ligand\.out");
			`rm $ligand\.out`;
		if(@map){
			foreach my $line(@map){
				#(66,THR,474,O):(39,PHE,172,C,10);(40,CYS,182,N,3)
				$line=~s/[\(\)]//g;
	    	    my @molecular=split(":",$line);
				$temp=(split(/,/,$molecular[0])	)[0];
				push @return_r,$temp;
				my @contact=split(";",$molecular[1]);
				foreach my $i(@contact){
					$temp=(split(/,/,$i)	)[0];
					push @return_l,$temp;
				}	
			}
		}
		else{
			$return_r[0]=99999;
			$return_l[0]=99999;
		}
		#delete the reduntant residues
		my %hash=();
		my @result1 = grep{$hash{$_}++ <1} @return_r;
		my %hash2=();
		my @result2 = grep{$hash2{$_}++ <1} @return_l;
		my @result_final=(@result1,"divide",@result2);
		return @result_final;
		
}
