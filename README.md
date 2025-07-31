# Drug Design Pipeline

A comprehensive Snakemake-based pipeline for structure-based drug design, integrating state-of-the-art machine learning models and molecular docking tools.

## Overview

This pipeline combines multiple cutting-edge approaches for drug discovery:
- **GraphBP**: Graph-based binding prediction using geometric deep learning
- **DiffDock**: Diffusion-based molecular docking 
- **EquiBind**: SE(3)-equivariant neural networks for protein-ligand binding
- **Delta LinF9**: XGBoost-based protein-ligand scoring
- **Vina/Hope toolboxes**: Molecular docking and filtering utilities

## Features

- Automated protein-ligand binding prediction
- Multiple docking approaches (diffusion-based, equivariant, traditional)
- Post-hoc filtering and scoring of generated molecules
- Comprehensive evaluation metrics and analysis tools
- GPU-accelerated deep learning models
- Containerized environments for reproducibility

## Installation

### 1. Clone the Repository

```bash
git clone --recurse-submodules https://github.com/LunaBaozi/drug-design-pipeline.git
cd drug-design-pipeline
```

### 2. Setup Environment

Install Conda/Mamba if not already available:
```bash
# Install Mamba (recommended for faster dependency resolution)
conda install -n base -c conda-forge mamba
```

Create the main pipeline environment:
```bash
# Option 1: Use the provided environment file
mamba env create -f environment.yaml

# Option 2: Use GraphBP environment setup (recommended)
cd workflow/envs/graphbp
bash install_environment.sh
```

### 3. Activate Environment

```bash
conda activate graphbp_complete_env  # or your environment name
```

### 4. Verify Installation

Test PyTorch and CUDA setup:
```bash
python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')"
```

Test PyTorch Geometric:
```bash
python -c "import torch_geometric; print(f'PyTorch Geometric version: {torch_geometric.__version__}'); import torch_scatter; import torch_sparse; print('torch_scatter and torch_sparse imported successfully')"
```

## Quick Start

### 1. Configure Pipeline

Edit the configuration files in the [`config/`](config/) directory:
```bash
# Main pipeline configuration
vim config/config.yaml

# Update paths in load_config_paths.py if needed
python load_config_paths.py
```

### 2. Prepare Input Data

Place your input files in the [`data/`](data/) directory:
- **Protein structures**: PDB format in `data/proteins/`
- **Ligand libraries**: SDF/MOL2 format in `data/ligands/`
- **Binding sites**: Coordinate files in `data/pockets/`

### 3. Run Pipeline

Execute the complete pipeline:
```bash
# Dry run to check workflow
snakemake -n

# Run with 4 cores
snakemake --cores 4

# Run with specific environment
snakemake --use-conda --cores 4
```

### 4. Monitor Progress

Check pipeline status:
```bash
# View workflow graph
snakemake --dag | dot -Tpng > workflow.png

# Check log files
tail -f .snakemake/log/*.log
```

## Pipeline Components

### Core Models

- **[GraphBP](external/graphbp/)**: Graph neural networks for binding prediction
- **[DiffDock](external/diffdock/)**: Diffusion models for molecular docking  
- **[EquiBind](external/equibind/)**: Equivariant networks for binding pose prediction
- **[Delta LinF9](external/deltalinf9/)**: Machine learning scoring functions

### Utilities

- **[Vina-box](external/vina-box/)**: AutoDock Vina integration
- **[Hope-box](external/hope-box/)**: Post-hoc molecule filtering

### Analysis Scripts

- [`analyze_structures.py`](analyze_structures.py): Structure analysis and validation
- [`compare_descriptors.py`](compare_descriptors.py): Molecular descriptor comparison
- [`test_structure_comparison.py`](test_structure_comparison.py): Structure-based evaluation

## Usage Examples

### Example 1: Single Protein-Ligand Docking

```bash
# Configure for single complex
echo "protein: data/proteins/1abc.pdb" > config/single_run.yaml
echo "ligand: data/ligands/compound1.sdf" >> config/single_run.yaml

# Run specific rule
snakemake dock_single --config configfile=config/single_run.yaml
```

### Example 2: High-Throughput Virtual Screening

```bash
# Configure for multiple ligands
snakemake virtual_screening --cores 8 --config ligand_library=data/ligands/
```

### Example 3: Model Comparison

```bash
# Compare different docking approaches
snakemake compare_models --config methods="[diffdock,equibind,vina]"
```

## Output Structure

Results are organized in the [`results/`](results/) directory:

```
results/
├── docking/          # Docking poses and scores
├── predictions/      # Binding affinity predictions  
├── analysis/         # Comparative analysis
├── figures/          # Generated plots and visualizations
└── benchmarks/       # Performance benchmarks
```

## Configuration

### Main Config File

Edit [`config/config.yaml`](config/config.yaml) to customize:
- Input/output paths
- Model parameters
- Computational resources
- Analysis settings

### Environment Variables

Key paths are managed in [`load_config_paths.py`](load_config_paths.py):
- Model checkpoint locations
- External software paths
- Data directory structure

## Troubleshooting

### Common Issues

1. **CUDA/GPU Issues**:
   ```bash
   # Check GPU availability
   nvidia-smi
   
   # Verify PyTorch CUDA
   python -c "import torch; print(torch.cuda.is_available())"
   ```

2. **Environment Conflicts**:
   ```bash
   # Clean and recreate environment
   conda env remove -n graphbp_complete_env
   cd workflow/envs/graphbp
   bash install_environment.sh
   ```

3. **Missing Dependencies**:
   ```bash
   # Install additional packages
   conda activate graphbp_complete_env
   pip install -r requirements.txt
   ```

### Debug Mode

Run with verbose output:
```bash
snakemake --verbose --debug-dag
```

Check specific rule execution:
```bash
snakemake target_rule --forcerun --verbose
```

## Development

### Adding New Models

1. Add model code to [`external/`](external/)
2. Create environment file in [`workflow/envs/`](workflow/envs/)
3. Add rules to [`Snakefile`](Snakefile)
4. Update configuration schema

### Testing

Run test suite:
```bash
# Structure validation tests
python test_structure_validation/

# Conversion tests  
python test_conversion.py

# Original functionality tests
python test_original.py
```

## Citation

If you use this pipeline in your research, please cite the relevant papers:

- **GraphBP**: [AIRS Repository](external/graphbp/)
- **DiffDock**: [ICLR 2024](external/diffdock/README.md)
- **EquiBind**: [Original Paper](external/equibind/README.md)

## License

This project is licensed under GPL-3.0. See individual model repositories for their specific licenses.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

- Documentation: [workflow/README.md](workflow/)
- Issues: GitHub Issues
- Discussions: GitHub Discussions
- Contact: [maintainer@email.com]

---

**Note**: This pipeline requires significant computational resources. GPU acceleration is recommended for optimal performance.