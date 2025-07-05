# Common functions and rules
import os
import pandas as pd

def get_sample_path(wildcards):
    """Get the path for a given sample."""
    return samples.loc[wildcards.sample, "path"]

def get_sample_condition(wildcards):
    """Get the condition for a given sample."""
    return samples.loc[wildcards.sample, "condition"]

# Common rule for creating directories
rule create_directories:
    output:
        directory("results/logs"),
        directory("results/benchmarks"),
        directory("results/plots"),
        directory("results/tables")
    shell:
        """
        mkdir -p {output}
        """