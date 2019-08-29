#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
    single_reads: File

    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: File
    lsu_tax: File
    ssu_otus: File
    lsu_otus: File
    rfam_models: File[]
    rfam_model_clans: File
    ssu_label: string
    lsu_label: string

    unite_db: {type: File, secondaryFiles: [.mscluster] }
    unite_tax: File
    unite_otu_file: File
    unite_label: string
    itsonedb: {type: File, secondaryFiles: [.mscluster] }
    itsonedb_tax: File
    itsonedb_otu_file: File
    itsonedb_label: string
    divide_sh: File

outputs:
  processed_nucleotide_reads:
    type: File
    outputSource: trim_and_reformat_reads/trimmed_and_reformatted_reads

  ncRNAs:
    type: File
    outputSource: classify/ncRNAs

  5s_fasta:
    type: File
    outputSource: classify/5S_fasta

  SSU_fasta:
    type: File
    outputSource: classify/SSU_fasta

  LSU_fasta:
    type: File
    outputSource: classify/LSU_fasta

  SSU_coords:
    type: File
    outputSource: classify/SSU_coords

  LSU_coords:
    type: File
    outputSource: classify/LSU_coords

  SSU_classifications:
    type: File
    outputSource: classify/SSU_classifications

  SSU_otu_tsv:
    type: File
    outputSource: classify/SSU_otu_tsv

  SSU_krona_image:
    type: File
    outputSource: classify/SSU_krona_image

  LSU_classifications:
    type: File
    outputSource: classify/LSU_classifications

  LSU_otu_tsv:
    type: File
    outputSource: classify/LSU_otu_tsv

  LSU_krona_image:
    type: File
    outputSource: classify/LSU_krona_image

  ssu_hdf5_classifications:
    type: File
    outputSource: classify/ssu_hdf5_classifications

  ssu_json_classifications:
    type: File
    outputSource: classify/ssu_json_classifications

  lsu_hdf5_classifications:
    type: File
    outputSource: classify/lsu_hdf5_classifications

  lsu_json_classifications:
    type: File
    outputSource: classify/lsu_json_classifications

  proportion_SU:
    type: File
    outputSource: ITS/proportion_SU

  masked_sequences:
    type: File
    outputSource: ITS/masked_sequences

  unite_classifications:
    type: File
    outputSource: ITS/unite_classifications

  unite_otu_tsv:
    type: File
    outputSource: ITS/unite_otu_tsv

  unite_krona_image:
    type: File
    outputSource: ITS/unite_krona_image

  itsonedb_classifications:
    type: File
    outputSource: ITS/itsonedb_classifications

  itsonedb_otu_tsv:
    type: File
    outputSource: ITS/itsonedb_otu_tsv

  itsonedb_krona_image:
    type: File
    outputSource: ITS/itsonedb_krona_image

  unite_hdf5_classifications:
    type: File
    outputSource: ITS/unite_hdf5_classifications

  unite_json_classifications:
    type: File
    outputSource: ITS/unite_json_classifications

  itsonedb_hdf5_classifications:
    type: File
    outputSource: ITS/itsonedb_hdf5_classifications

  itsonedb_json_classifications:
    type: File
    outputSource: ITS/itsonedb_json_classifications

steps:

  trim_and_reformat_reads:
    run: trim_and_reformat_reads.cwl
    in:
      reads: single_reads
    out:  [ trimmed_and_reformatted_reads ]

  qc_stats:
    run: ../tools/qc-stats/qc-stats.cwl
    in:
        QCed_reads: trim_and_reformat_reads/trimmed_and_reformatted_reads
    out:
      - summary_out
      - seq_length_pcbin
      - seq_length_bin
      - seq_length_out
      - nucleotide_distribution_out
      - gc_sum_pcbin
      - gc_sum_bin
      - gc_sum_out

  classify:
    run: rna_prediction.cwl
    in:
       input_sequences: trim_and_reformat_reads/trimmed_and_reformatted_reads
       silva_ssu_database: ssu_db
       silva_lsu_database: lsu_db
       silva_ssu_taxonomy: ssu_tax
       silva_lsu_taxonomy: lsu_tax
       silva_ssu_otus: ssu_otus
       silva_lsu_otus: lsu_otus
       ncRNA_ribosomal_models: rfam_models
       ncRNA_ribosomal_model_clans: rfam_model_clans
       otu_ssu_label: ssu_label
       otu_lsu_label: lsu_label
    out:
      - ncRNAs
      - 5S_fasta
      - SSU_fasta
      - LSU_fasta
      - SSU_coords
      - LSU_coords
      - SSU_classifications
      - SSU_otu_tsv
      - SSU_krona_image
      - LSU_classifications
      - LSU_otu_tsv
      - LSU_krona_image
      - ssu_hdf5_classifications
      - ssu_json_classifications
      - lsu_hdf5_classifications
      - lsu_json_classifications
  ITS:
    run: ITS-wf.cwl
    in:
        qc_stats_summary: qc_stats/summary_out
        query_sequences: trim_and_reformat_reads/trimmed_and_reformatted_reads
        LSU_coordinates: classify/LSU_coords
        SSU_coordinates: classify/SSU_coords
        unite_database: unite_db
        unite_taxonomy: unite_tax
        unite_otus: unite_otu_file
        itsone_database: itsonedb
        itsone_taxonomy: itsonedb_tax
        itsone_otus: itsonedb_otu_file
        divide_script: divide_sh
        otu_unite_label: unite_label
        otu_itsone_label: itsonedb_label
    out:
      - proportion_SU
      - masked_sequences
      - unite_classifications
      - unite_otu_tsv
      - unite_krona_image
      - itsonedb_classifications
      - itsonedb_otu_tsv
      - itsonedb_krona_image
      - unite_hdf5_classifications
      - unite_json_classifications
      - itsonedb_hdf5_classifications
      - itsonedb_json_classifications