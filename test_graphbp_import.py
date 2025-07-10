#!/usr/bin/env python3
"""
Test script to verify GraphBP imports work correctly
"""

import sys
import os

# Add the GraphBP directory to the path
graphbp_dir = os.path.join(os.path.dirname(__file__), 'external', 'graphbp', 'OpenMI', 'GraphBP', 'GraphBP')
sys.path.insert(0, graphbp_dir)

def test_imports():
    print("Testing GraphBP imports...")
    
    # Test 1: Basic imports
    try:
        import torch
        import torch.nn.functional as F
        print("✓ PyTorch imports successful")
    except ImportError as e:
        print(f"✗ PyTorch import failed: {e}")
        return False
    
    # Test 2: PyTorch Geometric imports
    try:
        import torch_geometric
        print("✓ PyTorch Geometric imports successful")
    except ImportError as e:
        print(f"✗ PyTorch Geometric import failed: {e}")
        return False
    
    # Test 3: Net utils import
    try:
        from model.net_utils import ST_Net_Exp
        print("✓ net_utils import successful")
    except ImportError as e:
        print(f"✗ net_utils import failed: {e}")
        return False
    
    # Test 4: GraphBP model import
    try:
        from model import GraphBP
        print("✓ GraphBP model import successful")
    except ImportError as e:
        print(f"✗ GraphBP model import failed: {e}")
        return False
    
    # Test 5: Runner import
    try:
        from runner import Runner
        print("✓ Runner import successful")
    except ImportError as e:
        print(f"✗ Runner import failed: {e}")
        return False
    
    print("\n🎉 All imports successful!")
    return True

if __name__ == "__main__":
    success = test_imports()
    sys.exit(0 if success else 1)
