#!/bin/bash
#bbwrap in=<infile> out=<outfile>

usage(){
echo "
BBWrap v34.x
Last modified April 21, 2015

Description:  Wrapper for BBMap to allow multiple input and output files for the same reference.

To index:                 bbwrap.sh ref=<reference fasta>
To map:                   bbwrap.sh in=<file,file,...> out=<file,file,...>
To map without an index:  bbwrap.sh ref=<reference fasta> in=<file,file,...> out=<file,file,...> nodisk
To map pairs and singletons and output them into the same file:
bbwrap.sh in1=read1.fq,singleton.fq in2=read2.fq,null out=mapped.sam append

BBWrap will not work with stdin and stdout, or histogram output.

Other Parameters:

in=<file,file>    Input sequences to map.
mapper=bbmap      Select mapper.  May be BBMap, BBMapPacBio, 
                  or BBMapPacBioSkimmer.
append=f          Append to files rather than overwriting them.  
                  If append is enabled, and there is exactly one output file,
                  all output will be written to that file.

***** All BBMap parameters can be used; see bbmap.sh for more details. *****
"
}

pushd . > /dev/null
DIR="${BASH_SOURCE[0]}"
while [ -h "$DIR" ]; do
  cd "$(dirname "$DIR")"
  DIR="$(readlink "$(basename "$DIR")")"
done
cd "$(dirname "$DIR")"
DIR="$(pwd)/"
popd > /dev/null

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/"
CP="$DIR""current/"
NATIVELIBDIR="$DIR""jni/"

z="-Xmx1g"
z2="-Xms1g"
EA="-ea"
set=0

if [ -z "$1" ] || [[ $1 == -h ]] || [[ $1 == --help ]]; then
	usage
	exit
fi

calcXmx () {
	source "$DIR""/calcmem.sh"
	parseXmx "$@"
	if [[ $set == 1 ]]; then
		return
	fi
	freeRam 3200m 84
	z="-Xmx${RAM}m"
	z2="-Xms${RAM}m"
}
calcXmx "$@"

bbwrap() {
	if [[ $NERSC_HOST == genepool ]]; then
		module unload oracle-jdk
		module load oracle-jdk/1.8_64bit
		module load pigz
		module load samtools
	fi
	local CMD="java -Djava.library.path=$NATIVELIBDIR $EA $z -cp $CP align2.BBWrap build=1 overwrite=true fastareadlen=500 $@"
	echo $CMD >&2
	eval $CMD
}

bbwrap "$@"
