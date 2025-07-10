import subprocess
import sys
import os
from pathlib import Path

# # Set up environment as per workflow/envs/graphbp/ENVIRONMENT_SETUP.md
# env_setup_script = "workflow/envs/graphbp/setup_env.sh"
# if os.path.exists(env_setup_script):
#     print("Setting up environment...")
#     subprocess.run(f"bash {env_setup_script}", shell=True, check=True)
# else:
#     print(f"Environment setup script not found: {env_setup_script}")

def check_conda_installed():
    """Check if conda is installed and available."""
    try:
        subprocess.run(["conda", "--version"], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def setup_conda_environment():
    """Set up the conda environment for GraphBP using the installation script."""
    if not check_conda_installed():
        print("ERROR: Conda is not installed or not in PATH.")
        print("Please install Miniconda or Anaconda first.")
        return False
    
    # Read and display setup instructions
    setup_file = Path("workflow/envs/graphbp/ENVIRONMENT_SETUP.md")
    if setup_file.exists():
        print("Found environment setup instructions:")
        print("=" * 50)
        with open(setup_file, 'r') as f:
            print(f.read())
        print("=" * 50)
    else:
        print(f"Environment setup file not found: {setup_file}")
    
    # Check if environment already exists
    try:
        result = subprocess.run(["conda", "env", "list"], capture_output=True, text=True, check=True)
        if "graphbp_complete2" in result.stdout:
            print("GraphBP conda environment (graphbp_complete2) already exists.")
            return True
    except subprocess.CalledProcessError:
        pass
    
    # Path to the installation script
    install_script = Path("workflow/envs/graphbp/install_graphbp_env.sh")
    
    if not install_script.exists():
        print(f"Installation script not found: {install_script}")
        print("Please ensure the script exists before running.")
        return False
    
    # 1. Make the script executable
    print("Making installation script executable...")
    try:
        subprocess.run(["chmod", "+x", str(install_script)], check=True)
        print("Installation script is now executable")
    except subprocess.CalledProcessError as e:
        print(f"Failed to make script executable: {e}")
        return False
    
    # 2. Run the installation script
    print("Running GraphBP environment installation script...")
    try:
        # Change to the script directory and run it
        script_dir = install_script.parent
        result = subprocess.run(
            ["./install_graphbp_env.sh"], 
            cwd=script_dir,
            check=True,
            capture_output=False  # Show output in real-time
        )
        print("GraphBP environment installation completed successfully!")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"Installation script failed with error: {e}")
        
        # 3. Try to fix PyTorch Geometric issues if they occurred
        fix_script = Path("workflow/envs/graphbp/fix_pytorch_geometric.sh")
        if fix_script.exists():
            print("Attempting to fix PyTorch Geometric compatibility issues...")
            try:
                # Make fix script executable
                subprocess.run(["chmod", "+x", str(fix_script)], check=True)
                
                # Run the fix script
                subprocess.run(
                    ["./fix_pytorch_geometric.sh"],
                    cwd=fix_script.parent,
                    check=True,
                    capture_output=False
                )
                print("PyTorch Geometric fix applied successfully!")
                
                # Try running the installation script again
                print("Retrying installation after applying fix...")
                subprocess.run(
                    ["./install_graphbp_env.sh"], 
                    cwd=script_dir,
                    check=True,
                    capture_output=False
                )
                print("GraphBP environment installation completed after fix!")
                return True
                
            except subprocess.CalledProcessError as e2:
                print(f"PyTorch Geometric fix also failed: {e2}")
                print("Please check the installation manually.")
                return False
        else:
            print(f"Fix script not found: {fix_script}")
            print("Manual intervention may be required.")
            return False

def select_protein():
    """Let user select protein and run the pipeline."""
    samples_file = "config/samples.tsv"
    
    if not os.path.exists(samples_file):
        print(f"Samples file not found: {samples_file}")
        print("Creating default samples file...")
        
        # Create default samples file
        os.makedirs("config", exist_ok=True)
        with open(samples_file, 'w') as f:
            f.write("sample\tprotein_path\tpdbid\n")
            f.write("4af3\tdata/proteins/4af3.pdb\t4af3\n")
            f.write("4cfg\tdata/proteins/4cfg.pdb\t4cfg\n")
    
    print("Available proteins:")
    with open(samples_file, "r") as f:
        lines = f.readlines()[1:]  # Skip header
        for i, line in enumerate(lines):
            pdbid = line.split("\t")[2].strip()
            print(f"{i+1}. {pdbid}")
    
    choice = input("Select protein (enter number): ")
    try:
        choice_idx = int(choice) - 1
        pdbid = lines[choice_idx].split("\t")[2].strip()
        return pdbid
    except (ValueError, IndexError):
        print("Invalid selection")
        sys.exit(1)

def run_snakemake_pipeline():
    """Run the Snakemake pipeline with conda environments."""
    print("Running Snakemake pipeline...")
    
    # Check if snakemake is installed
    try:
        subprocess.run(["snakemake", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Snakemake not found. Installing...")
        try:
            subprocess.run(["conda", "install", "-n", "base", "snakemake", "-c", "bioconda", "-y"], check=True)
        except subprocess.CalledProcessError:
            print("Failed to install snakemake. Please install manually.")
            return False
    
    # Run snakemake with conda environments
    try:
        cmd = [
            "snakemake", 
            "--use-conda", 
            "--cores", "1",
            "--verbose"
        ]
        
        subprocess.run(cmd, check=True)
        print("Pipeline completed successfully!")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"Pipeline failed: {e}")
        print("You can run the pipeline manually with:")
        print("snakemake --use-conda --cores 1")
        return False

def main():
    print("=== Drug Design Pipeline Setup ===\n")
    
    # Setup conda environment using the installation script
    if not setup_conda_environment():
        print("Failed to setup conda environment. Exiting.")
        sys.exit(1)
    
    # Select protein
    selected_protein = select_protein()
    print(f"Selected protein: {selected_protein}")
    
    # Run pipeline
    success = run_snakemake_pipeline()
    
    if success:
        print("\n🎉 Pipeline setup and execution completed successfully!")
    else:
        print("\n⚠️  Pipeline setup completed, but execution failed.")
        print("You may need to run the pipeline manually.")

if __name__ == "__main__":
    main()