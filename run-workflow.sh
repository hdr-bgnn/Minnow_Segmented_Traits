#!/bin/bash
#SBATCH --account=PAS2136
#SBATCH --job-name=MinnowTraits
# Runs the Minnow Traits snakemake workflow 

# Usage:
# sbatch run-workflow.sh
module load miniconda3
source activate snakemake
module load R/4.2.1-gnu11.2
snakemake --cores 1
