#!/usr/bin/env bash
source setvars.sh

FMATRIX=$1
BLACKLIST=$2
ADIR=$3
OUTDIR=${ADIR}/rf-pred/
TARGET=$4
NAME=$(basename $FMATRIX)
TREES=${OUTDIR}/${NAME}_${5}
DEFMTRY=100
MTRY=${6:-$DEFMTRY}

set +e
cd ${OUTDIR}

echo RUNNING RANDOM FOREST WITH BLACKLIST
echo RFACE $RFACE
echo FMATRIX $FMATRIX
echo TREES $TREES
echo BLACKLIST $BLACKLIST
$RFACE -I $FMATRIX \
 -B ${BLACKLIST} --saveForest ${TREES} \
 -i $TARGET -n 12800 -m ${MTRY} -a 1000 -s 4 -e 8


JSONDIR=${OUTDIR}/layouts/$(basename $TREES)/hodge


mkdir -p $JSONDIR
if [ -e "${TREES}" ]
then
	cd ${JSONDIR}
	echo PARSING PREDICTOR 
	seq 0 1 0 | xargs -I CUTOFF  \
	python ${GSPEC}/parseRfPred.py ${TREES} CUTOFF
	echo FINDING HODGE RANK
	ls ${JSONDIR}/* | xargs -I FILE  \
	python ${GSPEC}/plotpredDecomp.py FILE

	TREENAME=$(basename $TREES)
	echo Feature Matrix $FMATRIX Predictor $TREES
	LEAFDIR=${ADIR}/rf-leaves
	BRANCHEDIR=${ADIR}/rf-branches
	BRANCHEMATDIR=${ADIR}/rf-branch-matrix

	mkdir -p $LEAFDIR
	mkdir -p $BRANCHEDIR
	mkdir -p $BRANCHEMATDIR

	BRANCHFILE=${BRANCHEDIR}/${TREENAME} 
	BRANCHMATFILE=${BRANCHEMATDIR}/${TREENAME} 
	LEAFFILE=${LEAFDIR}/${TREENAME}
	${LCOUNT} -branches="$BRANCHFILE" -leaves="$LEAFFILE" \
	-rfpred="${TREES}" -fm="${FMATRIX}"
	if [ -e $LEAFFILE ] 
	then	
		python ${GSPEC}/pruneLeaves.py $LEAFFILE $FMATRIX

		for INERRFILE in ${LEAFFILE}*
		do
			INNERNAME=$(basename $INERRFILE)
			LEAFLAYOUT=${LEAFDIR}/layouts/${INNERNAME}/fiedler
			#if [ ! -d "$LEAFLAYOUT" ]; 
			#then

				mkdir -p $LEAFLAYOUT
				cd $LEAFLAYOUT
				seq 0 2 0 | xargs -P 8 -I CUT python ${GSPEC}/parseByCol.py ${INERRFILE} CUT 2
				for JSONFILE in ${LEAFLAYOUT}/*
				do
					python ${GSPEC}/annotateLeaves.py $JSONFILE $FMATRIX $BRANCHFILE
				done

				cd -
			#fi
			RMEMPTY $LEAFLAYOUT
			RMEMPTY ${LEAFDIR}/layouts/${INNERNAME}
			JSONFILE=${LEAFLAYOUT}/${INNERNAME}.cutoff.0.0.json
			python ${GSPEC}/branchMatrix.py $JSONFILE $FMATRIX $BRANCHFILE $BRANCHMATFILE
			echo View the results at http://glados1.systemsbiology.net:3335/#branches/${TREES}/branch
			
		done
	fi
	RMEMPTY ${LEAFDIR}/layouts 
	RMEMPTY $LEAFDIR
	RMEMPTY $BRANCHEDIR
	RMEMPTY $BRANCHEMATDIR
fi

set -e

cd ${OUTDIR}
RMEMPTY $JSONDIR
RMEMPTY ${OUTDIR}/layouts/$(basename $TREES)