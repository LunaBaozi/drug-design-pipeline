# Vina-Box molecular docking

rule vina_docking:
    input:
        csv_file=f"external/equibind/results/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/top_15_confidence_with_synth.csv",
    output:
        f"external/vina-box/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/vina_results.csv"
    params:
        experiment = "{experiment}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        equibind_path = lambda wildcards: config['modules']['equibind']['path'],
        vina_path = lambda wildcards: config['modules']['vina_box']['path'],
    conda:
        "/vol/data/drug-design-pipeline/workflow/envs/vina.yaml"
    # log:
    #     "results/logs/vina_box/{sample}_prepare.log"
    benchmark:
        f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/vina.txt"
    shell:
        """
        cd {params.vina_path} && pwd && \
        bash run_pipeline.sh \
            {params.epoch} \
            {params.num_gen} \
            {params.known_binding_site} \
            {params.pdbid} \
            {params.aurora} \
            {params.experiment}
        """

rule pareto:
    input:
        f"external/vina-box/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/vina_results.csv"
    output:
        f"external/vina-box/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/vina_results_postprocessed.csv",
        f"external/vina-box/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/pareto_front.csv",
        f"external/vina-box/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/sa_vs_affinity_plot.png"
    params:
        experiment = "{experiment}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        equibind_path = lambda wildcards: config['modules']['equibind']['path'],
        vina_path = lambda wildcards: config['modules']['vina_box']['path'],
    # conda:
    #     "/vol/data/drug-design-pipeline/workflow/envs/vina.yaml"
    benchmark:
        f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/vina.txt"
    shell:
        """
        cd {params.vina_path} && \
        python top_scoring_docking.py \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} \
            --experiment {params.experiment}
        """