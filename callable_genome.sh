#!/bin/bash

# Usage info
usage() {
        echo "Usage: ./${0##*/} --input <INPUT> [ --length <INT> ] [--gap_extension <INT> ] [ --threads <INT> ] [ -h ]"
}
show_help() {
        usage
        cat << EOF
Use the GEM-library (installed in your \$PATH) and a gap correction for obtain the callable genome.
	
	Options:
        -h  | --help	display this help and exit
        -i  | --input <INPUT>	FASTA file to compute the callable genome
        -l  | --length <INT>	read length for the mapping [default=100]
        -g  | --gap_extension <INT>	expand the gap regions INT bp [default=5]
        -t  | --threads <INT>	number of threads to use with gem-mappability [default=2]
EOF
}

# function for check the error
checkError() {
	if [ $1 -ne 0 ]; then
		echo "Unexpected error running the pipeline"
		exit 1
	fi
}

# Default values
length=100
threads=2
gap=5

# Parsing command line
while [ $# -ne 0 ];
do
	opt=$1
	shift
	case "$opt" in
		"-h" | "--help"			 )	show_help 1>&2
									exit 0
									;;
		"-i" | "--input"		 )	input=$1
									shift
									;;
		"-l" | "--length"		 )	length=$1
									shift
									;;
		"-g" | "--gap_extension" )	gap=$1
									shift
									;;
		"-t" | "--threads"		 )	threads=$1
									shift
									;;
		*						 )	echo "Invalid option: $opt" 1>&2
									usage 1>&2
									exit 1
									;;
	esac
done

# Checking input
if [ ! -f $input ] || [ -z $input ]; then
	usage 1>&2
	echo "Error: Input not provided or does not exists" 1>&2
	exit 1
fi

## Checking that the programs are in the PATH
if [ -z $(which gem-indexer) ] && [ -z $(which gem-do-index) ];
	then echo "Error: gem-indexer or gem-do-index should be in your \$PATH" >&2
	exit 1
fi

if [ -z $(which gem-mappability) ]; 
	then echo "Error: gem-mappability should be in your \$PATH" >&2
	exit 1
fi

if [ -z $(which bedtools) ]; 
	then echo "Error: bedtools should be in your \$PATH" >&2
	exit 1
fi

echo "Starting generating callable genome at `date`"

# Chreating output directory
echo "Generating output folder"
OUTPUT_FOLDER="$(dirname $input)/mappable"
mkdir -p $OUTPUT_FOLDER

# First create the gem-index
echo "Indexing reference"
INDEXER="gem-indexer"
if [ -z $(which gem-indexer) ]; then INDEXER="gem-do-index"; done
$INDEXER -i ${input} -o ${OUTPUT_FOLDER}/${input%.*}

checkError $?

# Second compute the mappability
echo "Computing mappability"
gem-mappability -I ${OUTPUT_FOLDER}/${input%.*}.gem -o ${OUTPUT_FOLDER}/${input%.*} -l ${length} -t ${threads}

checkError $?

# Third compute the mappable and gap bed
echo "Parsing mappability"
java -jar $(dirname $0)/java/MappabilityTools.jar mappable -i ${OUTPUT_FOLDER}/${input%.*}.mappability -o ${OUTPUT_FOLDER}/${input%.*}.mappable.bed

checkError $?

echo "Obtaining gaps"

java -jar $(dirname $0)/java/MappabilityTools.jar gaps -i ${input} -o ${OUTPUT_FOLDER}/${input%.*}.${gap}Gap.bed -e ${gap}

checkError $?

# Fourth compute the callable genome merging both
echo "Combining mappable and gaps"
betools subtract -a ${OUTPUT_FOLDER}/${input%.*}.mappable.bed -b ${OUTPUT_FOLDER}/${input%.*}.${gap}Gap.bed > ${OUTPUT_FOLDER}/${input%.*}.callable.bed

checkError $?

echo "Callable genome generated at `date`"

exit 1
