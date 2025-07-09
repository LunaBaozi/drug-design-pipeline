# GraphBP molecular generation/prediction
import time

# Define config flags to control skipping
skip_generate = config.get("skip_generate", False)

# Centralize wildcards and params for consistency
wildcards = {
    "trained_model_path": config["trained_model_path"],
    "epoch": config["epoch"],
    "num_gen": config["num_gen"],
    "known_binding_site": config["known_binding_site"],
    "aurora": config["aurora"],
    "pdbid": config["pdbid"]
}

start_time = time.time()

onsuccess:
    end_time = time.time()
    elapsed = end_time - start_time
    print(f"Pipeline completed successfully in {elapsed:.2f} seconds ({elapsed/60:.2f} minutes)")

onerror:
    end_time = time.time()
    elapsed = end_time - start_time
    print(f"Pipeline failed after {elapsed:.2f} seconds ({elapsed/60:.2f} minutes)")


# if not skip_generate:
rule generate:
    output:
        "{trained_model_path}/epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict"
    params: wildcards
    conda:
        "../envs/graphbp/graphbp_conda_env.yaml"
    benchmark:
        "benchmarks/generate_{trained_model_path}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        "{config[python_env_path]} main_gen.py --epoch {wildcards[epoch]} --num_gen {wildcards[num_gen]} "
        "--known_binding_site {wildcards[known_binding_site]} --pdbid {wildcards[pdbid]}"

rule evaluate:
    input:
        "{trained_model_path}/epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict"
    output:
        directory("{trained_model_path}/gen_mols_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/sdf")
    params: wildcards
    conda:
        "../envs/graphbp/graphbp_conda_env.yaml"
    benchmark:
        "benchmarks/evaluate_{trained_model_path}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        "{config[python_env_path]} main_eval.py --num_gen {wildcards[num_gen]} --epoch {wildcards[epoch]} "
        "--known_binding_site {wildcards[known_binding_site]} --pdbid {wildcards[pdbid]}"


# rule run_graphbp_generation:
#     output:
#         "results/graphbp/{sample}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict"
#     params:
#         sample = "{sample}",
#         epoch = "{epoch}",
#         num_gen = "{num_gen}",
#         known_binding_site = "{known_binding_site}",
#         pdbid = "{pdbid}",
#         output_dir = "results/graphbp"
#     conda:
#         "../envs/graphbp.yaml"
#     shell:
#         """
#         mkdir -p {params.output_dir}
#         cd external/graphbp/OpenMI/GraphBP/GraphBP && \
#         python main_gen.py \
#             --epoch {params.epoch} \
#             --num_gen {params.num_gen} \
#             --known_binding_site {params.known_binding_site} \
#             --pdbid {params.pdbid} \
#             --output_path ../../../../{output}
#         """