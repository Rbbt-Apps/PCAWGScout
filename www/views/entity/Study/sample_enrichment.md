# Sample enrichment

This action shows a functional enrichment analysis based on the number of samples with
genes belonging to a functional class (i.e. pathway) affected. 

This approach is based on a permutation test that compares the observed number
of samples with at least one gene affected that belongs to a functional class
or pathway, with the number of samples matching that criteria when the
mutations are shuffled. Each permutations consists then in shuffling the
relevant _exome_ mutations across all _exome_ bases.

Note that this procedure makes two important simplifications, namely that all
exome bases are equally likely to be mutated, and that they are equally likely
to give rise to non-synonymous variants.


