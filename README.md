# PEP_scaffolder <p>
use (homolog) proteins to scaffold genomes <p>
<b>DESCRIPTION</b><p>
   PEP_scaffolder is a genome scaffolding tool with protein sequences from studied species or close speciess. The protein sequences could be downloaed from Uniprot Database, NCBI NR database or denovo predicted from assembled transcriptome. The proteins are aligned to genome fragments using BLAT and the alignment file (PSL format with no heading) is used as the input file of PEP_scaffolder. PEP_scaffolder searches "guide" proteins, fragment of which were mapped to different genome fragments. Then the "guide" proteins orientated and ordered the genome fragments into longer scaffolds. 

SYSTEM REQUIREMENTS <p>
   The software, written with Shell script, consists of C++ programs and Perl programs. The C programs have been precompiled and therefore could be directly executed. To run Perl program, perl and Bioperl modules should be installed on the system. Further, the program required PSL file as input file. Thus, BLAT program should also be installed on the system. PEP_scaffolder has been tested and is supported on Linux. 

CAUTION <p>
   When running BLAT, you should use the following parameters: blat -t=dnax -q=prot genome-file protein-file psl-file -noHead 

INPUT FILES <p>
   PSL file and genome fragment fasta file are necessary for scaffolding. The psl file was generated using BLAT program with "-noHead" option. The genome fragment file should be fasta format, consistent with the subject sequences when using BLAT program. Another file, named overlapping file, contain two columns. This file is not necessary but will avoid some interesting genome fragments not being scaffolded. 

COMMANDS AND OPTIONS <p>
   PEP_scaffolder is run via the shell script: PEP_scaffolder.sh found in the base installation directory.

   Usage info is as follows:

   Required: <p>
   -d : the directory where the programs are in. <p>
   -i : the output of transcripts alignment with BLAT. <p>
   -j : the genome fragments fasta file which will be scaffolded and was used as the database when aligning proteins. <p>
   Optional: <p>
   -r : some fragments which you might be interesting and will not be scaffolded. The file has two columns per row. One row stand for that two fragments might be connected and should not be scaffolded. <p>
   -l : the threshold of alignment length coverage (default:0.95). If one protein has a hit of which length coverage was over the threshold, then this protein would be filtered out.<p>
   -p : the threshold of alignment identity (default: 0.9). If one alignment has an identity over the threshold, then the alignment is kept for the further analysis. <p>
   -o : the directory where the output file is stored. The default output directory is equal to the program directory. <p>
   -e : The maximal intron length between two exons (default: 100kb). <p>
   -f : the minimal number of supporting protein (default: 1). If the number of the supporting proteins for the connection is over the frequency, then this connection is reliable. <p>

   Note: a typical PEP_scaffolder command might be: <p>
   sh PEP_scaffolder.sh -d ./ -i input.psl -j genome.fasta <p>

OUTPUT FILES <p>
   When PEP_scaffolder completes, it will create an PEP_scaffolder.fasta output file in the output_dir/ output directory. 

SPEED <p>
   PEP_scaffolder spent about one minute in scaffolding fly genome contigs with a psl file generated from alignment of 30362 proteins. The sequencing alignment using BLAT s time-consuming (about 27 minutes to align 30362 proteins). We recommend splitting the proteins into multiple pieces and running the alignments simultaneously.
