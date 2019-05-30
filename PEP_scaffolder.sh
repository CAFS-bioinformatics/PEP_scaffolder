#!/bin/bash
#!/bin/sh
lc=0.95
pid=0.90
output=./
intron=150000
frequency=1
N=100
overlap=
while getopts ":d:l:p:r:e:f:i:j:o:n:" opt; do
  case $opt in
    d)
      directory=$OPTARG
      vardir=1
      ;;
    o)
      output=$OPTARG
      ;;
    l)
      lc=$OPTARG   #get the value
      ;;
    p)
      pid=$OPTARG
      ;;
    e)
      intron=$OPTARG
      ;;
    f)
      frequency=$OPTARG
      ;;
    n)
      N=$OPTARG
      ;;
    i)
      inputfile=$OPTARG
      varpsl=1
      ;;
    j)
      contig=$OPTARG
      varfasta=1
      ;;
    r)
      overlap=$OPTARG
      ;;
    ?)
  
      echo "Usage: sh `basename $0` -d Program_DIR -i inputfile.psl -j contig.fasta";
      
      echo "       [-l length_coverage (default coverage is 0.95)]";
      echo "       [-p identity (default identity is 0.90)]";
      echo "       [-o output_directory (default directory is current directory)]"; 
      echo "       [-r overlap.agp (which is not necessary )]";
      echo "       [-e the maximal intron( default intron size is 150000 bp)]";
      echo "       [-f the minimal number of supporting proteins (default number is 1)]";
      echo "       [-n N number (100 N is default)]";
      echo "";
      echo "       The arguments '"-d Program_DIR"' , '"-i inputfile.psl"' and '"-j contig.fasta"' are mandatory." >&2
      echo "";
      echo "       -d        C++ and Perl programs directory path, -d is mandatory.";
      echo "       -i        PSL file (result of BLAT with '-noHead option'), -i is mandatory.";
      echo "       -j        Pre-assembly contig FASTA file, -j is mandatory.";
      echo "       -l        length_coverage, the coverage threshold of alignment length to the full length (coverage of 0.95 is default).";
      echo "       -p        identity, the identity threshold of alignment (Default identity is 0.90).";
      echo "       -o        output directory, where you will store assembly result, the default directory is current directory, ";
      echo "                 You can mkdir an output-directory before assembly.";
      echo "       -e        the maximal intron length. The default length is 150000 bp.";
      echo "       -f        the minimal number of supporting proteins, default value of which is 1.";
      echo "       -r        overlap contigs according to AGP file.";
      echo "       -n        N number you want to indicate a gap if the gap is larger than the median intron length.";
      echo "";
      
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ $vardir -eq 1 ]] && [[ $varpsl -eq 1 ]] && [[ $varfasta -eq 1 ]]; then

	`$directory/./calculate-pid $inputfile $output/overpid$pid.file $output/lesspid$pid.file $lc $pid`;
	`$directory/./calculate-lc $output/overpid$pid.file $output/overlc$lc.file $output/lesslc$lc.file $lc $pid`;
	`sort -k10,10 -k14,14 -k12,12n -k13,13nr -k22,22nr $output/lesslc$lc.file > $output/sort.lesslc$lc.file`;
	`$directory/convert $output/sort.lesslc$lc.file $output/convert.alignment`;
	`sort -k2,2 -k3,3n -k4,4nr $output/convert.alignment > $output/sort.convert.alignment`;
	`$directory/order $output/sort.convert.alignment $output/order.convert.alignment`;
	`$directory/form_block $output/order.convert.alignment $output/block`;
	`$directory/delete_block $output/block $output/retained.block `;
	`$directory/search_guider $output/retained.block $output/guider`;
	`$directory/link_block $output/guider $output/linker $intron`;
	`sort -k1,1 -k2,2n -k27,27n -k16,16nr $output/linker > $output/sort.linker`;
	`$directory/delete_linker $output/sort.linker $output/retained.linker`;
	`$directory/delete_same_fragment $output/retained.linker $output/linker.dif`;
	`$directory/exon_length $output/linker.dif $output/linker.length`;
	`$directory/convert_linker $output/linker.length $output/linker.convert`;
	`sort -k2,2 -k3,3 -k4,4nr $output/linker.convert > $output/linker.sort`;
	`$directory/select $output/linker.sort $output/linker.select`;
	`cut -f 2-4 $output/linker.select |sort -k1,1 -k2,2 > $output/connections`;
	`$directory/count_connection_frequency $output/connections $output/connections.frequency`;
	`$directory/find_reliable_connection $output/connections.frequency $output/reliable.connections $frequency`;
	`sort -k1,1 -k3,3nr $output/reliable.connections > $output/sort.reliable.connection`;
	`$directory/find_end_node $output/sort.reliable.connection $output/end.node`;
	`sort -k2,2 -k3,3nr $output/end.node > $output/sort.end.node`;
	`$directory/find_start_node $output/sort.end.node $output/start.node`;
	`$directory/select_nodes $output/start.node $output/both.nodes`;
	`perl $directory/form_initial_path.pl $output/both.nodes $N > $output/both.path`;
	`sed 's/->/\n/g' $output/both.path |sed 's/\/r//g' |grep -v "N(" |sort -u > $output/scaffolded.fragment.id`;
	`perl $directory/filter_scaffold.pl $output/linker.dif $output/scaffolded.fragment.id 7 > $output/temp`;
	`perl $directory/filter_scaffold.pl $output/temp $output/scaffolded.fragment.id 20 > $output/filtered.linker.dif`;
	`$directory/exon_length $output/filtered.linker.dif $output/filtered.linker.length`;
	`$directory/convert_linker $output/filtered.linker.length $output/filtered.linker.convert`;
	`sort -k2,2 -k3,3 -k4,4nr $output/filtered.linker.convert > $output/filtered.linker.sort`;
	`$directory/select $output/filtered.linker.sort $output/filtered.linker.select`;
	`cut -f 2-4 $output/filtered.linker.select |sort -k1,1 -k2,2 > $output/filtered.connections`;
	`$directory/count_connection_frequency $output/filtered.connections $output/filtered.connections.frequency`;
	`$directory/find_reliable_connection $output/filtered.connections.frequency $output/filtered.reliable.connections $frequency`;
	`sort -k1,1 -k3,3nr $output/filtered.reliable.connections > $output/sort.filtered.reliable.connections `;
	`$directory/find_end_node $output/sort.filtered.reliable.connections $output/filtered.end.node`;
	`sort -k2,2 -k3,3nr $output/filtered.end.node > $output/sort.filtered.end.node`;
	`$directory/find_start_node $output/sort.filtered.end.node $output/filtered.start.node`;
	`$directory/select_nodes $output/filtered.start.node $output/filtered.both.nodes`;
	`cat $output/both.nodes $output/filtered.both.nodes |sort -u > $output/nodes`;
	`$directory/overlap $output/nodes $overlap $output/final.nodes $output/different.nodes`;
	`perl $directory/form_path.pl $output/final.nodes $output/overlc$lc.file > $output/final.path`;
	`sed 's/->/\n/g' $output/final.path |sed 's/\/r//g' |grep -v "N(" |sort -u > $output/scaffolded.fragment.id`;
	`perl $directory/generate_scaffold.pl $contig $output/final.path scaffold_PEP_ > $output/scaffold.fasta`;
	`perl $directory/generate_unscaffold.pl $contig $output/scaffolded.fragment.id  > $output/unscaffold.fasta`;
	`cat $output/scaffold.fasta $output/unscaffold.fasta >$output/PEP_scaffolder.fasta`;
	
