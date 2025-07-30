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
        lambda wildcards: get_target_files(config)

def get_target_files(config):
    """Generate list of target files based on configuration"""
    files = []
    
    # GraphBP outputs (only if skip_generate is False)
    if not config.get("parameters", {}).get("skip_generate", False):
        files.append("{graphbp_path}/{trained_model}/gen_mols_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/sdf")
    
    # HOPE-Box outputs  
    files.extend([
        "{hope_path}/results/experiment_{experiment}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/merged_scores.csv",
        "{hope_path}/results/experiment_{experiment}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/synthesizability_scores.csv",
        "{hope_path}/results/experiment_{experiment}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/lipinski_pass.csv",
        "{hope_path}/results/experiment_{experiment}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/tanimoto_intra.csv",
        "{hope_path}/results/experiment_{experiment}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/tanimoto_inter.csv",
    ])
    
    # EquiBind outputs
    files.extend([
        "{equibind_path}/results/experiment_{experiment}_{epoch}_{num_gen}_{known_binding_site}_{pdbid}/ligands/failed.txt",
        "{equibind_path}/results/experiment_{experiment}_{epoch}_{num_gen}_{known_binding_site}_{pdbid}/ligands/output.sdf",
        "{equibind_path}/results/experiment_{experiment}_{epoch}_{num_gen}_{known_binding_site}_{pdbid}/ligands/success.txt",
        "{equibind_path}/results/experiment_{experiment}_{epoch}_{num_gen}_{known_binding_site}_{pdbid}/ligands/confidence_scores.csv",
    ])
    
    # Delta LinF9 pipeline final output
    # files.append("benchmarks/experiment_{experiment}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/final_pipeline_report.txt")
    
    return expand(files,
                  graphbp_path=config['modules']['graphbp']['path'],
                  trained_model=config['modules']['graphbp']['trained_model'],
                  hope_path=config['modules']['hope_box']['path'],
                  equibind_path=config['modules']['equibind']['path'],
                  epoch=config['parameters']['epoch'],
                  num_gen=config['parameters']['num_gen'],
                  known_binding_site=config['parameters']['known_binding_site'],
                  pdbid=config['parameters']['pdbid'],
                  experiment=config['parameters']['experiment'])

# Clean rule
rule clean:
    shell:
        "rm -rf results/ data/processed/"
