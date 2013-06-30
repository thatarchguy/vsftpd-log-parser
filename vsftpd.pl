#!/bin/usr/perl/
#programmer: Kevin Law
#Version: 0.5

use Carp;
my $max_records = '10'; #change for max records. 0 is no limit
 open (FH, '<', "/var/log/vsftpd.log")
  		or die "error, Cannot open $file";

   
while (<FH>) {
	$line = $_;
	  
	#next if $line =~ m/^\s*$/;
	#next if $line =~ m/^\s*#/; 
	chomp($line);
  


			@bits = split(/\s+/, $line);
			$day		= $bits[0];
			$date		= $bits[2];
			$time		= $bits[3];
			$year		= $bits[4];
			$pid_label	= $bits[5]; 
			$pid		= $bits[6];  
			$user		= $bits[7];
			$status		= $bits[8];
			$action		= $bits[9];
			$client		= $bits[10];
			$ip			= $bits[11];
			$file		= $bits[12];
			$b			= $bits[13];
                   if ( $user =~ /CONNECT:/ ) {
						$day		= $bits[0];
						$date		= $bits[2];
						$time		= $bits[3];
						$year		= $bits[4];
						$pid_label	= $bits[5]; 
						$pid		= $bits[6];  
						$user		= $bits[7];
						$client		= $bits[8];
						$ip			= $bits[9];
						$hits_by_connect_for{$ip}++
					}
					
					if ( $result =~ /LOGIN:/ ) {
						$hits_by_result_for{$action}++;
					}
                    
					#Search engines look for robots.txt
					if ( $url =~ m!^(/robots.txt)! ) {     
						$search++;
					} 
					#Scanners generaly hit a lot of pages that do not exist
					if ( $result == "404") {
					$scanners++;
					}
			
#print "$day\t$time\t$user\t$ip\t$file\t$b\n"; debugging purposes

#add stats to our counters
$hits_by_day_for{$day}++;
$hits_by_cip_for{$ip}++;
$hits_by_url_for{$file}++;




} #end while

close (FH);

#         Hash Reference          "Name"          "Top N" to show
Display(\%hits_by_day_for,      'By Day',        $max_records);
Display(\%hits_by_cip_for,      'Actions By CIP',         $max_records);
Display(\%hits_by_url_for,      'By URL',         $max_records);
Display(\%hits_by_connect_for,  'By Connect',   $max_records);

#print unparsed logs. useful for weird stuff that didn't match the regex
if ( @unparsed ) {
    print STDERR "\n";
    foreach my $unparsed ( @unparsed ) {
        print STDERR "unparsed: $unparsed\n";
    }
}

######## Subs ########

# Returns when $max_records recahed
sub Display {
    @_ == 3 or carp 'Sub Display(\%hash, "name", $max_records)';
    my ( $hash_ref, $name, $max_records, ) = @_;
    my $counter = 0;

    print STDERR "\nCount\t$name\n";
    foreach my $hit (sort { $$hash_ref{$b} <=> $$hash_ref{$a} } keys %{$hash_ref}) {
        print STDERR $$hash_ref{$hit} . "\t$hit\n";
        $counter++;
        return if ( $max_records and $counter >= $max_records );
    }
} # end of sub Display
