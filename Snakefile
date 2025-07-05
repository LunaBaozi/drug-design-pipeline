# Snakefile
from snakemake.utils import validate
import pandas as pd
import os

# Configuration
configfile: "config/config.yaml"

# Validate configuration
validate(config, schema="workflow/schemas/config.schema.yaml")

# Load sample information
samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
validate(samples, schema="workflow/schemas/samples.schema.yaml")

# Include rules
include: "workflow/rules/common.smk"
include: "workflow/rules/preprocessing.smk"
include: "workflow/rules/modeling.smk"
include: "workflow/rules/postprocessing.smk"

# Target rule
rule all:
    input:
        expand("results/final/{sample}_final.txt", sample=samples.index)

# Clean rule
rule clean:
    shell:
        "rm -rf results/ data/processed/"