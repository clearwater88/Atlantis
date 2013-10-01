#!/bin/bash

# Request an hour of runtime:
#SBATCH --time=6:00:00

# Default resources are 1 core with 2.8GB of memory.

# Use more memory (4GB):
#SBATCH --mem=4G

# Specify a job name:
#SBATCH -J MyMatlabJob

# Specify an output file
#SBATCH -o MyMatlabJob-%j.out
#SBATCH -e MyMatlabJob-%j.out

#SARRAY --range=50,75,100

# Run a matlab script called 'foo.m' in the same directory as this batch script.
#matlab -r "foo; exit"
funct="mainGen"

matlab -nosplash -r "$funct([$SLURM_ARRAYID,$SLURM_ARRAYID],0.07,1,1,[],0,2); exit"	