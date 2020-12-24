#! /usr/bin/gawk
function sequence_complement (s)
{
    compdict["A"] = "T";
    compdict["C"] = "G";
    compdict["G"] = "C";
    compdict["T"] = "A";
    compdict["U"] = "A";
    compdict["W"] = "W";
    compdict["S"] = "S";
    compdict["M"] = "K";
    compdict["K"] = "M";
    compdict["R"] = "Y";
    compdict["Y"] = "R";
    compdict["B"] = "V";
    compdict["D"] = "H";
    compdict["H"] = "D";
    compdict["V"] = "B";
    compdict["N"] = "N";
    compdict["Z"] = "Z";
    compdict["*"] = "*";
    if (s == "") {
        return s;
    }
    x = substr(s,1,1);
    if (x in compdict) {
        return (compdict[x] sequence_complement(substr(s, 2)));
    } else {
        return (x sequence_complement(substr(s,2)));
    }
}

function sequence_reverse (s)
{
    if (s == "") {
        return "";
    }
    return (sequence_reverse(substr(s, 2)) substr(s, 1, 1));
}

function sequence_reverse_complement (s)
{
    return sequence_reverse(sequence_complement(s));
}

BEGIN {
    RS="@";
    FS="\n";
    before_sgrna="ACACCG";
    sgrna_length=20;
    after_sgrna="GTTT";
    before_barcode="AGTTT";
    barcode_length=4;
    after_barcode="CTCGA";
    seqid="";
    print "sequence_id\tforward_sgrna\tforward_barcode\treverse_sgrna\treverse_barcode";
}

FNR != 1 {
    split($1, a, " ");
    seqid=a[1];
    seq=toupper($2);
    revseq=sequence_reverse_complement(seq);
    fsgrna="-";
    fbarcode="-";
    rsgrna="-";
    rbarcode="-";

    if (match(seq, /ACACCG([ATCG]{20})GTTT/, arr1)) {
        fsgrna=arr1[1];
    }
    if (match(seq, /AGTTT([ATCG]{4})CTCGA/, arr2)) {
        fbarcode=arr2[1];
    }
    if (match(revseq, /ACACCG([ATCG]{20})GTTT/, arr3)) {
        rsgrna=arr3[1];
    }
    if (match(revseq, /AGTTT([ATCG]{4})CTCGA/, arr4)) {
        rbarcode=arr4[1];
    }

    print seqid "\t" fsgrna "\t" fbarcode "\t" rsgrna "\t" rbarcode;
}
