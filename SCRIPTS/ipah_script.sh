#!/bin/bash

module load blast+ 
#version blastn: 2.10.1+
#Package: blast 2.10.1

usage() {
        echo
        echo "###### This script is used for blasting genomes against ipaH  gene  #####"
        echo "usage : bash ipaH_script.sh -l <your_list> -o <output_directory> -p <databases_pathway>"
        echo
        echo "options :"
        echo "-l        List file contains FASTA pathway"
        echo "-o        Output directory"
        echo "-p        Pathway to databases directory"
        echo "-h        Display this help and exit"
        echo
}


while getopts "l:o:p:h" option; do
        case "${option}" in
                l) LIST=${OPTARG};;
                o) OUTDIR=${OPTARG};;
                p) DBPATHWAY=${OPTARG};;
                h) # display usage
                        usage
                        exit;;
                \?) # incorrect option
                        echo "Error: Invalid option"
                        usage
                        exit;;
        esac
done

echo $LIST
echo $OUTDIR

if [ ! -d ./${OUTDIR} ]
then
        mkdir ${OUTDIR}
fi

for database in ${DBPATHWAY}/*.fasta; do makeblastdb -dbtype nucl -in ${database}; done

BLAST_OPT="-num_threads 2 -num_alignments 10000 -outfmt 6 -word_size 11 -dust no"
date="`date '+%d_%m_%Y__%H_%M_%S'`"
echo "name;ipaH" > ${OUTDIR}/all_summary_${date}.csv

for y in $(cat ${LIST})
do
        echo ${y}
        ipaH=""
                
        NAMEDIR=$(basename $y .fasta)
        if [ ! -d ${OUTDIR}/${NAMEDIR} ]
        then
                mkdir ${OUTDIR}/${NAMEDIR}
        elif [ -d ${OUTDIR}/${NAMEDIR} ]
        then
                rm -r ${OUTDIR}/${NAMEDIR}/*
        fi

        sed 's/_/~/g' ${y} > ${OUTDIR}/${NAMEDIR}/$(basename ${y} .fasta)_parsed.fasta
        f="${OUTDIR}/${NAMEDIR}/$(basename ${y} .fasta)_parsed.fasta"

	blastn -db ${DBPATHWAY}/ipaH_common.fasta -query ${f} -out ${OUTDIR}/${NAMEDIR}/ipaH_blastout.txt ${BLAST_OPT}  
        awk -F "\t|_" '{if ($6>=98 && ($7/$5)*100>=45) print $0}' ${OUTDIR}/${NAMEDIR}/ipaH_blastout.txt > ${OUTDIR}/${NAMEDIR}/ipaH_records.txt
        ipaH=$([[ -s ${OUTDIR}/${NAMEDIR}/ipaH_records.txt ]] && echo "POS" || echo "NEG") 
	
	echo "${y};$ipaH" | tee -a ${OUTDIR}/all_summary_${date}.csv
rm ${f}
done

