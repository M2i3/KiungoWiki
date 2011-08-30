#!/usr/bin/perl

while(1){
    $file_list = shift(@ARGV);
    
    if(!$file_list){
	exit;
    }

    @files = split("\n",`ls $file_list`);
    
    for($ifile = 0; $ifile <= $#files; $ifile++){
	$file = $files[$ifile];
	print STDOUT "Processing $file \n";
        @lines = split("\n",`cat $file`);
        $filecontent = $lines[0]."\n";
        for($iline = 1; $iline <= $#lines; $iline++){
           $filecontent = $filecontent.$iline.",".$lines[$iline]."\n";
        }
	open(OUTFILE, "> $file") || die "Cannot open $file\n";
	select(OUTFILE);
	print $filecontent
    }

    print STDOUT "Done.\n";
}
