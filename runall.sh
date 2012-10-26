#!/usr/bin/env bash
# usage ./runall.sh /titan/cancerregulome9/ITMI_PTB/public/analysis/ /titan/cancerregulome9/workspaces/users/rbressle/2012_09_18/blacklist.txt /titan/cancerregulome9/ITMI_PTB/public/analysis/layouts/
export NGSPECCORES=4
export NGSPECPLOTINGCORES=2
export RFACE=/titan/cancerregulome9/workspaces/rf-ace/bin/rf-ace
export GSPEC=/titan/cancerregulome9/ITMI_PTB/bin/GraphSpectrometer
ADIR=$1
BLACKLIST=$2



#Loop over feature matrixes and run and layout rf-ace predictors
for FILE in ${ADIR}/feature_matrices/*
do
	echo Feature Matrix $FILE
	if [ -f $FILE ]
	then
		OUTDIRBASE=${ADIR}/rf-pred/
		if [ ! -e $OUTDIRBASE ]
		then
			mkdir $OUTDIRBASE
		fi
		LAYOUTS=${OUTDIRBASE}/layouts
		if [ ! -e $LAYOUTS ]
		then
			mkdir $LAYOUTS
		fi
		
		./runrf_no_bl.sh $FILE $OUTDIR
		./runrf.sh $FILE $BLACKLIST $OUTDIR
	fi
done

#Loop over pairwise results and run fiedler and mds
for FILE in ${ADIR}/pairwise/*
do
	echo Pairwise $FILE
	if [ -f $FILE ]
	then
		OUTDIRBASE=${ADIR}/pairwise/layouts
		if [ ! -e $OUTDIRBASE ]
		then
			mkdir $OUTDIRBASE
		fi

		OUTDIRBASE=${OUTDIRBASE}/$(basename $FILE)
		if [ ! -e $OUTDIRBASE ]
		then
			mkdir $OUTDIRBASE
		fi

		OUTDIR=${OUTDIRBASE}/fiedler
		if [ ! -e $OUTDIR ]
		then
			mkdir $OUTDIR
		fi
		
		./runpw.sh $FILE $OUTDIR 2

		OUTDIR=${OUTDIRBASE}/mds
		if [ ! -e $OUTDIR ]
		then
			mkdir $OUTDIR
		fi
	fi
done

#Loop over rf-ace filter results and run fiedler and mds
for FILE in ${ADIR}/rf-ace/*
do
	echo Pairwise $FILE
	if [ -f $FILE ]
	then
		OUTDIRBASE=${ADIR}/rf-ace/layouts
		if [ ! -e $OUTDIRBASE ]
		then
			mkdir $OUTDIRBASE
		fi

		OUTDIRBASE=${OUTDIRBASE}/$(basename $FILE)
		if [ ! -e $OUTDIRBASE ]
		then
			mkdir $OUTDIRBASE
		fi

		OUTDIR=${OUTDIRBASE}/fiedler
		if [ ! -e $OUTDIR ]
		then
			mkdir $OUTDIR
		fi

		./runpw.sh $FILE $OUTDIR 3

		OUTDIR=${OUTDIRBASE}/mds
		if [ ! -e $OUTDIR ]
		then
			mkdir $OUTDIR
		fi
	fi
done


