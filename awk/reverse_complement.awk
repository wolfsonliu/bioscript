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
{
    print sequence_reverse_complement($0);
}
