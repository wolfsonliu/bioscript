## annotate peaks or sites with genomic region information
options(stringsAsFactors = FALSE)
library(GenomicRanges)
library(GenomicFeatures)
library(dplyr)
library(ggplot2)

chromosomes <- c('chr1', 'chr2', 'chr3', 'chr4', 'chr5', 'chr6',
                 'chr7', 'chr8', 'chr9', 'chr10', 'chr11', 'chr12',
                 'chr13', 'chr14', 'chr15', 'chr16', 'chr17', 'chr18',
                 'chr19', 'chr20', 'chr21', 'chr22', 'chrX', 'chrY')

coding.txdb <- loadDb(file="data/gencode.v34.protein_coding.sqlite")

noncoding.txdb <- loadDb(file="data/gencode.v34.not_protein_coding.sqlite")

repeats <- read.table('data/hg38.repeat_masker.table.tab', header = FALSE, sep = '\t')

colnames(repeats) <- c(
    'bin', 'swScore', 'milliDiv', 'milliDel', 'milliIns', 'genoName', 'genoStart',
    'genoEnd', 'genoLeft', 'strand', 'repName', 'repClass', 'repFamily', 'repStart',
    'repEnd', 'repLeft', 'id'
)

repeats$info <- paste(
    repeats$repClass, repeats$repFamily, repeats$repName,
    paste(repeats$genoName, paste(repeats$genoStart, repeats$genoEnd, sep = '-'), repeats$strand,  sep = ':'),
    sep = '|'
)

#LINE|SINE|Retroposon(SVA)|LTR

rte.repeats <- repeats %>%
    filter(repClass %in% c("LINE", "SINE", "Retroposon", "LTR"))

rte.repeat.gr <- GRanges(
    seqnames=rte.repeats %>% pull(genoName),
    ranges = IRanges(
        start = rte.repeats %>% pull(genoStart),
        end = rte.repeats %>% pull(genoEnd)
    ),
    strand = rte.repeats %>% pull(strand),
    info = rte.repeats %>% pull(info),
    name = rte.repeats %>% pull(repName),
    class = rte.repeats %>% pull(repClass),
    family = rte.repeats %>% pull(repFamily)
)

####################

peaks <- read.table(
    'peaks.txt', header = FALSE, sep = '\t'
)
colnames(peaks) <- c('chr', 'start', 'end', 'strand')

peaks.gr <- GRanges(
    seqnames = peaks$chr,
    ranges = IRanges(start = peaks$start, end = peaks$end),
    strand = peaks$strand
)

## genes
genes.gr <- genes(coding.txdb)
gene.idx <- findOverlaps(peaks.gr, genes.gr, ignore.strand=FALSE)

genes.queryhit <- data.frame(
    query = queryHits(gene.idx),
    gene_id = mcols(genes.gr)[subjectHits(gene.idx), 'gene_id']
) %>% unique()

genes.queryhit.merge <- genes.queryhit %>%
    group_by(query) %>%
    summarize(gene_ids = paste(gene_id, collapse = ';'))

mcols(peaks.gr)$coding_gene_ids <- NA
mcols(peaks.gr)[genes.queryhit.merge$query, 'coding_gene_ids'] <- genes.queryhit.merge$gene_ids

## in CDS
cds.gr <- cds(coding.txdb, columns = c('gene_id'))

mcols(cds.gr)$gene_ids <- unlist(lapply(mcols(cds.gr)$gene_id, paste, collapse = ';'))

cds.idx <- findOverlaps(peaks.gr, cds.gr, ignore.strand=FALSE)

cds.queryhit <- data.frame(
    query = queryHits(cds.idx),
    gene_id = mcols(cds.gr)[subjectHits(cds.idx), 'gene_ids']
) %>% unique()

cds.queryhit.merge <- cds.queryhit %>%
    group_by(query) %>%
    summarize(gene_ids = paste(gene_id, collapse = ';'))

mcols(peaks.gr)$coding_cds_gene_ids <- NA
mcols(peaks.gr)[cds.queryhit.merge$query, 'coding_cds_gene_ids'] <- cds.queryhit.merge$gene_ids

