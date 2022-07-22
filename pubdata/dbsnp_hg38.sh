#! /usr/bin/bash

echo "dbSNP with GRCh38 coordinates"

echo "download vcf"

wget "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.39.gz"

wget "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.39.gz.md5"

md5sum -c GCF_000001405.39.gz.md5

echo "download index"

wget "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.39.gz.tbi"

wget "https://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.39.gz.tbi.md5"

md5sum -c GCF_000001405.39.gz.tbi.md5

echo "convert GRCh38 vcf to hg38 bcf"

wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.29_GRCh38.p14/GCA_000001405.29_GRCh38.p14_assembly_report.txt"

egrep -v "^#" GCA_000001405.29_GRCh38.p14_assembly_report.txt | cut -f 7,10 | tr "\t" " " > GRCh38-to-hg38.map

bcftools annotate --rename-chrs GRCh38-to-hg38.map GCF_000001405.39.gz -Ob -o dbsnp.39.hg38.bcf

bcftools index dbsnp.39.hg38.bcf

echo "finished"
