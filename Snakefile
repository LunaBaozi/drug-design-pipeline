# Snakefile
from snakemake.utils import validate
import pandas as pd
import os

# Configuration
configfile: "config/config.yaml"

# Load sample information
# samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)

# Include rules
include: "workflow/rules/common.smk"
include: "workflow/rules/graphbp.smk"
# include: "workflow/rules/hope_box.smk"
# include: "workflow/rules/equibind.smk"
# include: "workflow/rules/vina_box.smk"

# Target rule - defines the final outputs
rule all:
    input:
        # GraphBP generation results - target the directory output from evaluate rule
        "{trained_model_path}/gen_mols_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/sdf".format(
                trained_model_path=config["trained_model_path"],
                epoch=config["epoch"],
                num_gen=config["num_gen"],
                known_binding_site=config["known_binding_site"],
                pdbid=config["pdbid"])

# Clean rule
rule clean:
    shell:
        "rm -rf results/ data/processed/"
