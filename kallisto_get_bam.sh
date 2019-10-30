#!/bin/bash

# run fastqc and kallisto on all fastq files
# requirements:
# fastqc-0.11.5
# kallisto-0.43.1

function fastqc(){
	sbatch --mem 6G -o /dev/null --wrap "source fastqc-0.11.5; fastqc -o results/$1 --extract -f fastq $2"
}

function kallisto(){
	sbatch --mem 10G -o results/$1/${3}_kallistobam.log  -J $3 -n 2 --wrap "source kallisto-0.43.1; kallisto quant -i /hpc-home/dingp/kallisto_Ram/AtRTDv2_QUASI_kallisto_index_v2  -o results/$1/${3}_kallisto_bam --genomebam --gtf /hpc-home/shrestha/workarea/pingtao/rnaseq_bgiseq500_seti/AtRTDv2_QUASI_19April2016.gtf -b 100 --single -l 170 -s 10 $2"
}

for filename in /tsl/data/reads/jjones/dingp_rnaseq_bgiseq500_seti_eti_2018/*/*/raw/*.fq.gz; do
	sample=$(dirname $filename | sed 's%/tsl/data/reads/jjones/dingp_rnaseq_bgiseq500_seti_eti_2018%%' | sed 's%/% %g' | awk '{print $1}')
	identifier=$(basename $filename | sed 's/.fq.gz//')
	if [[ "$@" =~ "fastqc" ]]; then
		fastqc $sample $filename
	fi

	if [[ "$@" =~ "kallisto" ]]; then
		kallisto $sample $filename $identifier
	fi
done
