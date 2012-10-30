#!/usr/bin/env bash
# usage ./runall.sh /titan/cancerregulome9/ITMI_PTB/public/analysis/ /titan/cancerregulome9/workspaces/users/rbressle/2012_09_18/blacklist.txt /titan/cancerregulome9/ITMI_PTB/public/analysis/layouts/
export NGSPECCORES=4
export NGSPECPLOTINGCORES=2
export RFACE=/titan/cancerregulome9/workspaces/rf-ace/bin/rf-ace
export GSPEC=/titan/cancerregulome9/ITMI_PTB/bin/GraphSpectrometer
ADIR=$1
BLACKLIST=$2

function RMEMPTY {
	if [ "$(ls -A $1)" ]; then
	     echo "$1 is not Empty"
	else
	    echo "$1 is Empty. Removeing."
	    rm -r $1
	fi
} 

#Loop over feature matrixes and run and layout rf-ace predictors
for FILE in ${ADIR}/feature_matrices/*
do
	echo Feature Matrix $FILE
	if [ -f $FILE ]
	then
		OUTDIRBASE=${ADIR}/rf-pred/
		LAYOUTS=${OUTDIRBASE}/layouts
		mkdir -p $LAYOUTS
		

		./runrf_no_bl.sh $FILE $OUTDIRBASE
		./runrf.sh $FILE $BLACKLIST $OUTDIRBASE
	fi
done

#Loop over pairwise results and run fiedler and mds
for FILE in ${ADIR}/pairwise/*
do
	echo Pairwise $FILE
	if [ -f $FILE ]
	then
		OUTDIRBASE=${ADIR}/pairwise/layouts/$(basename $FILE)
		OUTDIR=${OUTDIRBASE}/fiedler
		mkdir -p $OUTDIR
		
		./runpw.sh $FILE $OUTDIR 2
		RMEMPTY $OUTDIR

		OUTDIR=${OUTDIRBASE}/mds
		mkdir -p $OUTDIR
		RMEMPTY $OUTDIR
		RMEMPTY $OUTDIRBASE

	fi
done

#Loop over rf-ace filter results and run fiedler and mds
for FILE in ${ADIR}/rf-ace/*
do
	echo Pairwise $FILE
	if [ -f $FILE ]
	then
		OUTDIRBASE=${ADIR}/rf-ace/layouts/$(basename $FILE)
		OUTDIR=${OUTDIRBASE}/fiedler
		mkdir -p $OUTDIR
		
		./runpw.sh $FILE $OUTDIR 3
		RMEMPTY $OUTDIR

		OUTDIR=${OUTDIRBASE}/mds
		mkdir -p $OUTDIR
		RMEMPTY $OUTDIR
		RMEMPTY $OUTDIRBASE
	fi
done


