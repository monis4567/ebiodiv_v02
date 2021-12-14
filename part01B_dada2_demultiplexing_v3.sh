#!/bin/bash
# -*- coding: utf-8 -*-
echo $BASH_VERSION

rm -rf DADA2_* # deletes any previous versions of these directories
mkdir DADA2_AS
mkdir DADA2_SS

#define input file with batch lists
INPF1_BTCH_LST="part01A_batch_file_ebiodiv_b_library_number.list"
                #part01A_batch_file_ebiodiv_b009.list
                #part01B_dada2_demultiplexing_v3_b009.sh
while read INPUT_R1 INPUT_R2 TAGS PRIMER_F PRIMER_R MIN_LENGTH ; do

CUR_PATH=$(pwd)
#mkdir tempdir
#export TMPDIR="${CUR_PATH}/tempdir/"

# Define binaries, temporary files and output files
CUTADAPT="$(which cutadapt) --discard-untrimmed --minimum-length ${MIN_LENGTH} -e 0"
CUTADAPT2="$(which cutadapt) -e 0"
VSEARCH=$(which vsearch)
C1_FASTQ=$(mktemp)
C2_FASTQ=$(mktemp)
TMP_FASTQ=$(mktemp)
MIN_F=$((${#PRIMER_F}))
MIN_R=$((${#PRIMER_R}))

REV_PRIMER_F="$(echo $PRIMER_F | rev | tr ATUGCYRKMBDHVN TAACGRYMKVHDBN)"
REV_PRIMER_R="$(echo $PRIMER_R | rev | tr ATUGCYRKMBDHVN TAACGRYMKVHDBN)"

rev="$(echo $primer | rev | tr ATUGCYRKMBDHVN TAACGRYMKVHDBN)"


while read TAG_NAME TAG_SEQ RTAG_SEQ; do
    LOG="DADA2_SS/${TAG_NAME}_R1.log"
    FINAL_FASTQ="DADA2_SS/${TAG_NAME}_R1.fastq"

   FTFP="$TAG_SEQ$PRIMER_F"
   RTRP="$RTAG_SEQ$PRIMER_R"

    # Trim tags, forward & reverse primers (search normal and antisens)
        cat "${INPUT_R1}" | \
        ${CUTADAPT} -g "${FTFP}" -e 0 -O "${#FTFP}" - 2> "${LOG}"  > "${TMP_FASTQ}"

	cat "${TMP_FASTQ}" | ${CUTADAPT2} -a "${REV_PRIMER_R}" - 2>> "${LOG}"  > "${FINAL_FASTQ}"

    LOG="DADA2_AS/${TAG_NAME}_R2.log"
    FINAL_FASTQ="DADA2_AS/${TAG_NAME}_R2.fastq"

    # Trim tags, forward & reverse primers (search normal and antisens)
        cat "${INPUT_R2}" | \
        ${CUTADAPT} -g "${FTFP}" -e 0 -O "${#FTFP}" - 2> "${LOG}" > "${TMP_FASTQ}"

        cat "${TMP_FASTQ}" | ${CUTADAPT2} -a "${REV_PRIMER_R}" - 2>> "${LOG}" > "${FINAL_FASTQ}"

    LOG="DADA2_SS/${TAG_NAME}_R2.log"
    FINAL_FASTQ="DADA2_SS/${TAG_NAME}_R2.fastq"

    # Trim tags, forward & reverse primers (search normal and antisens)
        cat "${INPUT_R2}" | \
        ${CUTADAPT} -g "${RTRP}" -e 0 -O "${#RTRP}" - 2>> "${LOG}" > "${TMP_FASTQ}"

        cat "${TMP_FASTQ}" | ${CUTADAPT2} -a "${REV_PRIMER_F}" - 2>> "${LOG}" > "${FINAL_FASTQ}"

    LOG="DADA2_AS/${TAG_NAME}_R1.log"
    FINAL_FASTQ="DADA2_AS/${TAG_NAME}_R1.fastq"

    # Trim tags, forward & reverse primers (search normal and antisens)
        cat "${INPUT_R1}" | \
        ${CUTADAPT} -g "${RTRP}" -e 0 -O "${#RTRP}" - 2>> "${LOG}" > "${TMP_FASTQ}"

        cat "${TMP_FASTQ}" | ${CUTADAPT2} -a "${REV_PRIMER_F}" - 2>> "${LOG}" > "${FINAL_FASTQ}"

done < "${TAGS}"

# Clean
rm -rf "${C1_FASTQ}" "${C2_FASTQ}" "${TMP_FASTQ}"

done < "${INPF1_BTCH_LST}"
