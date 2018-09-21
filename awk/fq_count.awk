#! /usr/bin/awk -f
BEGIN {
        reads=0;
    }
FNR % 4 == 0 {
    reads += 1;
}
END {
    print reads;
}
####################
