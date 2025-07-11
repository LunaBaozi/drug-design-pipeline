#!/usr/bin/env python3
import os
import yaml
from pathlib import Path

def setup_pipeline():
    """Interactive setup for new users"""
    print("Drug Design Pipeline Setup")
    print("=" * 40)
    
    # Detect available modules
    external_dir = Path("external")
    available_modules = []
    
    if (external_dir / "graphbp").exists():
        available_modules.append("graphbp")
        print("GraphBP detected")
    if (external_dir / "hope-box").exists():
        available_modules.append("hope_box")
        print("HOPE-Box detected")
    if (external_dir / "vina").exists():
        available_modules.append("vina")
        print("Vina detected")
    
    if not available_modules:
        print("No modules detected in external/ directory")
        print("Make sure to clone the required submodules first")
        return
    
    print(f"\nDetected modules: {', '.join(available_modules)}")
    
    # Generate config based on detected modules
    config = generate_config_template(available_modules)
    
    # Create config directory if it doesn't exist
    Path("config").mkdir(exist_ok=True)
    
    # Write config file
    with open("config/config.yaml", "w") as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)
    
    print("\nConfiguration file created at config/config.yaml")
    print("Please review and customize the parameters as needed")
    print("\nReady to run: snakemake --cores 1")

def generate_config_template(modules):
    """Generate config template based on available modules"""
    config = {
        'project_paths': {
            'base_dir': '.',
            'external_dir': 'external',
            'results_dir': 'results',
            'data_dir': 'data'
        },
        'modules': {},
        'parameters': {
            'epoch': 99,
            'num_gen': 1,
            'known_binding_site': False,
            'aurora': 'B',
            'pdbid': '4af3'
        },
        'resources': {}
    }
    
    # Add module-specific configurations
    if 'graphbp' in modules:
        config['modules']['graphbp'] = {
            'path': 'external/graphbp/OpenMI/GraphBP/GraphBP',
            'trained_model_subdir': 'trained_model_reduced_dataset_100_epochs',
            'output_pattern': 'gen_mols_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}/sdf'
        }
        config['resources']['graphbp'] = {
            'mem_mb': 8000,
            'threads': 4
        }
    
    if 'hope_box' in modules:
        config['modules']['hope_box'] = {
            'path': 'external/hope-box',
            'scripts_dir': 'scripts',
            'data_dir': 'data',
            'models_dir': 'models',
            'results_subdir': 'results_epoch_{epoch}_mols_{num_gen}_bs_{known_binding_site}_pdbid_{pdbid}'
        }
        config['resources']['hope_box'] = {
            'mem_mb': 16000,
            'threads': 8
        }
    
    if 'vina' in modules:
        config['modules']['vina'] = {
            'path': 'external/vina'
        }
        config['resources']['vina'] = {
            'mem_mb': 8000,
            'threads': 4
        }
    
    return config

if __name__ == "__main__":
    setup_pipeline()