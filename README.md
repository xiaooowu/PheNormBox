# PheNorm Analysis containerizied through `renv`

## Purpose

This repository provides a complete PheNorm workflow. A user specifies the input columns and analysis settings in one configuration section at the top of the R Markdown file. The document then:

1. Validates and prepares the cohort.
2. Fits PheNorm models.
3. Evaluates the models on chart-reviewed records.
4. Generates predicted probabilities for a full cohort.
5. Produces an HTML report, logs, fitted models, tables, plots, and prediction files.

Unreviewed records are used for model training. Chart-reviewed records are used for internal evaluation against a binary gold-standard outcome.

## Prerequisites

### Software

- R. The project lockfile records **R 4.6.0**; using that version is recommended for the most reproducible setup.
- Pandoc, which is required to render the R Markdown report. RStudio includes Pandoc. Users without RStudio must install Pandoc separately and make it available on the system `PATH`.
- Internet access when restoring packages on a computer where they are not already installed.
- On Windows, Rtools may be needed if any package must be compiled from source.

### R environment

The project uses `renv`. Its `.Rprofile` activates the project library, and `renv.lock` records the required package versions. Restoring the lockfile is preferred over installing packages individually.

The main packages used by the workflow include:

- `rmarkdown`, `knitr`, and `here`
- `optparse`
- `dplyr`, `tidyr`, `tibble`, `purrr`, `readr`, and `stringr`
- `ggplot2` and `cowplot`
- `PheNorm`, `ROCR`, `WeightedROC`, `vimp`, `cvAUC`, and `SuperLearner`

`renv::restore()` installs these packages and their recorded dependencies.

### Project structure

Keep the following files and directories together:

```text
PheNorm_renv/
├── PheNorm_Analysis.Rmd
├── PheNorm_renv.Rproj
├── renv.lock
├── .Rprofile
├── renv/
├── PheNorm/
├── Data/
└── Result/                         
```

Run the analysis from the `PheNorm_renv` project root. The scripts use `PheNorm_renv.Rproj` to identify that root.

## Configuration guide

Edit the first code chunk in `PheNorm_Analysis.Rmd`. The table below combines the input-data specifications with their corresponding R configuration settings.

