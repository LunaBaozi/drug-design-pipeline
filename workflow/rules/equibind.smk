# EquiBind protein-ligand binding prediction
rule prepare_EB_input:
    input:
        # Add proper input dependency from HOPE-Box - match the correct output pattern
        merged_scores=f"{config['modules']['hope_box']['path']}/results/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/merged_scores.csv"
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
        hope_path = lambda wildcards: config['modules']['hope_box']['path'],
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

rule prepare_receptor:
    input:
        # Add proper input dependency from HOPE-Box - match the correct output pattern
        f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/multiligand.sdf"
    output:
        f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/4af3_A_rec_reduce_noflip.pdb"
        # prepared="results/equibind/{sample}_prepared.pkl"
    params:
        experiment = "{experiment}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        equibind_path = lambda wildcards: config['modules']['equibind']['path'],
        hope_path = lambda wildcards: config['modules']['hope_box']['path'],
        vina_path = lambda wildcards: config['modules']['vina_box']['path']
    conda:
        "/vol/data/drug-design-pipeline/workflow/envs/environment_EB_cpu.yml"
    # log:
    #     "results/logs/equibind/{sample}_prepare.log"
    benchmark:
        f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/prepare_receptor.txt"
    shell:
        """
        cd {params.equibind_path} && \
        bash prepare_receptor.sh \
            --epoch {params.epoch} \
            --num_gen {params.num_gen} \
            --known_binding_site {params.known_binding_site} \
            --pdbid {params.pdbid} \
            --aurora {params.aurora} \
            --experiment {params.experiment}
        """

