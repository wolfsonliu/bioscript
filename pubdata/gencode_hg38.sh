#! /usr/bin/bash
# need:
#     bgzip
#     tabix


echo "Gencode GRCh38 Release 41 comprehensive"

wget "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/gencode.v41.annotation.gtf.gz" -O gencode.v41.annotation.gtf.gz

gunzip gencode.v41.annotation.gtf.gz

echo "sort"

(grep ^"#" gencode.v41.annotation.gtf; grep -v ^"#" gencode.v41.annotation.gtf | sort -k1,1 -k4,4n) | bgzip > gencode.v41.annotation.sorted.gtf.gz

tabix -p gff gencode.v41.annotation.sorted.gtf.gz

echo "finished"
