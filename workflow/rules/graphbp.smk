# GraphBP molecular generation/prediction
import time

# Define config flags to control skipping
skip_generate = config.get("skip_generate", False)

start_time = time.time()

onsuccess:
    end_time = time.time()
    elapsed = end_time - start_time
    print(f"Pipeline completed successfully in {elapsed:.2f} seconds ({elapsed/60:.2f} minutes)")

onerror:
    end_time = time.time()
    elapsed = end_time - start_time
    print(f"Pipeline failed after {elapsed:.2f} seconds ({elapsed/60:.2f} minutes)")

rule generate:
    output:
        "{trained_model_path}/epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict"
    params: 
        trained_model_path = "{trained_model_path}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}"
    # conda:
    #     "../envs/graphbp/graphbp_conda_env.yml"
    benchmark:
        "benchmarks/generate_{trained_model_path}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        """
        cd external/graphbp/OpenMI/GraphBP/GraphBP && \
        python main_gen.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid}
        """

rule evaluate:
    input:
        "{trained_model_path}/epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.mol_dict"
    output:
        directory("{trained_model_path}/gen_mols_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/sdf")
    params: 
        trained_model_path = "{trained_model_path}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}"
    # conda:
    #     "../envs/graphbp/graphbp_conda_env.yml"
    benchmark:
        "benchmarks/evaluate_{trained_model_path}_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
    shell:
        """
        cd external/graphbp/OpenMI/GraphBP/GraphBP && \
        python main_eval.py \
            --num_gen {params.num_gen} \
            --epoch {params.epoch} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} && \
        mkdir -p ../../../../{output}
        """
