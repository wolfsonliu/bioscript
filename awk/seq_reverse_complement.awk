#! /usr/bin/awk -f

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
    x = "";
    for (i = 1; i <= length(s); i++) {
        x = (x compdict[substr(s, i, 1)]);
    }
    return x;
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
    x = "";
    for (i = length(s); i > 0; i--) {
        x = (x compdict[substr(s, i, 1)]);
    }
    return x;
}
{
    print sequence_reverse_complement($0);
}
