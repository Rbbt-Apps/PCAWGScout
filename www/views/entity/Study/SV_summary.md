# Structural variantion overview

Genes are associated with an SV if they overlap with the boundary of the SV
&plusmn; 1000 bases. If the boundaries of the SV each overlap a gene these
form a 'candidate fusion'. This analysis does not go into further detail into
trying to understand events like promoter high-jacking.

For each 'candidate fusion' we perform an expression analysis to quantify to
what extent the donors that suffer from these SV events have deregulated
expression of either of the genes. This is limited by the availability of gene
expression data from enough donors. When expression is available for enough
samples of the cohort the gene expression matrix is 'barcoded', which means
that it is transformed into 0 and 1 values based on the distribution of
expression values for each gene across the samples. A fisher exact-test is
used to determine, for each of the genes separately, if the list of donors
with the fusion has significant proportion of 0 or 1 in these barcoded values.
