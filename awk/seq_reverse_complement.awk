BEGIN {
    compdict["A"]="T";
    compdict["C"]="G";
    compdict["G"]="C";
    compdict["T"]="A";
    compdict["U"]="A";
    compdict["W"]="W";
    compdict["S"]="S";
    compdict["M"]="K";
    compdict["K"]="M";
    compdict["R"]="Y";
    compdict["Y"]="R";
    compdict["B"]="V";
    compdict["D"]="H";
    compdict["H"]="D";
    compdict["V"]="B";
    compdict["N"]="N";
    compdict["Z"]="Z";
    compdict["*"]="*";
}
{
    x="";
    for (i = length($0); i > 0; i--) {
        x=(x compdict[substr($0, i, 1)]);
    }
    print x;
}
