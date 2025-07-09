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
        # GraphBP generation results
        expand("results/graphbp/{sample}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict",
               sample=samples.index,
               epoch=config["epoch"],
               num_gen=config["num_gen"],
               known_binding_site=config["known_binding_site"],
               pdbid=config["pdbid"]),
        # Final docking results for all samples
        # expand("results/final_results/{sample}_docking_complete.txt", sample=samples.index),
        # Summary plots and tables
        # "results/plots/pipeline_summary.png",
        # "results/tables/final_summary.csv"

# Clean rule
rule clean:
    shell:
        "rm -rf results/ data/processed/"


# from snakemake.utils import validate
# import pandas as pd
# import os

# # Configuration
# configfile: "config/config.yaml"

# # Load sample information
# samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)

# # Simple rule to run GraphBP generation
# rule run_graphbp_generation:
#     output:
#         "{sample}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict"
#     params:
#         sample = "{sample}",
#         epoch = config["epoch"],
#         num_gen = config["num_gen"],
#         known_binding_site = config["known_binding_site"],
#         pdbid = config["pdbid"]
#     shell:
#         """
#         cd external/graphbp && \
#         {config[python_env_path]} main_gen.py \
#             --epoch {params.epoch} \
#             --num_gen {params.num_gen} \
#             --known_binding_site {params.known_binding_site} \
#             --pdbid {params.pdbid}
#         """

# # Target rule
# rule all:
#     input:
#         expand("{sample}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict",
#                sample=samples.index,
#                epoch=config["epoch"],
#                num_gen=config["num_gen"],
#                known_binding_site=config["known_binding_site"],
#                pdbid=config["pdbid"])