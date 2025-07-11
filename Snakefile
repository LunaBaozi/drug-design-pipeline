# Snakefile
from snakemake.utils import validate
import pandas as pd
import os
import time

# Configuration
configfile: "config/config.yaml"

# Load sample information
# samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)

# Include rules
include: "workflow/rules/common.smk"
include: "workflow/rules/graphbp.smk"
include: "workflow/rules/hope_box.smk"
# include: "workflow/rules/equibind.smk"
# include: "workflow/rules/vina_box.smk"

start_time = time.time()

onsuccess:
    end_time = time.time()
    elapsed = end_time - start_time
    print(f"Pipeline completed successfully in {elapsed:.2f} seconds ({elapsed/60:.2f} minutes)")

onerror:
    end_time = time.time()
    elapsed = end_time - start_time
    print(f"Pipeline failed after {elapsed:.2f} seconds ({elapsed/60:.2f} minutes)")

# Target rule - defines the final outputs
rule all:
    input:
        # GraphBP generation results - target the directory output from evaluate rule
        # "{trained_model_path}/gen_mols_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/sdf".format(
        #         trained_model_path=config["trained_model_path"],
        #         epoch=config["epoch"],
        #         num_gen=config["num_gen"],
        #         known_binding_site=config["known_binding_site"],
        #         pdbid=config["pdbid"])
        # expand(
        expand(
            "{path}/{results_dir}/epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/synthesizability_scores_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
            path=config['modules']['hope_box']['path'],
            results_dir=config['modules']['hope_box']['results_dir'],
            epoch=config['parameters']['epoch'],
            num_gen=config['parameters']['num_gen'],
            known_binding_site=config['parameters']['known_binding_site'],
            pdbid=config['parameters']['pdbid']
        )
        # trained_model_path=config["trained_model_path"],
        # epoch=config["epoch"],
        # num_gen=config["num_gen"],
        # known_binding_site=config["known_binding_site"],
        # pdbid=config["pdbid"],
        # aurora=config["aurora"]
        # )

# Clean rule
rule clean:
    shell:
        "rm -rf results/ data/processed/"
