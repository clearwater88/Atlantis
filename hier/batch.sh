#!/bin/bash

# Request an hour of runtime:
#SBATCH --time=3:00:00

# Default resources are 1 core with 2.8GB of memory.

# Use more memory (4GB):
#SBATCH --mem=4G

# Specify a job name:
#SBATCH -J MyMatlabJob

# Specify an output file
#SBATCH -o MyMatlabJob-%j.out
#SBATCH -e MyMatlabJob-%j.out

#SARRAY --range=50,60,70,80,90,100

# Run a matlab script called 'foo.m' in the same directory as this batch script.
#matlab -r "foo; exit"
funct="mainBP"

matlab -nosplash -r "$funct(8,0.1,1,$SLURM_ARRAYID,[],0,2); exit"	
