#! /usr/bin/awk -F "\t" -f

# This file is used to obtain the gene CDS start and end from gtf.
# For the gene on - strand, the start is the stop codon end, and the
# end is the start codon start.

$3 ~ /(start_codon|stop_codon|CDS)/ {
    match($9, /gene_id "([^ ;]*)"/, a);
    name = a[1];
    gchr[name] = $1;      # chromosome
    gstrand[name] = $7;   # strand
    gstart[name] += 0;    # initiation if not exist
    gend[name] += 0;      # initiation if not exist

    # gene start should be the min start value.
    if (gstart[name] > $4 || gstart[name] == 0) {
        gstart[name] = $4;
    }

    # gene start should be the max end value.
    if (gend[name] < $5) {
        gend[name] = $5;
    }
}

END {
    for (i in gchr) {
        print i FS gchr[i] FS gstrand[i] FS gstart[i] FS gend[i] > "/dev/stdout";
    }
}
