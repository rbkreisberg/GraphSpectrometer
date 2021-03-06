#!/usr/bin/env bash
#This will only work if the input file has .pwpv exstension
source setvars.sh

PWFILE=$1
OUTDIR=$2
COL=$3


#fnbase=2012_09_19.pwpv

cd ${OUTDIR}
echo PARSING FILE AND FINDING MDS
seq 1 -.1 0 | xargs --max-procs=1 -I CUTOFF  \
python ${GSPEC}/runMDS.py \
${PWFILE} CUTOFF $COL