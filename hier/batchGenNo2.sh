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

#SARRAY --range=5,10,15,20,25,30,35,40,45,50

# Run a matlab script called 'foo.m' in the same directory as this batch script.
#matlab -r "foo; exit"
funct="mainGen"

matlab -nosplash -r "$funct([75,75],$SLURM_ARRAYID,1,[],1,2); exit"	
