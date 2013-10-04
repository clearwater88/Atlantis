#!/bin/bash

# Request an hour of runtime:
#SBATCH --time=24:00:00

# Default resources are 1 core with 2.8GB of memory.

# Use more memory (4GB):
#SBATCH --mem=4G

# Specify a job name:
#SBATCH -J MyMatlabJob

# Specify an output file
#SBATCH -o MyMatlabJob-%j.out
#SBATCH -e MyMatlabJob-%j.out

#SARRAY --range=1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31

# Run a matlab script called 'foo.m' in the same directory as this batch script.
#matlab -r "foo; exit"
funct="mainGen"

matlab -nosplash -r "$funct([50,50],$SLURM_ARRAYID,1,[],0,2); exit"	
