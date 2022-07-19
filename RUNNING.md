# Running minnowTraits pipeline

## Requirements
- [Snakemake](https://snakemake.readthedocs.io/) 6.1.1+ 
- [Singularity/Apptainer](https://apptainer.org/)
- [Slurm](https://slurm.schedmd.com/) (optional)

## Setup
Before running the workflow a conda environment named "snakemake" needs to be created.

On the OSC cluster run the following commands to created the conda environment:
```
module load miniconda3/4.10.3-py37
conda create -n snakemake -c bioconda -c conda-forge snakemake -y
```
See [snakemake install docs](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) for more installation options.

## Running

On the OSC cluster the pipeline can be run with Slurm by running:
```
sbatch run-pipeline.sh
```
If using a different account the `--account` parameter will need to be adjusted in run-pipeline.sh and config/config.yaml.

Assuming snakemake is installed you can run without Slurm and 1 job by running:
```
snakemake --jobs 1 --use-singularity
```



