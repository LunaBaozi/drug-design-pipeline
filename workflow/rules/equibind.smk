# EquiBind protein-ligand binding prediction
rule prepare_equibind_input:
    input:
        molecules="results/hope_box/{sample}_processed.sdf",
        protein=lambda wildcards: samples.loc[wildcards.sample, "protein_path"]
    output:
        prepared="results/equibind/{sample}_prepared.pkl"
    conda:
        "../envs/equibind.yaml"
    log:
        "results/logs/equibind/{sample}_prepare.log"
    shell:
        """
        cd external/equibind && \
        python prepare_input.py \
            --molecules {input.molecules} \
            --protein {input.protein} \
            --output {output.prepared} \
            2> {log}
        """

rule run_equibind:
    input:
        prepared="results/equibind/{sample}_prepared.pkl"
    output:
        binding_poses="results/equibind/{sample}_poses.sdf",
        binding_scores="results/equibind/{sample}_binding_scores.csv"
    conda:
        "../envs/equibind.yaml"
    log:
        "results/logs/equibind/{sample}_binding.log"
    shell:
        """
        cd external/equibind && \
        python run_equibind.py \
            --input {input.prepared} \
            --output_poses {output.binding_poses} \
            --output_scores {output.binding_scores} \
            2> {log}
        """