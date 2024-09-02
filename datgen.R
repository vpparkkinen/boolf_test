if(is.na(Sys.getenv("RSTUDIO", unset = NA))){
  setwd(system2("pwd", stdout = TRUE)) # if not in RStudio, assume R runs in
} else {                               # a shell. otherwise assume RStudio
  path <- rstudioapi::getActiveDocumentContext()$path
  Encoding(path) <- "UTF-8"
  setwd(dirname(path))
}

library(cnasimtools)
library(frscore)

a <- replicate(500, randomDat(6, outcome = "A"), simplify = FALSE)
targets <- lapply(a, \(x) attributes(x)$target)

irrel <- replicate(500, data.frame(I1 = rbinom(nrow(a[[1]]), 1, 0.5), I2 = rbinom(nrow(a[[1]]), 1, 0.5)), simplify = FALSE)
a <- mapply(cbind, a, irrel, SIMPLIFY = FALSE)

writeLines(unlist(targets), file("targets.txt"))

ndat <- mapply(prevalence_compliant_noisify,
               model = targets,
               data = a,
               MoreArgs = list(outcome = "A", noiselevel = 0.125),
               SIMPLIFY = FALSE)




for(i in seq_along(ndat)){
  write.csv2(ndat[[i]], file = paste0("data/dat", i, ".csv"), row.names = FALSE)
}

frsc <- lapply(a, \(x) frscored_cna(x, outcome = "A", output = "asf"))

frsc_re <- lapply(frsc, `[[` , 1)
nonull_id <- lapply(lapply(frsc_re, nrow), \(x) !is.null(x)) |> unlist()

FRscore_selected <- frsc_re[nonull_id]

FRscore_results <- lapply(FRscore_selected, function(y) if (!is.null(y)){y[y$score >= quantile(y$score, 0.98, na.rm = T),]$condition})

fr_cor <- mapply(\(x, y) sapply(x, \(z) is.submodel(z, y)),
            x = FRscore_results,
            y = targets[nonull_id],
            SIMPLIFY = FALSE,
            USE.NAMES = FALSE)

fr_cor_any <- unlist(lapply(fr_cor, any))

sum(fr_cor_any) / length(targets[nonull_id])
