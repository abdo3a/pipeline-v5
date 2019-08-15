#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool


label: "Biosequence analysis using profile hidden Markov models"

requirements:
  DockerRequirement:
    dockerPull: hmmscan_assembly:latest
  InlineJavascriptRequirement: {}

baseCommand: ["hmmscan"]

arguments:
  - prefix: --domtblout
    valueFrom: $(inputs.seqfile.nameroot)_hmmscan.tbl
    position: 2

inputs:

  omit_alignment:
    type: boolean?
    inputBinding:
      position: 1
      prefix: "--noali"

  filter_e_value:
    type: float?
    inputBinding:
      position: 3
      prefix: "-E"

  gathering_bit_score:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--cut_ga"

  name_database:
    type: string

  data:
    type: Directory?
    default:
      class: Directory
      path:  db/
      location: db/
      listing: []
      basename: db
    inputBinding:
      valueFrom: $(self.path)/$(inputs.name_database)
      position: 5

  seqfile:
    type: File
    inputBinding:
      position: 6
      separate: true

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr
  output_table:
    type: File
    outputBinding:
      glob: "*hmmscan.tbl"