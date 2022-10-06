#!/bin/bash
#SBATCH --account=PAS2136
#SBATCH --job-name=MinnowTraits
#SBATCH --time=03:00:00
# Runs the Minnow Traits snakemake workflow 

# Usage:
# sbatch run-workflow.sh

# Setup Snakemake/sbatch to use same account as this job
export SBATCH_ACCOUNT=$SLURM_JOB_ACCOUNT

# Configure Snakemake to run up to 20 jobs at once
NUM_JOBS=20

module load miniconda3
source activate snakemake
module load R/4.2.1-gnu11.2
snakemake \
    --jobs $NUM_JOBS \
    --profile slurm/ \
    --use-singularity \
    --singularity-args "--bind $HOME/.dataverse" \
    "$@"
