# Render PheNorm_Analysis.Rmd into a timestamped Result directory.
# Run this script from the project root with:
#
#   Rscript render_analysis.R

main <- function() {
  input <- "PheNorm_Analysis.Rmd"

  if (!file.exists(input)) {
    stop(
      "Cannot find ", input, ". Run this script from the project root.",
      call. = FALSE
    )
  }

  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop(
      "The rmarkdown package is unavailable. Run renv::restore() first.",
      call. = FALSE
    )
  }

  if (requireNamespace("pandoc", quietly = TRUE) &&
      length(pandoc::pandoc_installed_versions()) > 0L) {
    pandoc::pandoc_activate("latest", rmarkdown = TRUE)
  }

  if (!rmarkdown::pandoc_available()) {
    stop(
      "Pandoc is unavailable. Follow the Pandoc setup instructions in README.md.",
      call. = FALSE
    )
  }

  run_name <- paste0(
    tools::file_path_sans_ext(basename(input)),
    "_result_",
    format(Sys.time(), "%Y%m%d_%H%M%S")
  )
  output_dir <- file.path(getwd(), "Result", run_name)

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)

  Sys.setenv(RUN_DIR = output_dir)
  on.exit(Sys.unsetenv("RUN_DIR"), add = TRUE)

  output_file <- rmarkdown::render(
    input = input,
    output_file = "Analysis.html",
    output_dir = output_dir
  )

  message(
    "Analysis complete: ",
    normalizePath(output_file, winslash = "/", mustWork = FALSE)
  )
}

main()
