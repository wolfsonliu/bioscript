#! /bin/awk -f
BEGIN {
    lengthsum = 0;
    records = 0;
}
FNR %4 == 2 {
    records += 1;
    lengthsum += length($0);
}
END {
    print lengthsum/records;
}
####################