exit 1

else
	echo "Usage: sh `basename $0` -d Program_DIR -i inputfile.psl -j contig.fasta";

        echo "       [-l length_coverage (default coverage is 0.95)]";
        echo "       [-p identity (default identity is 0.90)]";
        echo "       [-o output_directory (default directory is current directory)]";
        echo "       [-r overlap.agp (which is not necessary )]";
        echo "       [-e the maximal intron( default intron size is 150000 bp)]";
        echo "       [-f the minimal number of supporting proteins (default number is 1)]";
        echo "       [-n N number (100 N is default)]";
	echo "";
	echo "       The arguments '"-d Program_DIR"' , '"-i inputfile.psl"' and '"-j contig.fasta"' are mandatory." >&2
	echo "";
	echo "       -d        C++ and Perl programs directory path, -d is mandatory.";
	echo "       -i        PSL file (result of BLAT), -i is mandatory.";
	echo "       -j        Pre-assembly contig FASTA file, -j is mandatory.";
	echo "       -l        length_coverage, the coverage threshold of alignment length to full length (coverage of 0.95 is default).";
	echo "       -p        identity, the identity threshold of alignment (Default identity is 0.9).";
	echo "       -o        output directory, where you will put assembly result. The default directory is current directory, ";
	echo "                 You can mkdir an output-directory before assembly.";
	echo "       -e        the maximal intron size, default is 150000 bp.";
	echo "       -f        the minimal number of supporting proteins, default value of which is 1.";
	echo "       -r        overlap contigs according to AGP file.";
	echo "       -n        N number you want to insert to indicate a gap if the gap is larger than the median intron size";
	echo "";
	exit 1
	
fi
