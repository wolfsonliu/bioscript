## create txdb from gtf

library(GenomicFeatures)
library(Biostrings)

coding.txdb <- makeTxDbFromGFF('gencode.v34.protein_coding.gtf')

saveDb(coding.txdb, file="gencode.v34.protein_coding.sqlite")

write.table(
    as.data.frame(genes(coding.txdb)),
    'gene_info.txt',
    row.names = FALSE, sep = '\t', quote = FALSE
)

noncoding.txdb <- makeTxDbFromGFF('gencode.v34.not_protein_coding.gtf')

saveDb(noncoding.txdb, file="gencode.v34.not_protein_coding.sqlite")
