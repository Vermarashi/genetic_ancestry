#!/bin/bash

# Input files
VCF_FILE="concat_subset_ref_all.vcf"   # Replace with the path to your 1000 Genomes VCF file
SAMPLE_FILE="sample_id_ref.txt"      # File containing sample IDs of interest (one per line)
OUTPUT_FILE="extracted_samples.vcf.gz"
MISSING_SAMPLES_LOG="missing_samples.log"

# Check if input files exist
if [[ ! -f "$VCF_FILE" ]]; then
    echo "Error: VCF file '$VCF_FILE' not found!"
    exit 1
fi

if [[ ! -f "$SAMPLE_FILE" ]]; then
    echo "Error: Sample ID file '$SAMPLE_FILE' not found!"
    exit 1
fi

# Clear any previous logs
> "$MISSING_SAMPLES_LOG"

# Extract sample IDs from the sample_id_ref.txt and process each sample
SAMPLES=""
while read -r SAMPLE; do
    if bcftools view -h "$VCF_FILE" | grep -q "$SAMPLE"; then
        echo "Sample $SAMPLE found in VCF. Adding to list..."
        SAMPLES="${SAMPLES},${SAMPLE}"
    else
        echo "Sample $SAMPLE not found in VCF. Logging missing sample."
        echo "$SAMPLE" >> "$MISSING_SAMPLES_LOG"
    fi
done < <(tail -n +2 "$SAMPLE_FILE")  # Ignore header in the sample file

# Remove leading comma from sample list
SAMPLES=${SAMPLES#,}

# Extract all valid samples in one go
if [[ -n "$SAMPLES" ]]; then
    bcftools view -s "$SAMPLES" "$VCF_FILE" -Oz -o "$OUTPUT_FILE"
    bcftools index "$OUTPUT_FILE"
    echo "Samples extracted and saved in $OUTPUT_FILE."
else
    echo "No valid samples found."
fi

echo "Missing samples (if any) are logged in $MISSING_SAMPLES_LOG."
