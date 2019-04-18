#! /usr/bin/awk -f

# This file is used to fetch all the spacers from the gtf with sequence file.
#     -- the first input file should be the gtf file with sequence attached (no header)

BEGIN {
    FS="\t";
    FORWARD="([ATCG]{20})([ATCG]GG)";
    REVERSE="(CC[ATCG])([ATCG]{20})";
}

{
    SEQ=toupper($10);
    OUT=($1 FS $2 FS $3 FS $4 FS $5 FS $6 FS $7 FS $8 FS $9);
    # Find spacers by forward strand sequence
    FSEQ=SEQ;
    do {
        match(FSEQ, FORWARD, a);
        if (RLENGTH > 0) {
            print OUT FS "s+" FS a[1] FS a[2];
            FSEQ=substr(FSEQ, a[1, "start"] + 1); 
        }
    } while (RLENGTH > 0)
    # Find spacers by reverse strand sequence
    RSEQ=SEQ;
    do {
        match(RSEQ, REVERSE, a);
        if (RLENGTH > 0) {
            print OUT FS "s-" FS a[2] FS a[1];
            RSEQ=substr(RSEQ, a[1, "start"] + 1); 
        }
    } while (RLENGTH > 0)
}
 
