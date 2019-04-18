#! /usr/bin/awk -f

# This file is used to paste the sequence to the gtf columns from the
# fasta file.
#     -- the first input file should be the fasta file.
#     -- the second input file should be the corresponding gtf file.

BEGIN {
    FS="\t";
    a="";
}
FILENAME == ARGV[1] && FNR != 1 {
    a=(a $0);
}
FILENAME == ARGV[2] {
    print $0 FS substr(a, $4, $5 - $4 + 1);
}
