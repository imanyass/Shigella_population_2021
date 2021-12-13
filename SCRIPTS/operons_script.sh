#!/bin/bash

module load blast+ #version 

usage() {
        echo
        echo "###### This script is used for blasting genomes against mtl and tna operons  #####"
        echo "usage : bash operons_script.sh -l <your_list> -o <output_directory> -p <databases_pathway>"
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
echo "name;tnaA;tnaB;tnaC;mtlA;mtlD;mtlR" > ${OUTDIR}/all_summary_${date}.csv

for y in $(cat ${LIST})
do
        echo ${y}
        tnaA=""
        tnaB=""
	tnaC=""
	mtlA=""
	mtlD=""
        mtlR=""

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

	echo "#### BLAST against tna operon ####"
	blastn -db ${DBPATHWAY}/tnaA.fasta -query ${f} -out ${OUTDIR}/${NAMEDIR}/tnaA_blastout.txt ${BLAST_OPT}  
        awk -F "\t|_" '{if ($6>=98 && ($7/$5)*100>=45) print $0}' ${OUTDIR}/${NAMEDIR}/tnaA_blastout.txt > ${OUTDIR}/${NAMEDIR}/tnaA_records.txt
        tnaA=$([[ -s ${OUTDIR}/${NAMEDIR}/tnaA_records.txt ]] && echo "POS" || echo "NEG") 
	echo "tnaA:" $tnaA
	
	blastn -db ${DBPATHWAY}/tnaB.fasta -query ${f} -out ${OUTDIR}/${NAMEDIR}/tnaB_blastout.txt ${BLAST_OPT}
        awk -F "\t|_" '{if ($6>=98 && ($7/$5)*100>=45) print $0}' ${OUTDIR}/${NAMEDIR}/tnaB_blastout.txt > ${OUTDIR}/${NAMEDIR}/tnaB_records.txt
        tnaB=$([[ -s ${OUTDIR}/${NAMEDIR}/tnaB_records.txt ]] && echo "POS" || echo "NEG")
	echo "tnaB:" $tnaB

	blastn -db ${DBPATHWAY}/tnaC.fasta -query ${f} -out ${OUTDIR}/${NAMEDIR}/tnaC_blastout.txt ${BLAST_OPT}
        awk -F "\t|_" '{if ($6>=98 && ($7/$5)*100>=45) print $0}' ${OUTDIR}/${NAMEDIR}/tnaC_blastout.txt > ${OUTDIR}/${NAMEDIR}/tnaC_records.txt
        tnaC=$([[ -s ${OUTDIR}/${NAMEDIR}/tnaC_records.txt ]] && echo "POS" || echo "NEG")
	echo "tnaC:" $tnaC

	echo "#### BLAST against mtl operon ####"
	blastn -db ${DBPATHWAY}/mtlA.fasta -query ${f} -out ${OUTDIR}/${NAMEDIR}/mtlA_blastout.txt ${BLAST_OPT}
        awk -F "\t|_" '{if ($6>=98 && ($7/$5)*100>=45) print $0}' ${OUTDIR}/${NAMEDIR}/mtlA_blastout.txt > ${OUTDIR}/${NAMEDIR}/mtlA_records.txt
        mtlA=$([[ -s ${OUTDIR}/${NAMEDIR}/mtlA_records.txt ]] && echo "POS" || echo "NEG")
	echo "mtlA:" $mtlA
	
	blastn -db ${DBPATHWAY}/mtlD.fasta -query ${f} -out ${OUTDIR}/${NAMEDIR}/mtlD_blastout.txt ${BLAST_OPT}
        awk -F "\t|_" '{if ($6>=98 && ($7/$5)*100>=45) print $0}' ${OUTDIR}/${NAMEDIR}/mtlD_blastout.txt > ${OUTDIR}/${NAMEDIR}/mtlD_records.txt
        mtlD=$([[ -s ${OUTDIR}/${NAMEDIR}/mtlD_records.txt ]] && echo "POS" || echo "NEG")
	echo "mtlD:" $mtlD

	blastn -db ${DBPATHWAY}/mtlR.fasta -query ${f} -out ${OUTDIR}/${NAMEDIR}/mtlR_blastout.txt ${BLAST_OPT}
        awk -F "\t|_" '{if ($6>=98 && ($7/$5)*100>=45) print $0}' ${OUTDIR}/${NAMEDIR}/mtlR_blastout.txt > ${OUTDIR}/${NAMEDIR}/mtlR_records.txt
        mtlR=$([[ -s ${OUTDIR}/${NAMEDIR}/mtlA_records.txt ]] && echo "POS" || echo "NEG")
	echo "mtlR:" $mtlR

	echo "${y};$tnaA;$tnaB;$tnaC;$mtlA;$mtlD;$mtlR" | tee -a ${OUTDIR}/all_summary_${date}.csv

rm ${f}
done