## in 5' UTR

fiveutr.gl <- fiveUTRsByTranscript(coding.txdb, use.name = TRUE)

fiveutr.idx <- findOverlaps(peaks.gr, fiveutr.gl, ignore.strand=FALSE)

fiveutr.queryhit <- data.frame(
    query = queryHits(fiveutr.idx),
    tx_id = names(fiveutr.gl[subjectHits(fiveutr.idx)])
) %>% unique()

fiveutr.queryhit.merge <- fiveutr.queryhit %>%
    group_by(query) %>%
    summarize(tx_ids = paste(tx_id, collapse = ';'))

mcols(peaks.gr)$coding_fiveutr_tx_ids <- NA
mcols(peaks.gr)[fiveutr.queryhit.merge$query, 'coding_fiveutr_tx_ids'] <- fiveutr.queryhit.merge$tx_ids

## in 3' UTR
threeutr.gl <- threeUTRsByTranscript(coding.txdb, use.name = TRUE)

threeutr.idx <- findOverlaps(peaks.gr, threeutr.gl, ignore.strand=FALSE)

threeutr.queryhit <- data.frame(
    query = queryHits(threeutr.idx),
    tx_id = names(threeutr.gl[subjectHits(threeutr.idx)])
) %>% unique()

threeutr.queryhit.merge <- threeutr.queryhit %>%
    group_by(query) %>%
    summarize(tx_ids = paste(tx_id, collapse = ';'))

mcols(peaks.gr)$coding_threeutr_tx_ids <- NA
mcols(peaks.gr)[threeutr.queryhit.merge$query, 'coding_threeutr_tx_ids'] <- threeutr.queryhit.merge$tx_ids


## in intron

intron.gl <- intronsByTranscript(coding.txdb, use.name = TRUE)

intron.idx <- findOverlaps(peaks.gr, intron.gl, ignore.strand=FALSE)

intron.queryhit <- data.frame(
    query = queryHits(intron.idx),
    tx_id = names(intron.gl[subjectHits(intron.idx)])
) %>% unique()

intron.queryhit.merge <- intron.queryhit %>%
    group_by(query) %>%
    summarize(tx_ids = paste(tx_id, collapse = ';'))

mcols(peaks.gr)$coding_intron_tx_ids <- NA
mcols(peaks.gr)[intron.queryhit.merge$query, 'coding_intron_tx_ids'] <- intron.queryhit.merge$tx_ids


## noncoding genes

noncoding.gr <- genes(noncoding.txdb)
noncoding.idx <- findOverlaps(peaks.gr, noncoding.gr, ignore.strand=FALSE)

noncoding.queryhit <- data.frame(
    query = queryHits(noncoding.idx),
    noncoding_gene_id = mcols(noncoding.gr)[subjectHits(noncoding.idx), 'gene_id']
) %>% unique()

noncoding.queryhit.merge <- noncoding.queryhit %>%
    group_by(query) %>%
    summarize(noncoding_gene_ids = paste(noncoding_gene_id, collapse = ';'))

mcols(peaks.gr)$noncoding_gene_ids <- NA
mcols(peaks.gr)[noncoding.queryhit.merge$query, 'noncoding_gene_ids'] <- noncoding.queryhit.merge$noncoding_gene_ids

## noncoding exon

nexon.gr <- exons(noncoding.txdb, columns = c('gene_id'))

mcols(nexon.gr)$gene_ids <- unlist(lapply(mcols(nexon.gr)$gene_id, paste, collapse = ';'))

nexon.idx <- findOverlaps(peaks.gr, nexon.gr, ignore.strand=FALSE)

nexon.queryhit <- data.frame(
    query = queryHits(nexon.idx),
    noncoding_gene_ids = mcols(nexon.gr)[subjectHits(nexon.idx), 'gene_ids']
) %>% unique()

nexon.queryhit.merge <- nexon.queryhit %>%
    group_by(query) %>%
    summarize(noncoding_gene_ids = paste(noncoding_gene_ids, collapse = ';'))

