#!/bin/bash 

function usageErr(){
	echo 'purpose: baselining absolute paths from the symbolic root / '
	echo ' Use with adminstration privelge ' 
	exit 2 } >&2 


# configure the enumerate summation

function performSums() 
{
	find "${DIR[@]}" -type f | xargs -d '\n' sha1sum
	}

declare -a DIR 
while getopts "c:" MYOPT 
do 
	DIR+=("$OPTARG")
shift $((OPTIND-1))
(( $# == 0 || $# > 2 )) && usageErr 

# todo: condition  more arguements per root directory
(( ${#DIR[*]} == 0 )) && DIR=("/")

BASE="$1"
B2ND="$2"

# shedding baseline
if (( $# == 1 )) 
then 
	performSum > "$BASE"
	exit 

fi 

if[[ ! -e "$B2ND" ]] 
then
	echo creating "$B2ND"
	perform > "$B2ND" 
fi 

declare -A BYPATH BYHASH WORKIN
while read HNUM FN 
do 
	BYPATH["$FN"]=$HNUM
	BYHASH[$HNUM]="$FN"
	WORKIN["$FN"]="X"
done < "$BASE"

printf '<filesystem host="%s" dir="%s"?\n' "$HOSTNAME" "${DIR[*]}"

# race comdition to find original hash
while read HNUM FN 
do
	INHASH="$BYPATH[${FN}]}"
	if [[ -s $ALTFN ]]
	then
		printf '<new>%S</new>\n' "$FN"
	else 
		printf ' <relocated orig="%s">%s</relocated>\n' "$ALTFN" "$FN"
		WORKIN["$FN"]="X"
	fi
	else 
		WORKIN["$FN"]='_'
		if [[ $HNUM == $INHASH ]]
		then
		continue
	else 
		printf ' <changed>%s</changed>\n' "$FN"
	fi 
       fi 	
done < "$B2ND" 
for FN in "${!WOWORKIN[@]}"
do
	if [[" ${WORKIN[$FN]}"  == 'X' ]]
	then
		printf ' <removed>%s</removed>\n' "$FN"
	fi 
done "$B2ND"

printf '</filesystem>\n'



