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
include: "workflow/rules/equibind.smk"
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
        expand(
            # "{path}/data/{pdbid}/experiment_{experiment}_{epoch}_{num_gen}_{known_binding_site}_{pdbid}/ligands/multiligand.sdf",
            ["{path}/data/{pdbid}/experiment_{experiment}_{epoch}_{num_gen}_{known_binding_site}_{pdbid}/ligands/failed.txt",
            "{path}/data/{pdbid}/experiment_{experiment}_{epoch}_{num_gen}_{known_binding_site}_{pdbid}/ligands/output.sdf",
            "{path}/data/{pdbid}/experiment_{experiment}_{epoch}_{num_gen}_{known_binding_site}_{pdbid}/ligands/success.txt"
            ],
            path=config['modules']['equibind']['path'],
            results_dir=config['modules']['equibind']['results_dir'],
            epoch=config['parameters']['epoch'],
            num_gen=config['parameters']['num_gen'],
            known_binding_site=config['parameters']['known_binding_site'],
            pdbid=config['parameters']['pdbid'],
            experiment=config['parameters']['experiment']
            # "{path}/{results_dir}/experiment_{experiment}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/merged_scores.csv",
            # path=config['modules']['hope_box']['path'],
            # results_dir=config['modules']['hope_box']['results_dir'],
            # epoch=config['parameters']['epoch'],
            # num_gen=config['parameters']['num_gen'],
            # known_binding_site=config['parameters']['known_binding_site'],
            # pdbid=config['parameters']['pdbid'],
            # experiment=config['parameters']['experiment']
        )

# Clean rule
rule clean:
    shell:
        "rm -rf results/ data/processed/"
