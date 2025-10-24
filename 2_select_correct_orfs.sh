#!/bin/bash

# Check if correct arguments are given
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 DIRECTORYNAME and run from the desired directory"
    exit 1
fi

# Set directory name
DIRNAME=$1

# Check if BLAST+ tools and FSA are installed
for cmd in makeblastdb blastp fsa; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd not found. Please install it before running this script."
        exit 1
    fi
done

echo "Processing directory: $DIRNAME"

# Create find_genes directory if it doesn't exist
mkdir -p find_genes
cd find_genes || { echo "Error: Cannot enter find_genes directory"; exit 1; }

# Create BLAST database
echo "Creating BLAST database..."
makeblastdb -in "../translate/orfs_${DIRNAME}.fasta" -dbtype prot -out "orfs_${DIRNAME}_db"

# Run BLASTP search
echo "Running BLASTP search..."
blastp -query "../translate/rosetta.fasta" -db "orfs_${DIRNAME}_db" -out "${DIRNAME}_results.txt" -evalue 1e-5 -outfmt 6

# Extract sequence IDs from BLAST results
echo "Extracting sequence IDs from BLAST results..."
cut -f2 "${DIRNAME}_results.txt" > sequences_with_correct_orf.txt

# Extract full sequences for matching headers and handle both parts (species and identifier)
echo "Extracting full sequences..."
awk 'NR==FNR {headers[$1]; next} /^>/ {header=substr($0,2); p=0; for(h in headers) if(index(header,h) > 0) p=1} p' sequences_with_correct_orf.txt "../translate/orfs_${DIRNAME}.fasta" > "../selected_${DIRNAME}.fst"

# Perform multiple sequence alignment with FSA
echo "Aligning selected sequences..."
fsa --fast "../selected_${DIRNAME}.fst" > "../aligned_selected_${DIRNAME}.fst"

echo "Alignment saved in ../aligned_selected_${DIRNAME}.fst"
