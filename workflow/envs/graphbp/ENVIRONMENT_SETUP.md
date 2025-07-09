# Environment Installation Guide

This guide provides two foolproof methods to install all required dependencies for the GraphBP project.

## Method 1: Using the Installation Script (Recommended)

This method installs packages in the correct order to avoid conflicts:

```bash
# Make the script executable
chmod +x install_graphbp_env.sh

# Run the installation script
./install_graphbp_env.sh
```

The script will:
1. Create a new environment called `graphbp_complete`
2. Install packages in the optimal order
3. Handle CUDA detection automatically
4. Verify all installations

## Method 2: Using environment.yml

If you prefer using conda's environment file:

```bash
# For CUDA systems
conda env create -f graphbp_conda_env.yml

# For CPU-only systems, first edit environment_complete.yml to remove the pytorch-cuda line
conda env create -f graphbp_conda_env.yml
```

## Activation

After installation, activate the environment:

```bash
conda activate graphbp_complete
```

## Package List

The environment includes:
- **Molecular modeling**: rdkit, openbabel
- **Scientific computing**: numpy, pandas, matplotlib, scikit-learn
- **Machine learning**: pytorch, pytorch-geometric, torch-scatter, torch-sparse, torch-spline-conv
- **Bioinformatics**: biopython
- **Graph processing**: networkx
- **Workflow**: snakemake, mamba

## Troubleshooting

If you encounter conflicts:

1. **Remove existing environment**: `conda env remove -n graphbp_complete`
2. **Clear conda cache**: `conda clean --all`
3. **Try the script method**: It handles dependencies more carefully
4. **Check CUDA compatibility**: Ensure your CUDA version matches PyTorch requirements
5. **Fix PyTorch Geometric compatibility**: run `./fix_pytorch_geometric.sh` if 
you encounter compatibility issues due to PyTorch Geometric


## Notes

- The script automatically detects CUDA and installs appropriate PyTorch version
- RDKit and OpenBabel must be installed via conda (not pip)
- PyTorch Geometric ecosystem packages are installed via pip for better compatibility
- Installation order matters to avoid conflicts
