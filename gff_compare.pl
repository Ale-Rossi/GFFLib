#!/usr/bin/perl
use strict;
use GFFFile;
use GFFUtils;

my $usage =
"gff_compare.pl <GFF A> <GFF B>\n\n";

die $usage if scalar(@ARGV) != 2;

my $gff_filename_a       = $ARGV[0];
my $gff_filename_b       = $ARGV[1];

my $gff_a = GFFFile::new($gff_filename_a);
$gff_a->read();

my $gff_b = GFFFile::new($gff_filename_b);
$gff_b->read();

my $gffAGenes = $gff_a->get_genes_hash();
my $gffBGenes = $gff_b->get_genes_hash();

# Ordering genes based on template name and start coord
my @gffGenesArray = ( values %{$gffAGenes}, values %{$gffBGenes} ) ;

GFFUtils::sort_gene_arrays( \@gffGenesArray, 0 );

for ( my $i1 = 0; $i1 <  scalar(@gffGenesArray); $i1++ ){
	
	#print $gffGenesArray[ $i1 ]->toGFF();
	#getc();
	
	for ( my $i2 = $i1 + 1; $i2 <  scalar(@gffGenesArray); $i2++ ){
		last if ( not $gffGenesArray[ $i1 ]->overlaps( $gffGenesArray[ $i2 ] ) );
		next if ( $gffGenesArray[ $i1 ]->get_filename() eq $gffGenesArray[ $i2 ]->get_filename() );
		
		my $gene_a;
		my $gene_b;
		
		if  ( $gffGenesArray[ $i1 ]->get_filename() eq $gff_filename_a &&
			  $gffGenesArray[ $i2 ]->get_filename() eq $gff_filename_b ){
			  $gene_a = $gffGenesArray[ $i1 ];
			  $gene_b = $gffGenesArray[ $i2 ];
			  	
		}elsif( $gffGenesArray[ $i1 ]->get_filename() eq $gff_filename_b &&
			    $gffGenesArray[ $i2 ]->get_filename() eq $gff_filename_a ){
			  $gene_b = $gffGenesArray[ $i1 ];
			  $gene_a = $gffGenesArray[ $i2 ];
			    	
		}else{
			die "Unknown filenames:\n\t" . $gffGenesArray[ $i1 ]->get_filename() . "\n\t" . $gffGenesArray[ $i2 ]->get_filename() . "\n";
		}
		
		my $exon_comparison = GFFUtils::print_exon_comparison( $gene_a, $gene_b);
		
		if( $exon_comparison ne '' ){
			print "GENE:\t" . $gene_a->get_id() . ":" . $gene_a->get_chrom() . ":" . $gene_a->get_start() . "-" . $gene_a->get_end() . ":" . $gene_a->get_strand() . ":exons=" . $gene_a->num_exons() . "\t" . 
		    	  			  $gene_b->get_id() . ":" . $gene_b->get_chrom() . ":" . $gene_b->get_start() . "-" . $gene_b->get_end() . ":" . $gene_a->get_strand() . ":exons=" . $gene_b->num_exons() . "\n";
		}
		      
				      
		      
	}
}