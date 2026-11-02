# `plots_and_tables`

This folder contains plots and tables with results from the COVID-19 PheNorm analyses.

The files follow a naming convention: <analysis name>_<phenotype>_<type of mentions>_data_<data site, i.e., where the data came from>_model_<model site, i.e., where the PheNorm model was trained>_<result description>, where text in brackets is replaced.

For example, to view the ROC curve corresponding to the moderate+ phenotype using the phase 1 enhanced dataset, and NLP variables based on all mentions, using data from KPWA and a PheNorm at KPWA, with all silver labels (and the aggregate silver label), look at `phenorm_phase_1_enhanced_moderateplus_covid_all_mentions_data_kpwa_model_kpwa_combined_roc.png`.

The possible analyses are:
* phase 1 enhanced (`phase_1_enhanced`): the original predictor set, with demographic variables and harmonized silver labels between KPWA and VUMC
* other analyses to be filled in

The possible outcomes are:
* moderate+ (`moderateplus_covid`): COVID-19 with moderate or higher severity. Only run in the phase 1 enhanced analysis, to reproduce prior results (presented at AMIA 2022).
* symptomatic (`symptomatic_covid`): any symptomatic COVID-19 (i.e., mild or higher severity).

The possible data and model sites are:
* Kaiser Permanente Washington (`kpwa`)
* Vanderbilt University Medical Center (`vumc`)

The possible results are:
* `<silver label>_combined_performance.png`: a plot showing several performance metrics (F0.5, F1, NPV, PPV, Sensitivity, Specificity) for the silver label (or aggregate, i.e., the mean of the predicted probabilities from the silver label-specific models)
* `<silver label>_perf_table.csv`: the same results as the above bullet, but in a table
* `<silver label>_roc.png`: a plot showing the ROC curve for the given label, plus the AUC.
* `combined_roc.png`: ROC curves for each silver label (and the aggregate) for the given analysis, outcome, and type of NLP variables
* `max_f1.csv`: a table showing the predicted probability cutoff (and quantile), sensitivity, specificity, NPV, F1, and F0.5 for each silver label at the cutoff that maximized the F1 score. There may be multiple rows for a given silver label; that occurs when there were muliple cutoffs that led to F1 values within 0.001 of the maximum.

