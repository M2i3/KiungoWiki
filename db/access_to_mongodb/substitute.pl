#!/usr/bin/perl

$string1 = shift(@ARGV);
$string2 = shift(@ARGV);

while(1){
    $file_list = shift(@ARGV);
    
    if(!$file_list){
	exit;
    }

    @files = split("\n",`ls $file_list`);
    
    for($ifile = 0; $ifile <= $#files; $ifile++){
	$file = $files[$ifile];
	
	print STDOUT "Processing $file \n";
	$lines = `cat $file`;
	$lines =~ s/$string1/$string2/ge;
	
	open(OUTFILE, "> $file") || die "Cannot open $file\n";
	select(OUTFILE);
	print $lines
    }

    print STDOUT "Done.\n";
}
