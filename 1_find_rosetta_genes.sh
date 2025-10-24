#!/bin/bash

# Check if correct arguments are given
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 DIRECTORYNAME and run from desired directory"
    exit 1
fi

# Set directory name
DIRNAME=$1

# Create necessary directories
mkdir -p find_genes translate

# Translate sequences from nucleotide to protein
transeq -sequence "./pre_filtered_${DIRNAME}.fasta" -outseq "./translate/orfs_${DIRNAME}.fasta" -frame F

# Extract sequences containing "rosetta" in the header
awk '/^>/ {p=($0 ~ /rosetta/)} p' "./translate/orfs_${DIRNAME}.fasta" > "./translate/rosetta.fasta"

echo "Filtered sequences saved in ./translate/rosetta.fasta"