mcols(peaks.gr)$noncoding_exon_gene_ids <- NA
mcols(peaks.gr)[nexon.queryhit.merge$query, 'noncoding_exon_gene_ids'] <- nexon.queryhit.merge$noncoding_gene_ids

## noncoding intron

nintron.gl <- intronsByTranscript(noncoding.txdb, use.name = TRUE)

nintron.idx <- findOverlaps(peaks.gr, nintron.gl, ignore.strand=FALSE)

nintron.queryhit <- data.frame(
    query = queryHits(nintron.idx),
    tx_id = names(nintron.gl[subjectHits(nintron.idx)])
) %>% unique()

nintron.queryhit.merge <- nintron.queryhit %>%
    group_by(query) %>%
    summarize(tx_ids = paste(tx_id, collapse = ';'))

mcols(peaks.gr)$noncoding_intron_tx_ids <- NA
mcols(peaks.gr)[nintron.queryhit.merge$query, 'noncoding_intron_tx_ids'] <- nintron.queryhit.merge$tx_ids


## RTE repeats

rte.repeat.idx <- findOverlaps(peaks.gr, rte.repeat.gr, ignore.strand=TRUE)

rte.repeat.queryhit <- data.frame(
    query = queryHits(rte.repeat.idx),
    info = mcols(rte.repeat.gr)[subjectHits(rte.repeat.idx), 'info']
) %>% unique()

rte.repeat.queryhit.merge <- rte.repeat.queryhit %>%
    group_by(query) %>%
    summarize(info = paste(info, collapse = ';'))

mcols(peaks.gr)$repeat_info <- NA
mcols(peaks.gr)[rte.repeat.queryhit.merge$query, 'repeat_info'] <- rte.repeat.queryhit.merge$info


####################

peaks.df <- as.data.frame(peaks.gr)

peaks.df$in_coding <- FALSE
peaks.df$in_coding[!is.na(peaks.df$coding_gene_ids)] <- TRUE
peaks.df$in_coding[
             (is.na(peaks.df$coding_cds_gene_ids)) &
             (is.na(peaks.df$coding_fiveutr_gene_ids)) &
             (is.na(peaks.df$coding_threeutr_gene_ids)) &
             (!is.na(peaks.df$noncoding_exon_gene_ids))
         ] <- FALSE

peaks.df$in_noncoding <- FALSE
peaks.df$in_noncoding[!is.na(peaks.df$noncoding_gene_ids)] <- TRUE
peaks.df$in_noncoding[
             (!is.na(peaks.df$coding_cds_gene_ids)) |
             (!is.na(peaks.df$coding_fiveutr_gene_ids)) |
             (!is.na(peaks.df$coding_threeutr_gene_ids))
         ] <- FALSE

peaks.df$region <- NA

peaks.df$region[
             peaks.df$in_noncoding &
             (!is.na(peaks.df$noncoding_intron_tx_ids))
         ] <- 'Non-coding gene intron'

peaks.df$region[
             peaks.df$in_noncoding &
             (!is.na(peaks.df$noncoding_exon_gene_ids))
         ] <- 'Non-coding gene exon'

peaks.df$region[
             peaks.df$in_coding &
             (!is.na(peaks.df$coding_intron_tx_ids))
         ] <- 'Coding gene intron'

peaks.df$region[
             peaks.df$in_coding &
             (!is.na(peaks.df$coding_threeutr_tx_ids))
         ] <- "Coding gene 3' UTR"

peaks.df$region[
             peaks.df$in_coding &
             (!is.na(peaks.df$coding_fiveutr_tx_ids))
         ] <- "Coding gene 5' UTR"

peaks.df$region[
             peaks.df$in_coding &
             (!is.na(peaks.df$coding_cds_gene_ids))
         ] <- 'Coding gene CDS'


write.table(
    peaks.df, 'data/peaks_with_regions.txt',
    row.names=FALSE, quote=TRUE, sep='\t'
)

####################
