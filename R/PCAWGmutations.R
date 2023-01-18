
#' List Available Datasets
#'
#' @return a dataframe listing available datasets
#' @export
#'
#' @examples
#' pcawg_available()
pcawg_available <- function(){
  path_to_dataset_manifest <- "https://github.com/CCICB/PCAWGmutationsDB/raw/main/inst/extdata/projects.tsv"
  utils::read.csv(path_to_dataset_manifest, sep = "\t", header=TRUE, check.names = FALSE)
}

#' Load PCAWG mafs
#'
#' Load PCAWG maf objects into R. Streams data from [PCAWGmutationsDB](https://github.com/CCICB/PCAWGmutations) repo
#'
#' @param cohort abbreviation of PCAWG project. See [pcawg_available()] for valid values (string)
#'
#' @return MAF object compatible with maftools
#' @export
#'
#' @examples
#' pcawg_load("Biliary-AdenoCA")
pcawg_load <- function(cohort, verbose = TRUE){

  df_available_cohorts <- pcawg_available()
  if (!all(cohort %in% df_available_cohorts[[1]]))
    stop("Could not find requested cohort!\nUse pcawg_available() to list available cohorts")

  path_github_folder = "https://github.com/CCICB/PCAWGmutationsDB/raw/main/inst/extdata/"


  cohorts <- df_available_cohorts[match(cohort, df_available_cohorts[[1]]), ]
  if(nrow(cohorts) == 1){
    doi = cohorts[1, "DOI"]
    cohort_shortname = cohorts[1, 1]

    path_rds <- paste0(path_github_folder, cohort_shortname, ".rds")
    z <- gzcon(con = url(path_rds, "rb"))
    maf <- readRDS(z)
    close(z)
    if(verbose) { message("Loading PCAWG data [", cohort_shortname,"]\nIf you find this data useful, please cite ", doi) ; print(maf@summary) }
    return(invisible(maf))
  }
  else{
    mafs <- lapply(seq_len(nrow(cohorts)), function(i){
      c <- cohorts[i,1]
      path_rds <- paste0(path_github_folder, c, ".rds")
      z <- gzcon(con = url(path_rds, "rb"))
      maf <- readRDS(z)
      close(z)
      return(maf)
      })
    names(mafs) <- cohort
    doi = unique(cohorts["DOI"])
    if(verbose) { message("Loading PCAWG datasets: ", paste0(cohorts[[1]], collapse = ","), "\nIf you find these datasets useful, please cite: \n", paste0(doi, collapse = "\n")) }
    return(invisible(mafs))
  }


  return(maf)
}
