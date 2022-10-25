#! /usr/bin/bash

echo "dbSNP with GRCh37 coordinates"

echo "download vcf"

wget "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.25.gz"

wget "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.25.gz.md5"

md5sum -c GCF_000001405.25.gz.md5

echo "download index"

wget "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.25.gz.tbi"

wget "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.25.gz.tbi.md5"

md5sum -c GCF_000001405.25.gz.tbi.md5

echo "convert GRCh37 vcf to hg19 bcf"

wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.14_GRCh37.p13/GCA_000001405.14_GRCh37.p13_assembly_report.txt"

egrep -v "^#" GCA_000001405.14_GRCh37.p13_assembly_report.txt | cut -f 7,10 | tr "\t" " " > GRCh37-to-hg19.map

bcftools annotate --rename-chrs GRCh37-to-hg19.map GCF_000001405.25.gz -Ob -o dbsnp.25.hg19.bcf

bcftools index dbsnp.25.hg19.bcf

echo "finished"
