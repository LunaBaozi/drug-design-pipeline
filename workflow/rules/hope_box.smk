# HOPE-Box molecular optimization

# rule run_hope_box_generation:
#     input:
#         molecules="results/graphbp/{sample}_molecules.sdf"
#     output:
#         generated="results/hope_box/{sample}_generated.sdf",
#         scores="results/hope_box/{sample}_scores.csv"
#     params:
#         num_gen=config.get("hope_box", {}).get("num_gen", 100),
#         epoch=config.get("hope_box", {}).get("epoch", 50),
#         known_binding_site=config.get("hope_box", {}).get("known_binding_site", "True"),
#         aurora=config.get("hope_box", {}).get("aurora", "B")
#     conda:
#         "../envs/hope_box.yaml"
#     log:
#         "results/logs/hope_box/{sample}_generation.log"
#     shell:
#         """
#         cd external/hope-box && \
#         python wrapper.py \
#             --num_gen {params.num_gen} \
#             --epoch {params.epoch} \
#             --known_binding_site {params.known_binding_site} \
#             --aurora {params.aurora} \
#             2> {log}
#         """

# rule run_hope_box_postprocessing:
#     input:
#         generated="results/hope_box/{sample}_generated.sdf"
#     output:
#         processed="results/hope_box/{sample}_processed.sdf",
#         synth_scores="results/hope_box/{sample}_synthesizability.csv",
#         lipinski="results/hope_box/{sample}_lipinski.csv"
#     params:
#         sample="{sample}"
#     conda:
#         "../envs/hope_box.yaml"
#     log:
#         "results/logs/hope_box/{sample}_postprocessing.log"
#     shell:
#         """
#         cd external/hope-box && \
#         python post_processing.py \
#             --input {input.generated} \
#             --output {output.processed} \
#             --sample {params.sample} \
#             2> {log}
#         """


rule synthesizability:
    input:
        lambda wildcards: (
            directory(f"{config['trained_model_path']}/gen_mols_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/sdf")
            if config["epoch"] != 0
            else f"post_hoc_filtering/data/aurora_kinase_{wildcards.aurora}_interactions.csv"
        )
    output:
        "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/synthesizability_scores_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv"
    params: # wildcards
        num_gen = config["num_gen"],
        epoch = config["epoch"],
        known_binding_site = config["known_binding_site"],
        aurora = config["aurora"],
        pdbid = config["pdbid"]
    benchmark:
        "benchmarks/synthesizability_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell: 
        "{config[python_env_path]} post_hoc_filtering/synthesizability_scores.py "
        "--num_gen {params.num_gen} --epoch {params.epoch} "
        "--known_binding_site {params.known_binding_site} "
        "--aurora {params.aurora} --pdbid {params.pdbid}"

rule lipinski:
    input:
        lambda wildcards: (
            directory(f"{config['trained_model_path']}/gen_mols_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/sdf")
            if config["epoch"] != 0
            else f"post_hoc_filtering/data/aurora_kinase_{wildcards.aurora}_interactions.csv"
        )
    output:
        "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/lipinski_pass_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv"
    params:
        num_gen = config["num_gen"],
        epoch = config["epoch"],
        known_binding_site = config["known_binding_site"],
        aurora = config["aurora"],
        pdbid = config["pdbid"]
    benchmark:
        "benchmarks/lipinski_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        "{config[python_env_path]} post_hoc_filtering/lipinski.py "
        "--num_gen {params.num_gen} --epoch {params.epoch} "
        "--known_binding_site {params.known_binding_site} "
        "--aurora {params.aurora} --pdbid {params.pdbid}"

rule tanimoto_intra:
    input:
        lambda wildcards: (
            directory(f"{config['trained_model_path']}/gen_mols_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/sdf")
            if config["epoch"] != 0
            else f"post_hoc_filtering/data/aurora_kinase_{wildcards.aurora}_interactions.csv"
        )
    output:
        "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/tanimoto_intra_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv"
    params:
        num_gen = config["num_gen"],
        epoch = config["epoch"],
        known_binding_site = config["known_binding_site"],
        aurora = config["aurora"],
        pdbid = config["pdbid"]
    benchmark:
        "benchmarks/tanimoto_intra_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        "{config[python_env_path]} post_hoc_filtering/tanimoto_intra.py "
        "--num_gen {params.num_gen} --epoch {params.epoch} "
        "--known_binding_site {params.known_binding_site} "
        "--aurora {params.aurora} --pdbid {params.pdbid}"

rule tanimoto_inter:
    input:
        lambda wildcards: (
            directory(f"{config['trained_model_path']}/gen_mols_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/sdf")
            if config["epoch"] != 0
            else f"post_hoc_filtering/data/aurora_kinase_{wildcards.aurora}_interactions.csv"
        )
    output:
        "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/tanimoto_inter_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv"
    params:
        num_gen = config["num_gen"],
        epoch = config["epoch"],
        known_binding_site = config["known_binding_site"],
        aurora = config["aurora"],
        pdbid = config["pdbid"]
    benchmark:
        "benchmarks/tanimoto_inter_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        "{config[python_env_path]} post_hoc_filtering/tanimoto_inter.py "
        "--num_gen {params.num_gen} --epoch {params.epoch} "
        "--known_binding_site {params.known_binding_site} "
        "--aurora {params.aurora} --pdbid {params.pdbid}"


rule graphics:
    input:
        lambda wildcards: [
            (directory(f"{config['trained_model_path']}/gen_mols_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/sdf")
             if config["epoch"] != 0
             else f"post_hoc_filtering/data/aurora_kinase_{wildcards.aurora}_interactions.csv"),
            f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/synthesizability_scores_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
            f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/lipinski_pass_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
            f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/tanimoto_intra_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
            f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/tanimoto_inter_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv"
        ]
    output:
        directory("post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/images")
    params:
        num_gen = config["num_gen"],
        epoch = config["epoch"],
        known_binding_site = config["known_binding_site"],
        aurora = config["aurora"],
        pdbid = config["pdbid"]
    shell:
        "{config[python_env_path]} post_hoc_filtering/graphics.py "
        "--num_gen {params.num_gen} --epoch {params.epoch} "
        "--known_binding_site {params.known_binding_site} "
        "--aurora {params.aurora} --pdbid {params.pdbid}"

rule postprocess:
    input:
        lambda wildcards: [
            (directory(f"{config['trained_model_path']}/gen_mols_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/sdf")
             if config["epoch"] != 0
             else f"post_hoc_filtering/data/aurora_kinase_{wildcards.aurora}_interactions.csv"),
            f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/synthesizability_scores_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
            f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/lipinski_pass_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
            f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/tanimoto_intra_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
            f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/tanimoto_inter_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
            directory(f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/images")
        ]
    output:
        "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/merged_scores_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
        "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/top_100_tanimoto_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
        "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/top_50_sascore_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
        directory("docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/ligands")
    benchmark:
        "benchmarks/postprocess_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    params:
        num_gen = config["num_gen"],
        epoch = config["epoch"],
        known_binding_site = config["known_binding_site"],
        aurora = config["aurora"],
        pdbid = config["pdbid"]
    shell:
        "{config[python_env_path]} post_hoc_filtering/post_processing.py "
        "--num_gen {params.num_gen} --epoch {params.epoch} "
        "--known_binding_site {params.known_binding_site} "
        "--aurora {params.aurora} --pdbid {params.pdbid}"