| Setting or data element | Configuration value or naming pattern | Value/requirement |
|---|---|---|
| Input-data layout | CSV file with a header row | One observation per row and one variable per column. |
| Variable names | Lowercase names with underscores in place of spaces, except CUI variables, which begin with uppercase `C` | Names must be unique. |
| `data_file` | Absolute path or a path constructed with `here::here()` | Must identify the input CSV file. |
| `study_id_col` | Name of the patient or record ID column | Values must be unique and nonmissing. |
| `reviewed_col` | `"reviewed_col"` | Binary and complete: `0` = not reviewed and `1` = reviewed. The dataset must contain both reviewed and unreviewed observations. |
| `reviewed_value` | `1` | Identifies the reviewed/evaluation observations. |
| `gold_outcome_col` | `"gold_outcome"` | Binary: `0` = not a case and `1` = case. Values must be nonmissing for reviewed observations, and reviewed observations must include both classes. Values may be missing for unreviewed observations. |
| `utilization_col` | Name of a utilization variable, such as number of notes or encounters | Values must be numeric, finite, complete, and nonnegative. Do not log-transform counts; stage 1 applies `log(x + 1)`. When set to `NULL`, every observation receives utilization = 1.  |
| `sampling_weight_col` | Name of the sampling-weight column, or `NULL` | Values must be numeric, finite, complete, and greater than zero. When set to `NULL`, every observation receives weight `1`. |
| `silver_label_cols` | Character vector of exact column names beginning with `silver_` | See [Silver labels](#silver-labels) below.|
| `predictor_cols`: structured/NLP data | Character vector of exact outcome-specific column names | CUI-based NLP variables must begin with uppercase `C`; see [Predictors](#predictors) below.|
| `site` | Short cohort/site name | Used by stages 1–3 and in output filenames. Only letters, numbers, underscores, and hyphens are allowed. |
| `stage4_data_site` | Site name for the stage-4 analysis data | Use `site` for same-site prediction or identify the external data site. |
| `stage4_model_site` | Site name for the fitted stage-4 model | Use `site` for same-site prediction or identify the external model site. |
| `stage4_data_dir` | Directory containing the stage-4 analysis-data RDS file, or `NULL` | `NULL` uses this run's analysis-data directory. |
| `stage4_output_dir` | Results directory containing the stage-4 model under `fits/`, or `NULL` | `NULL` uses this run's results directory. Predictions are also written here. |
| `analysis_id` | Optional output name stem, or `NULL` | `NULL` uses the Rmd filename without its extension. Only letters, numbers, underscores, and hyphens are allowed. |
| `seed` | Integer random-number seed | Used for reproducibility. |
| `corrupt_rate` | Numeric PheNorm corruption rate | Default: `0.3`. |
| `train_size_multiplier` | Integer multiplier for the inflated training size | Default: `13L`. |

`site`, `stage4_data_site`, `stage4_model_site`, and a non-`NULL` `analysis_id` may contain only letters, numbers, underscores, and hyphens.

## Predictors

List every non-silver predictor explicitly in `predictor_cols`. The Rmd does not search for predictors with regular expressions and does not automatically include columns based on their names.

In particular:

- Categorical predictors must be converted to numeric indicator columns.
- NLP data: Every desired CUI column must be listed individually and named with an uppercase `C` followed by its CUI digits, such as `C0000001`.
- Do not include the ID, review indicator, gold outcome, utilization, sampling weight, or silver-label columns in `predictor_cols`.
- Predictor names must be unique and must exactly match the CSV header.

A column that is present in the CSV but absent from `predictor_cols` and `silver_label_cols` will not be used as a model variable.

## Silver labels

List the exact source column names in `silver_label_cols`. At least one silver label is required, and every silver-standard variable must begin with the lowercase prefix `silver_`. The outcome-specific silver labels to use will be provided separately.

### Compact example for data configuration in PheNorm_Analysis.Rmd

```r
data_file <- here::here(
  "Data", "Smoke_test", "phenorm_smoke_test_nonrare_info.csv"
)

study_id_col <- "study_id"
reviewed_col <- "reviewed_col"
reviewed_value <- 1
gold_outcome_col <- "gold_outcome"
utilization_col <- "utilization"
sampling_weight_col <- "sampling_weight"

silver_label_cols <- c(
  "silver_total_icd_nlp",
  "silver_total_icd_mention",
  "silver_total_nlp"
)
predictor_cols <- c(
  "age", "sex_female",
  "race_asian", "race_black", "race_white",
  "C0000001", "C0000002"
)

site <- "smoke_test"
stage4_data_site <- site
stage4_model_site <- site
stage4_data_dir <- NULL
stage4_output_dir <- NULL

analysis_id <- NULL
```

### Cross-site stage-4 prediction

For the usual same-site analysis, leave the four stage-4 settings as shown above. The current run's analysis data and fitted model will be used.

To apply a model trained at one site to data from another site, specify both site names and the directories containing the required files:

```r
stage4_data_site <- "site_b"
stage4_model_site <- "site_a"
stage4_data_dir <- "/path/to/site_b/analysis_data"
stage4_output_dir <- "/path/to/site_a/results"
```

The configured directories must contain these exact paths:

```text
<stage4_data_dir>/<analysis_name>_<stage4_data_site>_analysis_data.rds
<stage4_output_dir>/fits/<analysis_name>_<stage4_model_site>_phenorm_output.rds
```

The external analysis data must contain variables compatible with the fitted model. Predictions are written under `<stage4_output_dir>/fits/`. When `stage4_data_site` differs from `site`, the report skips the gold-standard diagnostic plot because the external predictions do not correspond to the cohort prepared in the current notebook.

# Running example

The following section provides instruction on how to run PheNorm_Analysis.Rmd with different tools. This script uses a synthetic data (`Data/Smoke_data`) with a simple data generation mechanism, so the result may not reflect the actual performance of the method.
## Running with RStudio

1. Open `PheNorm_renv.Rproj` in RStudio.
2. Confirm that the working directory is the `PheNorm_renv` project root.
3. If the project library has not been restored on this computer, run in the R console:

   ```r
   install.packages("renv")  # Only if renv is unavailable
   renv::restore()
   renv::status()
   ```

4. Open `PheNorm_Analysis.Rmd`.
5. Edit and save the user-configuration chunk.
6. Click **Knit**.

The Knit button uses the document's custom knit function. It creates:

```text
Result/PheNorm_Analysis_result_YYYYMMDD_HHMMSS/
```

The rendered report is saved in that directory as `Analysis.html`. If `analysis_id` is set, it controls analysis artifact names, but the timestamped run-directory name is based on the Rmd filename used by the Knit function.

## Running with RGui

Start RGui, then run the following commands in its console. This example runs `PheNorm_Analysis.Rmd` with the included smoke-test data:

```r
setwd("/path/to/PheNorm_renv")

# Activate the project-specific package library.
source("renv/activate.R")

# Only needed the first time, or when the lockfile changes:
# renv::restore()

input <- "PheNorm_Analysis.Rmd"
run_name <- paste0(
  tools::file_path_sans_ext(basename(input)),
  "_result_",
  format(Sys.time(), "%Y%m%d_%H%M%S")
)
output_dir <- file.path(getwd(), "Result", run_name)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
Sys.setenv(RUN_DIR = output_dir)

tryCatch(
  rmarkdown::render(
    input = input,
    output_file = "Analysis.html",
    output_dir = output_dir
  ),
  finally = Sys.unsetenv("RUN_DIR")
)
```

Replace `/path/to/PheNorm_renv` with the actual project path. RGui does not include Pandoc, so Pandoc must be installed separately and available on the system `PATH`. Its availability can be checked with:

```r
rmarkdown::pandoc_available()
```

The report is written to:

```text
Result/PheNorm_Analysis_result_YYYYMMDD_HHMMSS/Analysis.html
```

Keep RGui open until rendering and all four pipeline stages finish.

## Running without RStudio

Install R and Pandoc, and make both `Rscript` and `pandoc` available on the system `PATH`. Then open a terminal and change to the project root.

macOS/Linux/Windows (terminal accessed through VS Code) example:

```bash
cd "/path/to/PheNorm_renv"
Rscript -e 'renv::restore()'
Rscript -e 'stopifnot(rmarkdown::pandoc_available())'
Rscript -e 'input <- "PheNorm_Analysis.Rmd"; out <- file.path("Result", paste0(tools::file_path_sans_ext(basename(input)), "_result_", format(Sys.time(), "%Y%m%d_%H%M%S"))); dir.create(out, recursive = TRUE, showWarnings = FALSE); Sys.setenv(RUN_DIR = out); rmarkdown::render(input, output_file = "Analysis.html", output_dir = out)'
```

The package restore only needs to be repeated when the environment is missing or the lockfile changes.

### Output location

The terminal command sets `RUN_DIR` and `output_dir` to the same timestamped directory, matching the RStudio Knit behavior. The rendered report is stored at:

```text
Result/PheNorm_Analysis_result_YYYYMMDD_HHMMSS/Analysis.html
```

Results and logs are stored in that run directory. Prepared and analysis-ready data are stored under the matching directory in `Result/Processed_data/`.

## Pipeline stages

### Cohort preparation

The Rmd reads the CSV, validates configured columns and values, creates the standardized fields expected by the pipeline, assigns internal silver-label names, and saves a prepared RDS file.

### Stage 1: process input data

`PheNorm/01_process_data.R` creates the analysis-ready data, identifies the silver labels, separates structured and NLP variables, and applies the pipeline's transformations.

### Stage 2: fit PheNorm

`PheNorm/02_run_phenorm.R` fits one PheNorm model per silver label, using the configured utilization, weight, corruption rate, training-size multiplier, and seed.

### Stage 3: internal evaluation

`PheNorm/03_get_results.R` evaluates predictions on the chart-reviewed rows and produces AUC estimates, ROC curves, performance tables, and related figures.

### Stage 4: full-cohort prediction

`PheNorm/Modified_04_get_predicted_probabilities.R` applies the selected fitted model to the selected analysis data and exports probabilities for the full cohort. The data and model may come from the same site or different sites.

Each stage runs in a separate R process. Its combined console output is saved to a stage-specific log file. A nonzero exit status stops the Rmd.

## Outputs

For a run named `<run_name>_result_YYYYMMDD_HHMMSS`, the standard output layout is:

```text
Result/
├── <run_name>_result_YYYYMMDD_HHMMSS/
│   ├── Analysis.html                         # RStudio Knit only
│   ├── logs/
│   │   ├── 01_process_data.log
│   │   ├── 02_run_phenorm.log
│   │   ├── 03_get_results.log
│   │   └── 04_get_predicted_probabilities.log
│   └── results/
│       ├── fits/
│       │   ├── <analysis>_<site>_phenorm_output.rds
│       │   └── <analysis>_<data_site>_phenorm_all_predicted_probabilities_using_<model_site>_model.csv
│       └── plots_and_tables/
│           ├── ..._aucs.csv
│           ├── ..._combined_roc.png
│           └── additional performance tables and figures
└── Processed_data/
    └── <run_name>_result_YYYYMMDD_HHMMSS/
        ├── prepared_input/
        │   └── <analysis>_prepared.rds
        └── analysis_data/
            ├── <analysis>_<site>_analysis_data.rds
            └── <analysis>_<site>_summary_statistics.csv
```

Stage 4 also creates a predicted-probability histogram under `fits/`. If external `stage4_data_dir` or `stage4_output_dir` values are configured, stage 4 reads from and writes to those locations instead of the current run's corresponding directories.
