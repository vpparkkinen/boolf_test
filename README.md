# boolformer vs. cna

`datgen.R` generates data sets and saves them to `data/` (which should exists), saves target DGSs in `targets.txt` and runs `frscored_cna()` on said data, collects results and checks correctness against the DGSs.

`bftest.py` runs a `boolformer` model on the data sets, returning lhs's converted to `cna` syntax, saved to `ress.txt` in project root.

`cor_check.R` generates redundancy-free versions of models returned by boolformer, and checks correctness against targets.
