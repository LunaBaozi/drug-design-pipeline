# Snakefile
from snakemake.utils import validate
import pandas as pd
import os

# Configuration
configfile: "config/config.yaml"

# Load sample information
samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)

# Include rules
include: "workflow/rules/common.smk"
include: "workflow/rules/graphbp.smk"
include: "workflow/rules/hope_box.smk"
include: "workflow/rules/equibind.smk"
include: "workflow/rules/vina_box.smk"

# Target rule - defines the final outputs
rule all:
    input:
        # Final docking results for all samples
        expand("results/final_results/{sample}_docking_complete.txt", sample=samples.index),
        # Summary plots and tables
        "results/plots/pipeline_summary.png",
        "results/tables/final_summary.csv"

# Clean rule
rule clean:
    shell:
        "rm -rf results/ data/processed/"