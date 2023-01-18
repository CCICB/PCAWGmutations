test_that("pcawg_available() works", {
  skip_on_cran()
  skip_if_offline()

  expect_s3_class(pcawg_available(), class = "data.frame")
  expect_gt(nrow(pcawg_available()), expected = 0)
  expect_named(pcawg_available(), c("Abbreviation", "Full name", "Samples", "DOI"))
})

test_that("pcawg_load() works", {
  skip_on_cran()
  skip_if_offline()

  df_cohorts_available <- pcawg_available()
  set.seed(1)
  n=2
  df_cohorts_available_subset <- df_cohorts_available[sample(seq_len(nrow(df_cohorts_available)), size = n),]

  verbose = FALSE
  for (cohort in df_cohorts_available_subset[[1]]){
    if(verbose) message(cohort)
    expect_error(pcawg_load(cohort, verbose = FALSE), NA)
    expect_s4_class(pcawg_load(cohort,  verbose = FALSE), "MAF")
  }
})

test_that("pcawg_load() works when multiple cohorts are requested", {
  skip_on_cran()
  skip_if_offline()

  df_cohorts_available <- pcawg_available()
  verbose = FALSE
  cohorts <- df_cohorts_available[[1]][1:2]
  expect_error(pcawg_load(cohorts, verbose = FALSE), NA)
  expect_type(pcawg_load(cohorts,  verbose = FALSE), "list")
})


