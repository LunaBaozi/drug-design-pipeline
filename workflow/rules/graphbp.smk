# GraphBP molecular generation/prediction

# rule run_graphbp:
#     input:
#         config="config/config.yaml"
#     output:
#         molecules="results/graphbp/{sample}_molecules.sdf",
#         predictions="results/graphbp/{sample}_predictions.csv"
#     params:
#         sample="{sample}",
#         graphbp_dir="external/graphbp"
#     conda:
#         "../envs/graphbp.yaml"
#     log:
#         "results/logs/graphbp/{sample}.log"
#     shell:
#         """
#         cd {params.graphbp_dir} && \
#         python main.py \
#             --sample {params.sample} \
#             --output_molecules {output.molecules} \
#             --output_predictions {output.predictions} \
#             2> {log}
#         """


import time

start_time = time.time()

onsuccess:
    end_time = time.time()
    elapsed = end_time - start_time
    print(f"Pipeline completed successfully in {elapsed:.2f} seconds ({elapsed/60:.2f} minutes)")

onerror:
    end_time = time.time()
    elapsed = end_time - start_time
    print(f"Pipeline failed after {elapsed:.2f} seconds ({elapsed/60:.2f} minutes)")

rule all: 
    input: 
        expand(
            [
            "docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/vina_results_postprocessed.csv",
            "docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/pareto_front.csv",
            "docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/sa_vs_affinity_plot.png"
            ],
            # [
            # "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/merged_scores_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
            # "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/top_100_tanimoto_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
            # "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/top_50_sascore_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv"
            # ],
            **wildcards
        )

# if not skip_generate:
rule generate:
    output:
        "{trained_model_path}/epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict"
    params: wildcards
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
    benchmark:
        "benchmarks/evaluate_{trained_model_path}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        "{config[python_env_path]} main_eval.py --num_gen {wildcards[num_gen]} --epoch {wildcards[epoch]} "
        "--known_binding_site {wildcards[known_binding_site]} --pdbid {wildcards[pdbid]}"
