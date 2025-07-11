# HOPE-Box molecular optimization
import time

def get_graphbp_output_path(wildcards):
    """Generate GraphBP output path from config"""
    graphbp_config = config['modules']['graphbp']
    pattern = graphbp_config['output_pattern']
    
    relative_path = pattern.format(
        epoch=wildcards.epoch,
        num_gen=wildcards.num_gen,
        known_binding_site=wildcards.known_binding_site,
        pdbid=wildcards.pdbid
    )
    return f"{graphbp_config['path']}/{graphbp_config['trained_model']}/{relative_path}"

rule synthesizability:
    input:
        lambda wildcards: (
            get_graphbp_output_path(wildcards)
            if int(wildcards.epoch) != 0
            else f"{config['modules']['hope_box']['path']}/{config['modules']['hope_box']['data_dir']}/aurora_kinase_{config['parameters']['aurora']}_interactions.csv"
        )
    output:
        f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/synthesizability_scores.csv"
    params: 
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        hope_box_path = lambda wildcards: config['modules']['hope_box']['path']
        # output_file = lambda wildcards, output: output[0]
    # resources:
    #     mem_mb = lambda wildcards: config['resources']['hope_box']['mem_mb'],
    #     threads = lambda wildcards: config['resources']['hope_box']['threads']
    benchmark:
        f"benchmarks/experiment_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/synthesizability.txt"
    shell: 
        """
        cd {params.hope_box_path} && \
        python synthesizability_scores.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} 
        """
        
# --output_file ../../{params.output_file}



rule lipinski:
    input:
        lambda wildcards: (
            [get_graphbp_output_path(wildcards),
            f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/synthesizability_scores.csv"]
            if int(wildcards.epoch) != 0
            else f"{config['modules']['hope_box']['path']}/{config['modules']['hope_box']['data_dir']}/aurora_kinase_{config['parameters']['aurora']}_interactions.csv"
        )
    output:
        f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/lipinski_pass.csv"
    params:
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        hope_box_path = lambda wildcards: config['modules']['hope_box']['path']
    benchmark:
        f"benchmarks/experiment_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/lipinski.txt"
    shell:
        """
        cd {params.hope_box_path} && \
        python lipinski.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} 
        """

rule tanimoto_intra:
    input:
        lambda wildcards: (
                [get_graphbp_output_path(wildcards),
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/lipinski_pass.csv"]
                if int(wildcards.epoch) != 0
                else f"{config['modules']['hope_box']['path']}/{config['modules']['hope_box']['data_dir']}/aurora_kinase_{config['parameters']['aurora']}_interactions.csv"
            )
    output:
        f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_intra.csv"
    params:
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        hope_box_path = lambda wildcards: config['modules']['hope_box']['path']
    benchmark:
        f"benchmarks/experiment_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_intra.txt"
    shell:
        """
        cd {params.hope_box_path} && \
        python tanimoto_intra.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} 
        """

rule tanimoto_inter:
    input:
        lambda wildcards: (
                [get_graphbp_output_path(wildcards),
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_intra.csv"]
                if int(wildcards.epoch) != 0
                else f"{config['modules']['hope_box']['path']}/{config['modules']['hope_box']['data_dir']}/aurora_kinase_{config['parameters']['aurora']}_interactions.csv"
            )
    output:
        f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_inter.csv"
    params:
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        hope_box_path = lambda wildcards: config['modules']['hope_box']['path']
    benchmark:
        f"benchmarks/experiment_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_inter.txt"
    shell:
        """
        cd {params.hope_box_path} && \
        python tanimoto_inter.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} 
        """

rule graphics:
    input: 
        lambda wildcards: (
                [get_graphbp_output_path(wildcards),
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/synthesizability_scores.csv",
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/lipinski_pass.csv",
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_intra.csv",
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_inter.csv"
                ]
                if int(wildcards.epoch) != 0
                else f"{config['modules']['hope_box']['path']}/{config['modules']['hope_box']['data_dir']}/aurora_kinase_{config['parameters']['aurora']}_interactions.csv"
            )
    output:
        directory(f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/images")
    params:
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        hope_box_path = lambda wildcards: config['modules']['hope_box']['path']
    benchmark:
        f"benchmarks/experiment_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/graphics.txt"
    shell:
        """
        cd {params.hope_box_path} && \
        python graphics.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} 
        """

rule postprocess:
    input: 
        lambda wildcards: (
                [get_graphbp_output_path(wildcards),
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/synthesizability_scores.csv",
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/lipinski_pass.csv",
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_intra.csv",
                f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/tanimoto_inter.csv",
                directory(f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/images")
                ]
                if int(wildcards.epoch) != 0
                else f"{config['modules']['hope_box']['path']}/{config['modules']['hope_box']['data_dir']}/aurora_kinase_{config['parameters']['aurora']}_interactions.csv"
            )
    output:
        f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/merged_scores.csv",
        f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/top_100_tanimoto.csv",
        f"{config['modules']['hope_box']['path']}/results/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/top_50_sascore.csv",
        directory(f"{config['modules']['vina_box']['path']}/{config['parameters']['aurora']}/epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/ligands")
    params:
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        hope_box_path = lambda wildcards: config['modules']['hope_box']['path'],
        vina_path = lambda wildcards: config['modules']['vina_box']['path']
    benchmark:
        f"benchmarks/experiment_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/graphics.txt"
    shell:
        """
        cd {params.hope_box_path} && \
        python graphics.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} 
        """

# rule postprocess:
#     input:
#         lambda wildcards: [
#             (directory(f"{config['trained_model_path']}/gen_mols_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/sdf")
#              if config["epoch"] != 0
#              else f"post_hoc_filtering/data/aurora_kinase_{wildcards.aurora}_interactions.csv"),
#             f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/synthesizability_scores_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
#             f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/lipinski_pass_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
#             f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/tanimoto_intra_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
#             f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/tanimoto_inter_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}.csv",
#             directory(f"post_hoc_filtering/results_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}/images")
#         ]
#     output:
#         "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/merged_scores_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
#         "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/top_100_tanimoto_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
#         "post_hoc_filtering/results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/top_50_sascore_{epoch}_{num_gen}_{known_binding_site}_{pdbid}.csv",
#         directory("docking/{pdbid}/experiment_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/ligands")
#     benchmark:
#         "benchmarks/postprocess_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}.txt"
#     params:
#         num_gen = config["num_gen"],
#         epoch = config["epoch"],
#         known_binding_site = config["known_binding_site"],
#         aurora = config["aurora"],
#         pdbid = config["pdbid"]
#     shell:
#         "{config[python_env_path]} post_hoc_filtering/post_processing.py "
#         "--num_gen {params.num_gen} --epoch {params.epoch} "
#         "--known_binding_site {params.known_binding_site} "
#         "--aurora {params.aurora} --pdbid {params.pdbid}"
