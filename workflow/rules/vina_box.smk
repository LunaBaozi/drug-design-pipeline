# Vina-Box molecular docking

# rule prepare_vina_input:
#     input:
#         poses="results/equibind/{sample}_poses.sdf",
#         protein=lambda wildcards: samples.loc[wildcards.sample, "protein_path"]
#     output:
#         ligand_dir=directory("results/vina_box/{sample}/ligands"),
#         receptor="results/vina_box/{sample}/receptor.pdb"
#     conda:
#         "../envs/vina.yaml"
#     log:
#         "results/logs/vina_box/{sample}_prepare.log"
#     shell:
#         """
#         mkdir -p {output.ligand_dir} && \
#         cp {input.protein} {output.receptor} && \
#         cd external/vina-box && \
#         python prepare_ligands.py \
#             --input {input.poses} \
#             --output_dir {output.ligand_dir} \
#             2> {log}
#         """

# rule run_vina_docking:
#     input:
#         ligand_dir="results/vina_box/{sample}/ligands",
#         receptor="results/vina_box/{sample}/receptor.pdb"
#     output:
#         results="results/vina_box/{sample}/vina_results.csv",
#         complete_flag="results/final_results/{sample}_docking_complete.txt"
#     params:
#         epoch=config.get("vina", {}).get("epoch", 50),
#         num_mols=config.get("vina", {}).get("num_mols", 100),
#         batch_size=config.get("vina", {}).get("batch_size", "1"),
#         pdbid=lambda wildcards: samples.loc[wildcards.sample, "pdbid"]
#     conda:
#         "../envs/vina.yaml"
#     log:
#         "results/logs/vina_box/{sample}_docking.log"
#     shell:
#         """
#         cd external/vina-box && \
#         bash run_pipeline.sh {params.epoch} {params.num_mols} {params.batch_size} {params.pdbid} \
#             2> {log} && \
#         touch {output.complete_flag}
#         """

# rule analyze_docking_results:
#     input:
#         results="results/vina_box/{sample}/vina_results.csv"
#     output:
#         analysis="results/vina_box/{sample}/analysis.csv",
#         plot="results/vina_box/{sample}/docking_plot.png"
#     conda:
#         "../envs/vina.yaml"
#     log:
#         "results/logs/vina_box/{sample}_analysis.log"
#     shell:
#         """
#         cd external/vina-box && \
#         python top_scoring_docking.py \
#             --input {input.results} \
#             --output_csv {output.analysis} \
#             --output_plot {output.plot} \
#             2> {log}
#         """


rule docking:
    input:
        lambda wildcards: directory(
            f"docking/{wildcards['pdbid']}/experiment_epoch_{wildcards['epoch']}_mols_{wildcards['num_gen']}_bs_{wildcards['known_binding_site']}_pdbid_{wildcards['pdbid']}/ligands"
        )
    output: 
        "docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/vina_results.csv"
    conda:
        "vina.yml"
    benchmark:
        "benchmarks/docking_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    params:
        num_gen = config["num_gen"],
        epoch = config["epoch"],        
        known_binding_site = config["known_binding_site"],
        # aurora = config["aurora"],
        pdbid = config["pdbid"]
    shell:
        "bash docking/run_pipeline.sh {params.epoch} {params.num_gen} {params.known_binding_site} {params.pdbid}"

rule pareto:
    input:
        lambda wildcards: f"docking/{wildcards['pdbid']}/experiment_epoch_{wildcards['epoch']}_mols_{wildcards['num_gen']}_bs_{wildcards['known_binding_site']}_pdbid_{wildcards['pdbid']}/vina_results.csv"
    output:
        "docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/vina_results_postprocessed.csv",
        "docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/pareto_front.csv",
        "docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/sa_vs_affinity_plot.png"
    params:
        num_gen = config["num_gen"],
        epoch = config["epoch"],
        known_binding_site = config["known_binding_site"],
        aurora = config["aurora"],
        pdbid = config["pdbid"]
    benchmark:
        "benchmarks/pareto_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        "{config[python_env_path]} docking/top_scoring_docking.py "
        "--num_gen {params.num_gen} --epoch {params.epoch} "
        "--known_binding_site {params.known_binding_site} "
        "--aurora {params.aurora} --pdbid {params.pdbid}"