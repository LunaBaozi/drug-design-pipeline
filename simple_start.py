import subprocess
import sys

def main():
    print("Available proteins:")
    # Read from samples.tsv and display options
    with open("config/samples.tsv", "r") as f:
        lines = f.readlines()[1:]  # Skip header
        for i, line in enumerate(lines):
            sample = line.split("\t")[0]
            print(f"{i+1}. {sample}")
    
    choice = input("Select protein (enter number): ")
    try:
        choice_idx = int(choice) - 1
        sample = lines[choice_idx].split("\t")[0]
        
        # Run snakemake for selected protein
        cmd = f"snakemake {sample}_epoch_33_mols_100_bs_True_pdbid_4af3.mol_dict"
        subprocess.run(cmd, shell=True)
        
    except (ValueError, IndexError):
        print("Invalid selection")
        sys.exit(1)

if __name__ == "__main__":
    main()