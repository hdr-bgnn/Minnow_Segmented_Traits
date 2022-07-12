#!/bin/bash
#SBATCH --account=PAS2136
#SBATCH --job-name=minnowTraits
#SBATCH --time=02:30:00
#
# sbatch run-pipeline.sh [NUMJOBS]
# - NUMJOBS - Number of parallel jobs to run at once

# Stop if a command fails (non-zero exit status)
set -e

# The number of jobs snakemake should run at once
NUMJOBS=10
# Use sbatch to run jobs for each step
SNAKEMAKE_PROFILE=slurm/

# Setup sbatch to use the same account for all jobs

# Activate Snakemake environment
module load miniconda3/4.10.3-py37
# Activate using source per OSC instructions
source activate snakemake

# Run pipeline using Snakemake
snakemake \
    --jobs $NUMJOBS \
    --profile $SNAKEMAKE_PROFILE \
    --use-singularity

snakemake --report report.html
