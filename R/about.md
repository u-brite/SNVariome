## Hackin' Omics 2022

Hackin' Omics 2022 is an biohackathon that was organized by UAB's Informatics Institute in collaboration with the Center for Computational Genomics and Data Science. 

Our goals was to create a shiny app that integrates protein-protein interactions, clinical variants, and protein structure to enhance the interactome.

## What is SNVariome

SNVariome (Single Nucleotide Variant interactome) is a tool that seeks to integrate protein structure, protein-protein interactions, drug-gene interaction data, variant data (using ClinVar, GOF/LOF data), and phenotype data (HPO terms) to develop a comprehensive interactome of clinical variants. We will utilize the SigCom LINCS API and integrate a publicly available dataset that has already examined GOF/LOF impacts on protein structure (pmcid: PMC9259657). Our first test case will be a list of genes/variants associated with breast cancer which should validate and expand the findings of DOI: 10.1126/science.abf3066.

## Project Significance

Most existing PPI databases only curate a binary interactome. However, integrating protein structure is critical in understanding complex human diseases because variants (GOF/LOF) have significant impacts on protein structure. Thus, having a more complete interactome will aid in the identification of pathogenic variants.

## Usage

This tool can be used to view clinical variants that are gain of function or loss of function with additional measures such as the impact these variants have on protein structure. Input a gene or variant to generate data and plots.
