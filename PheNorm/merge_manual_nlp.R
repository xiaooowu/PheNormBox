# merge dataset containing silver labels, raw NLP variables, structured variables
# with the dataset containing the manually-curated NLP variables

# load required functions and packages -----------------------------------------
library("readr")
library("dplyr")
library("tidyselect")
library("here")

# RENV PORTABILITY CHANGE: keep optional manual-NLP inputs and outputs in Data.
here::i_am("PheNorm_renv.Rproj")

# read in the datasets ---------------------------------------------------------
# top-level data directory
data_dir <- here::here("Data", "manual_nlp")
final_data_dir <- file.path(data_dir, "Severity-specific silver-standard surrogates")

silver_label_data_name <- "SevSpecSlvStdSur_N8329_23JAN2023.csv"
manual_nlp_data_name <- "Tp_vst_caldays_per_feature_n8329.csv"

# dataset with silver labels, raw NLP variables, structured variables
initial_dataset <- readr::read_csv(file.path(final_data_dir, silver_label_data_name))

# dataset with manually-curated NLP variables
manual_nlp_dataset <- readr::read_csv(file.path(data_dir, "Per Member Per Dx within 61 days", manual_nlp_data_name))

# select only the n_ments variables
manual_nlp_vars_of_interest <- manual_nlp_dataset %>% 
  select(Studyid, starts_with("n_ments_nn"))
# do the merge -----------------------------------------------------------------
final_dataset <- initial_dataset %>% 
  left_join(manual_nlp_vars_of_interest, by = "Studyid")

# save off as a .csv -----------------------------------------------------------
dir.create(final_data_dir, recursive = TRUE, showWarnings = FALSE)
readr::write_csv(final_dataset, file.path(final_data_dir, "full_analysis_dataset_n8329.csv"))
