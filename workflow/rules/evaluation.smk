###################################
#### evaluation sub workflow  ####
###################################


"""
Results will be saved in results/evaluation/<training_run>

Evaluation of training runs like AUPRC, AUROC or curves. 
Also mean AURPRC and AUROC for repetetive (100 times) CV training.
"""

import random


def getSeedsForTraining(training_run, n):
    """
    Getting n number of integers in the range of 0,100000 using the seed of the given training run.
    """
    seed = config["training"][training_run]["config"]["seed"]
    random.seed(seed)

    seeds = [random.randint(0, 100000) for x in range(n)]

    return seeds


rule evaluation_auc:
    input:
        "results/training/{training_run}/predictions/predictions.with_labels.tsv.gz",
    output:
        "results/evaluation/{training_run}/metrics/auc.tsv.gz",
    params:
        label_column="LABEL",
        prediction_column="SCORE",
        positive_label=1,
    wrapper:
        getWrapper("evaluate/auc")


rule evaluation_aucRepetitive:
    input:
        "results/training/{training_run}/predictions/repetitive/predictions.{seed}.with_labels.tsv.gz",
    output:
        temp(
            "results/evaluation/{training_run}/metrics/repetitive/auc_tmp.{seed}.tsv.gz"
        ),
    params:
        label_column="LABEL",
        prediction_column="SCORE",
        positive_label=1,
    wrapper:
        getWrapper("evaluate/auc")


rule evaluation_aucRepetitiveRename:
    input:
        "results/evaluation/{training_run}/metrics/repetitive/auc_tmp.{seed}.tsv.gz",
    output:
        temp("results/evaluation/{training_run}/metrics/repetitive/auc.{seed}.tsv.gz"),
    params:
        columns=lambda wc: {"value": "seed_%d" % int(wc.seed)},
    wrapper:
        getWrapper("file_manipulation/rename")


rule evaluation_aucRepetitiveCombine:
    input:
        lambda wc: expand(
            "results/evaluation/{{training_run}}/metrics/repetitive/auc.{seed}.tsv.gz",
            seed=getSeedsForTraining(wc.training_run, 100),
        ),
    output:
        "results/evaluation/{training_run}/metrics/repetitive/auc_all.tsv.gz",
    params:
        index="metric",
    wrapper:
        getWrapper("file_manipulation/concat")


rule evaluation_aucRepetitiveMean:
    input:
        "results/evaluation/{training_run}/metrics/repetitive/auc_all.tsv.gz",
    output:
        "results/evaluation/{training_run}/metrics/repetitive/auc_all.mean_max_min.tsv.gz",
    params:
        columns=lambda wc: [
            "seed_%d" % seed for seed in getSeedsForTraining(wc.training_run, 100)
        ],
        new_columns=["mean", "max", "min"],
        operations=["mean", "max", "min"],
    wrapper:
        getWrapper("file_manipulation/summarize_columns")


#### plots


rule evaluation_plot_metrics:
    input:
        "results/training/{training_run}/predictions/predictions.with_labels.tsv.gz",
    output:
        "results/evaluation/{training_run}/metrics/curves_prc_roc.png",
    params:
        label_column="LABEL",
        score_column="SCORE",
        positive_label=1,
    wrapper:
        getWrapper("plots/metric_curves")