#!/usr/bin/perl

use warnings;
use strict;
use English;
use File::Basename;
use Cwd;
use File::Temp qw/ tempdir /;
use Getopt::Long 'HelpMessage';


# test input on the command line
GetOptions(
    'Task=s' => \my $TASK,
    'Folder=s' => \my $FOLDER,
    'Classification=s' => \my $CLASSIFICATION,
) or HelpMessage(1);

# check presence of mandatory inputs
HelpMessage(1) unless $TASK;
HelpMessage(1) unless $FOLDER;



=head1 NAME

Image Classifier

=head1 SYNOPSIS

  --Task, -T            	Which task is required: "Train" or "Classify" (required)
  --Folder, -F          	Folder containing pictures (required)
  --Classification, -C          Manually classified images (required)

		Example classification file:
				image1.jpg,tree
				image2.jpg,tree
				image3.jpg,flower
				...
  
Help

  --help, -h             Print this help
  
=head1 VERSION
0.01
=cut


# test if task is correct
if ($TASK ne 'Train' && $TASK ne 'Classify'){
	print "'Task' need to be either 'Train' or 'Classify'\n";
	exit;
}

if ($TASK eq 'Train' && undef $CLASSIFICATION){
	print "'Train' needs Classification file\n";
	HelpMessage(1);
	exit;
}

# getwd
my $dir = getcwd . "/";

# script directory
my $PATHscript = dirname $0;

# make tmp folder
my $TEMPfolder = tempdir( DIR => $dir, CLEANUP => 1 ); 


# make array with image names
my @files = glob("$FOLDER" . "/*.*");

# Extract values from images
print "Processing images in $FOLDER ...\n";
#system "ls $FOLDER | parallel -j8 'java -jar ~/Downloads/ImageJ/ij.jar -batch ImageClassifier/generalImageStats.bat {}' >/dev/null 2>&1 ";


# parse results
my @ImageData;

foreach my $Image (@files){
	chomp $Image;
	my $Row = basename($Image);
	my $general = $Row . "_general.csv";
	my $grey = $Row . "_greyHisto.csv";
	$Row = $Row . ',';

	# extract general info
	open(IN, $general) or die "can't open $general"; 
	while (<IN>){
		if ($_ !~ m/Area/){
			chomp;
			$Row = $Row . $_; 
		}
	}
	close $general;

	# extract grey distribution
	open(IN, $grey) or die "can't open $grey"; 
	while (<IN>){
		if ($_ !~ m/Counts/){
			chomp;
			my $greyRow = $_;
			$greyRow =~ s/\d+,//;
			$Row = $Row . $_; 
		}
	}
	close $general;

	# add to array
	push(@ImageData, $Row);
}

# write out multivar description of images
my $TEMPimageDescription = $TEMPfolder . '/imageDescriptor.csv';
open(FH, '>>', $TEMPimageDescription) or die $!;
foreach (@ImageData){
	print FH "$_\n";
}
close(FH);


### TRAIN

if ($TASK eq 'Train'){
	print "Train Model...\n";

	######################################################################### test classification

	system "Rscript $PATHscript/trainer.R $TEMPimageDescription $CLASSIFICATION Trained.Model";
	system "cp -r $TEMPfolder COPIA";
}

### PREDICT

if ($TASK ne 'Train'){
	print "Classify...\n";
	
	# test if training was performed
	unless (-e 'Trained.Model') {
		print "Train the model first!\nFile 'Trained.Model' not found\n";
	}

	# output name
	my $newClass = $dir . $FOLDER . '_predicted.csv';

	system "Rscript $PATHscript/predicter.R $TEMPimageDescription  Trained.Model $newClass";
	print "Done, check file $newClass\n";

}

