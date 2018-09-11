#! /usr/bin/awk -f
BEGIN {}
FNR %4 == 2 {
    readlength[FNR] = length($0);
}
END {
    asort(readlength);
    records = length(readlength);
    q1 = readlength[int(records/4)];
    q3 = readlength[int(records/4*3)];
    median = readlength[int(records/2 + 1)];
    if (records % 2 == 0) {
        median = (readlength[int(records/2)] + readlength[int(records/2 + 1)]) / 2;
    }
    print readlength[1] FS q1 FS median FS q3 FS readlength[records];
}
####################
