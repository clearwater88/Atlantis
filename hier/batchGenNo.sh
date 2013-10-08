#!/bin/bash

# Request an hour of runtime:
#SBATCH --time=24:00:00

# Default resources are 1 core with 2.8GB of memory.

# Use more memory (4GB):
#SBATCH --mem=8G

# Specify a job name:
#SBATCH -J MyMatlabJob

# Specify an output file
#SBATCH -o job-%j.out
#SBATCH -e Job-%j.out

#SARRAY --range=1,4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49

# Run a matlab script called 'foo.m' in the same directory as this batch script.
#matlab -r "foo; exit"
funct="mainGen"

matlab -nosplash -r "$funct([50,50],$SLURM_ARRAYID,1,[],1,2,1); exit"	
