# SAM column names
# 1. QNAME
# 2. FLAG
# 3. RNAME
# 4. POS
# 5. MAPQ
# 6. CIGAR
# 7. MNAME
# 8. MPOS
# 9. TLEN
# 10. SEQ
# 11. QUAL

# CIGAR marker
# D: Deletion, in refence not in reads
# H: Hard clipping, read in reads not in reference, removed from SEQ
# I: Insertion, nucleotide in read not in reference
# M: Match, can be alignment or mismatch, in refence and reads
# N: Skipped region, in referece not in reads
# P: Padding, in reads not in reference
# S: Soft clipping, read in reads not in reference, included from SEQ
# X: Read mismatch, in reference and reads, but mismatch
# =: Read match, in reference and reads
# http://bioinformatics.cvr.ac.uk/blog/tag/cigar-string/ 
BEGIN {
    FS="\t";
}
!/^@/ {
     # Store the column values of SAM file
     qname = $1; flag = $2; rname = $3; rpos = $4; tlen = $9;
     # Get CIGAR column
     cigar = $6;
     # Separate CIGAR column 
     cigar_n = patsplit(cigar, cigar_sep, /[[:digit:]]*[[:upper:]]*/);
     # Calculate position of reference initiation
     ref_pos = rpos;
     # Calculate position of query sequence initiation 
     query_pos = 1;
     # Calculate positions for all the separated CIGAR regions
     rcord=""; qcord="";
     for (i = 1; i <= cigar_n; i++) {
         cmark = substr(cigar_sep[i], length(cigar_sep[i]));
         clen = substr(cigar_sep[i], 1, length(cigar_sep[i]) - 1);
         ref_region = "";
         query_region = "";
         switch (cmark) {
             case "M": # match or mismatch
             case "X": # mismatch
             case "=": # match 
                 ref_start = ref_pos;
                 ref_end = ref_pos + clen - 1;
                 ref_pos = ref_pos + clen;
                 ref_region = (cmark ":" ref_start "-" ref_end);
                 query_start = query_pos;
                 query_end = query_pos + clen - 1;
                 query_pos = query_pos + clen;
                 query_region = (cmark ":" query_start "-" query_end);
                 break;
             case "S": # Soft clipping
             case "H": # Hard clipping
             case "I": # Insertion
             case "P": # Padding
                 query_start = query_pos;
                 query_end = query_pos + clen - 1;
                 query_pos = query_pos + clen;
                 query_region = (cmark ":" query_start "-" query_end);
                 break;
             case "D": # Deletion
             case "N": # Skipping
                 ref_start = ref_pos;
                 ref_end = ref_pos + clen - 1;
                 ref_pos = ref_pos + clen;
                 ref_region = (cmark ":" ref_start "-" ref_end);
                 break
         }
         # RCORD information
         if (length(ref_region) > 0) { 
             if (length(rcord) == 0) {
                 rcord = ref_region;
             } else { 
                 rcord = (rcord ";" ref_region);
             }
         }
         # QCORD information
         if (length(query_region) > 0) { 
             if (length(qcord) == 0) {
                 qcord = query_region;
             } else { 
                 qcord = (qcord ";" query_region);
             }
         }
     }
     print $1 FS $2 FS $3 FS $4 FS $5 FS $6 FS $7 FS $8 FS $9 FS $10 FS $11 FS rcord FS qcord;
}
