# Snakefile
configfile: "config.yaml"

rule all:
    input:
        "results/final_output.txt"

rule preprocess:
    input:
        "data/raw_input.txt"
    output:
        "results/preprocessed.txt"
    shell:
        "cd external/preprocessing && python preprocess.py ../../{input} ../../{output}"

rule main_model:
    input:
        "results/preprocessed.txt"
    output:
        "results/model_output.txt"
    shell:
        "python your_main_model.py {input} {output}"

rule postprocess:
    input:
        "results/model_output.txt"
    output:
        "results/final_output.txt"
    shell:
        "cd external/postprocessing && python postprocess.py ../../{input} ../../{output}"