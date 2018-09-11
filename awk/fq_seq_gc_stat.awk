#! /usr/bin/awk -f
BEGIN {}
FNR %4 == 2 {
    seq = $0;
    gc[FNR] = gsub(/[GCgc]/, "", seq) / length($0);
}
END {
    asort(gc);
    records = length(gc);
    q1 = gc[int(records/4)];
    q3 = gc[int(records/4*3)];
    median = gc[int(records/2 + 1)];
    if (records % 2 == 0) {
        median = (gc[int(records/2)] + gc[int(records/2 + 1)]) / 2;
    }
    print gc[1] FS q1 FS median FS q3 FS gc[records];
}
####################
