# My Snakemake Pipeline

Brief description of what your pipeline does.

## Installation

1. Clone the repository with submodules:
   ```bash
   git clone --recurse-submodules https://github.com/yourusername/my-pipeline.git
   cd my-pipeline

conda activate graphbp_complete2 && python -c "import torch; print(f'PyTorch version: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')"

conda activate graphbp_complete2 && python -c "import torch_geometric; print(f'PyTorch Geometric version: {torch_geometric.__version__}'); import torch_scatter; import torch_sparse; print('torch_scatter and torch_sparse imported successfully')"
