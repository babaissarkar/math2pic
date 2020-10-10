#! /usr/bin/env perl

#  ss_math2pic.pl

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

# Subhrman Sarkar, 30.09.2020

# This program scans a text document for math formulas
# delimited by two $ characters (i.e., $ x^2 $),
# copies them to files "outn.tex"
# (out0.tex, out1.tex etc., n is the nth formula),
# and converts them to pictures using latex
# and the companion shell script ss_tex2jpg.

use strict;
use warnings;

# File names
# All file names start with "f"
my $fdocin = shift @ARGV;                   # Input file
my $fdocout = $fdocin =~ s/\./-gen\./r;     # Output file
#print "$fdocout\n";

# File handles
my ($docin, $docout); # Handle for the input and outputs
my $texout; # Handle for the temporary tex file

my $line;

####
my $n = 0; # Counter for no. of equations in the input

open($docin, "<", $fdocin) or die "Can't open file $fdocin";
open($docout, ">", $fdocout) or die "Can't open file $fdocout";

while($line=<$docin>)
{
	my ($ftexout, $fimgout, $imghtml);
	$ftexout = "out".$n.".tex";
	$fimgout = "out".$n.".jpg";

	# The tex mathmode equations are replaced with a html img tag 
	$imghtml = "<br/><img src=\"$fimgout\" alt=\"$ftexout\" style=\"margin:10px 10px\" /><br/>";

	if($line =~ s/\$(.+)\$/$imghtml/g)
	{
		# Extract the equations inside $$ and write to a .tex file.
		open($texout, ">", $ftexout) or die "Can't open file $ftexout";
		printf "Math expression %s found : %s.\n", $n, $1;

		# Writing to temporary tex file.
		print $texout "\\begin{math}\n";
		print $texout "$1\n";
		print $texout "\\end{math}\n";
		close($texout);
		
		print "Converting...\n";
		# Compile the .tex file to generate the .jpg of the equation
		system("ss_tex2jpg $ftexout");
		# Remove intermediate .tex file
		system("rm $ftexout");
		print "Equation $n converted and written to out$n.jpg\n";
		
		$n += 1;
	}

	# Writing output file
	print $docout $line;
}

print "Output written to $fdocout.\n";

close($docout);
close($docin);
