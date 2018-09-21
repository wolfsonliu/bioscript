#! /usr/bin/awk -f
BEGIN {
    gc = 0;
    records = 0;
}
FNR %4 == 2 {
    records += 1;
    seq = $0;
    gc += gsub(/[GCgc]/, "", seq) / length($0);
}
END {
    print gc/records;
}
####################
