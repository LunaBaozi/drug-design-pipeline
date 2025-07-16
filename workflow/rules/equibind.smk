# EquiBind protein-ligand binding prediction
rule prepare_EB_input:
    # input:
    #     lambda wildcards: (
    #         [directory(f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands")
    #         ]
    #     )
        # molecules="results/hope_box/{sample}_processed.sdf",
        # protein=lambda wildcards: samples.loc[wildcards.sample, "protein_path"]
    output:
        f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/multiligand.sdf"
        # prepared="results/equibind/{sample}_prepared.pkl"
    params:
        experiment = "{experiment}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        equibind_path = lambda wildcards: config['modules']['equibind']['path'],
        vina_path = lambda wildcards: config['modules']['vina_box']['path']
    conda:
        "/vol/data/drug-design-pipeline/workflow/envs/environment_EB_cpu.yml"
    # log:
    #     "results/logs/equibind/{sample}_prepare.log"
    benchmark:
        f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/prepare_EB_input.txt"
    shell:
        """
        cd {params.equibind_path}/data_preparation && \
        python create_lig_rec_pairs.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} \
            --experiment {params.experiment} 
        """

rule run_equibind:
    input:
        f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/multiligand.sdf"
    output:
        f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/failed.txt",
        f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/output.sdf",
        f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/success.txt"
    params:
        experiment = "{experiment}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        equibind_path = lambda wildcards: config['modules']['equibind']['path'],
        vina_path = lambda wildcards: config['modules']['vina_box']['path']
    conda:
        "/vol/data/drug-design-pipeline/workflow/envs/environment_EB_cpu.yml"
    # log:
    #     "results/logs/equibind/{sample}_binding.log"
    benchmark:
        f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/run_EB.txt"
    shell:
        """
        cd {params.equibind_path} && \
        python multiligand_inference.py \
            -o data/{wildcards.pdbid}/experiment_{wildcards.experiment}_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}/ligands/ \
            -r data/{wildcards.pdbid}/experiment_{wildcards.experiment}_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}/ligands/4af3_A_rec_reduce_flip.pdb \
            -l data/{wildcards.pdbid}/experiment_{wildcards.experiment}_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}/ligands/multiligand.sdf 
        """