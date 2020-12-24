#! /usr/bin/env python3
from Bio import SeqIO
import pandas as pd
import re
import sys

fq1 = sys.argv[1]
fq2 = sys.argv[2]
libpath = sys.argv[3]

fq1_iter = SeqIO.parse(fq1, 'fastq')
fq2_iter = SeqIO.parse(fq2, 'fastq')

sg_fwd = re.compile('ACCG([ATCG]{19,20})GTTTT')
sg_rev = re.compile('AAAAC([ATCG]{19,20})CGGT')

bar_fwd = re.compile('GTTT(CACT|GCAG|AGCA)CTCG')
bar_rev = re.compile('CGAG(AGTG|CTGC|TGCT)TAAA')

lib = pd.read_table(libpath, header=0, sep='\t')

lib.set_index(['guide'], drop=False, inplace=True)

print('\t'.join(['read_name', 'guide', 'barcode', 'gene']))

for r1, r2 in zip(fq1_iter, fq2_iter):
    has_sg = 0
    has_bar = 0
    sgmatch = sg_fwd.search(str(r1.seq))
    if sgmatch is None:
        sgmatch = sg_fwd.search(str(r2.seq))
    if sgmatch is not None:
        has_sg = 1
        guide = sgmatch.group(1)
        try:
            gene = lib.loc[guide, 'gene']
        except:
            gene = '-'
        barmatch = bar_fwd.search(str(r2.seq.reverse_complement()))
        if barmatch is None:
            barmatch = bar_fwd.search(str(r1.seq.reverse_complement()))
        if barmatch is not None:
            has_bar = 1
            barcode = barmatch.group(1)
        else:
            barcode = '-'
        print(
            '\t'.join([r1.name, guide, barcode, gene])
        )
    else:
        print(
            '\t'.join([r1.name, '-', '-', '-'])
        )