rule run_equibind:
    input:
        receptor=f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/{{pdbid}}_A_rec_reduce_noflip.pdb",
        multiligand=f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/multiligand.sdf"
    output:
        # ligands_dir=directory(f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands")
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
            -r data/{wildcards.pdbid}/experiment_{wildcards.experiment}_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}/ligands/{wildcards.pdbid}_A_rec_reduce_noflip.pdb \
            -l data/{wildcards.pdbid}/experiment_{wildcards.experiment}_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}/ligands/multiligand.sdf 
        """

rule postprocess_equibind:
    input:
        failed_txt=f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/failed.txt",
        output_sdf=f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/output.sdf",
        success_txt=f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/success.txt",
        receptor_pdb=f"{config['modules']['equibind']['path']}/data/{{pdbid}}/experiment_{{experiment}}_{{epoch}}_{{num_gen}}_{{known_binding_site}}_{{pdbid}}/ligands/{{pdbid}}_A_rec_reduce_noflip.pdb"
    output:
        delta_results=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/delta_linf9_results.csv",
        ranked_results=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/ligands_ranked.csv"
    params:
        experiment = "{experiment}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        aurora = lambda wildcards: config['parameters']['aurora'],
        equibind_path = lambda wildcards: config['modules']['equibind']['path'],
        vina_path = lambda wildcards: config['modules']['vina_box']['path'],
        input_dir = lambda wildcards: f"{config['modules']['equibind']['path']}/data/{wildcards.pdbid}/experiment_{wildcards.experiment}_{wildcards.epoch}_{wildcards.num_gen}_{wildcards.known_binding_site}_{wildcards.pdbid}",
        output_dir = lambda wildcards: f"benchmarks/experiment_{wildcards.experiment}_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}"
    conda:
        "/vol/data/drug-design-pipeline/workflow/envs/delta_linf9.yml"
    # log:
    #     "results/logs/equibind/{sample}_binding.log"
    benchmark:
        f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/post_processing.txt"
    shell:
        """
        # Create output directory
        mkdir -p {params.output_dir}
        
        # Run Delta LinF9 processing on EquiBind output
        python {params.equibind_path}/process_equibind_delta.py \
            -i {params.input_dir} \
            -p {input.receptor_pdb} \
            -o {params.output_dir}
        """

rule analyze_delta_linf9_results:
    input:
        delta_results=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/delta_linf9_results.csv",
        ranked_results=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/ligands_ranked.csv"
    output:
        top_ligands=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/top_10_ligands.csv",
        analysis_plot=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/xgb_analysis.png",
        summary_report=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/analysis_summary.txt"
    params:
        experiment = "{experiment}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        equibind_path = lambda wildcards: config['modules']['equibind']['path'],
        output_dir = lambda wildcards: f"benchmarks/experiment_{wildcards.experiment}_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}"
    conda:
        "/vol/data/drug-design-pipeline/workflow/envs/delta_linf9.yml"
    benchmark:
        f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/analysis.txt"
    shell:
        """
        # Ensure output directory exists
        mkdir -p {params.output_dir}
        
        # Check if we have any successful results
        if [ -s {input.ranked_results} ] && [ $(wc -l < {input.ranked_results}) -gt 1 ]; then
            # Run analysis and visualization without changing directory
            python {params.equibind_path}/analyze_results.py \
                {input.delta_results} \
                -o {params.output_dir} \
                -t 10 \
                --plot \
                --stats > {output.summary_report}
        else
            # Create empty output files if no successful results
            echo "ligand_id,xgb_score,processing_time,status" > {output.top_ligands}
            echo "No successful ligands to analyze" > {output.summary_report}
            # Create empty plot file
            python -c "import matplotlib.pyplot as plt; plt.figure(); plt.text(0.5, 0.5, 'No data to plot', ha='center', va='center'); plt.savefig('{output.analysis_plot}'); plt.close()"
        fi
        """

# Summary rule for complete EquiBind + Delta LinF9 pipeline
rule equibind_delta_linf9_complete:
    input:
        # Main Delta LinF9 results
        delta_results=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/delta_linf9_results.csv",
        ranked_results=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/ligands_ranked.csv",
        # Analysis outputs
        top_ligands=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/top_10_ligands.csv",
        analysis_plot=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/xgb_analysis.png",
        summary_report=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/analysis_summary.txt"
    output:
        final_report=f"benchmarks/experiment_{{experiment}}_epoch_{{epoch}}_mols_{{num_gen}}_bs_{{known_binding_site}}_pdbid_{{pdbid}}/final_pipeline_report.txt"
    params:
        experiment = "{experiment}",
        epoch = "{epoch}",
        num_gen = "{num_gen}",
        known_binding_site = "{known_binding_site}",
        pdbid = "{pdbid}",
        output_dir = lambda wildcards: f"benchmarks/experiment_{wildcards.experiment}_epoch_{wildcards.epoch}_mols_{wildcards.num_gen}_bs_{wildcards.known_binding_site}_pdbid_{wildcards.pdbid}"
    shell:
        """
        echo "EquiBind + Delta LinF9 Pipeline Complete!" > {output.final_report}
        echo "=======================================" >> {output.final_report}
        echo "Experiment: {params.experiment}" >> {output.final_report}
        echo "Epoch: {params.epoch}" >> {output.final_report}
        echo "Number of molecules: {params.num_gen}" >> {output.final_report}
        echo "Known binding site: {params.known_binding_site}" >> {output.final_report}
        echo "PDB ID: {params.pdbid}" >> {output.final_report}
        echo "Output directory: {params.output_dir}" >> {output.final_report}
        echo "" >> {output.final_report}
        echo "Generated Files:" >> {output.final_report}
        echo "- delta_linf9_results.csv: All XGB scoring results" >> {output.final_report}
        echo "- ligands_ranked.csv: Ligands ranked by XGB score (best first)" >> {output.final_report}
        echo "- top_10_ligands.csv: Top 10 best scoring ligands" >> {output.final_report}
        echo "- xgb_analysis.png: Visualization plots" >> {output.final_report}
        echo "- analysis_summary.txt: Statistical summary" >> {output.final_report}
        echo "" >> {output.final_report}
        echo "Top 3 ligands:" >> {output.final_report}
        head -4 {input.ranked_results} | tail -3 >> {output.final_report}
        """