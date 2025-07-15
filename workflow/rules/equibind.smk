# EquiBind protein-ligand binding prediction
rule prepare_EB_input:
    input:
        lambda wildcards: (
            [directory(f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands")
            ]
        )
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
        "../envs/equibind2.yaml"
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

# rule run_equibind:
#     input:
#         prepared="results/equibind/{sample}_prepared.pkl"
#     output:
#         binding_poses="results/equibind/{sample}_poses.sdf",
#         binding_scores="results/equibind/{sample}_binding_scores.csv"
#     conda:
#         "../envs/equibind.yaml"
#     log:
#         "results/logs/equibind/{sample}_binding.log"
#     shell:
#         """
#         cd external/equibind && \
#         python run_equibind.py \
#             --input {input.prepared} \
#             --output_poses {output.binding_poses} \
#             --output_scores {output.binding_scores} \
#             2> {log}
#         """