#!/usr/bin/env python3

import argparse
import subprocess
import sys
import os
from shutil import copy

def run_command(command):
    try:
        print('*** command running *** \n' + command + '\n***************')
        subprocess.Popen(['/bin/bash', '-c', command]).wait()
    except subprocess.CalledProcessError as e:
        print >> sys.stderr, "ERROR: Failed to run " + ' '.join(e.cmd)
        sys.exit(1)


pipeline_run_folder = "/hps/nobackup2/production/metagenomics/pipeline/testing/kate/pipeline-v5-runs"
yml = pipeline_run_folder + "/ymls/assembly-wf-pattern.yml"
cwl = "/hps/nobackup2/production/metagenomics/pipeline/testing/kate/pipeline-v5/workflows/judy.cwl"
list_contigs = 'example.txt'  # "/hps/nobackup2/production/metagenomics/assemblies/judy/Mgnify_result/primary_assemblies_non_ena.txt"

source = "source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/auto_env.rc ; " \
         "source /hps/nobackup/production/metagenomics/software/toil-venv/bin/activate"

# create yml
with open(list_contigs, 'r') as fastas:
    for fasta in fastas:
        print(fasta)
        fasta = fasta.strip()
        path_dir = os.path.dirname(fasta)
        run_yml = os.path.join(path_dir, 'run.yml')
        copy(yml, run_yml)
        create_yml_command = 'python3 ' + os.path.join(pipeline_run_folder, 'scripts', 'prepare_yml.py ')
        create_yml_command += ' -y ' + run_yml + ' -a ' + "assembly" + ' -s ' + fasta

        annotation_dir = os.path.join(path_dir, "assembly-annotation")
        if not os.path.exists(annotation_dir):
            os.makedirs(annotation_dir)

        work_dir = os.path.join(annotation_dir, "work-dir")
        job_store = os.path.join(annotation_dir, "job-store")
        out_dir = os.path.join(annotation_dir, "result")
        log_file = os.path.join(annotation_dir, "file.log")
        json = os.path.join(annotation_dir, "out.json")
        stderr = os.path.join(annotation_dir, "stderr")
        if not os.path.exists(work_dir):
            os.makedirs(work_dir)

        bsub = 'bgadd -L 100 /kates_judy > /dev/null; bgmod -L 100 /kates_judy > /dev/null; ' \
               'bgadd -L 100 /kates_judy_toil > /dev/null; bgmod -L 100 /kates_judy_toil > /dev/null;' \
               'export TOIL_LSF_ARGS=\"-q production-rh74 -g /kates_judy\"; bsub -M 7G -g /kates_judy_toil ' \
               '-o {work_dir}/bsub.out -e {work_dir}/bsub.err'.format(work_dir=work_dir)

        beginning = 'cd {work_dir} ; time toil-cwl-runner '.format(work_dir=work_dir)

        command = bsub + ' ' + source + ';' + beginning + \
              '--no-container --batchSystem LSF --disableCaching --retryCount 3 --stats ' \
              '--defaultMemory {memory} ' \
              '--defaultCores {num_cores} ' \
              '--jobStore {job_store} ' \
              '--outdir {out_dir} ' \
              '--logFile {log_file} ' \
              '{cwl} {yml} >> {json} 2> {stderr}'.format(memory="30G", num_cores="8", job_store=job_store,
                                                         out_dir=out_dir, log_file=log_file, cwl=cwl, yml=run_yml,
                                                         json=json, stderr=stderr)
        print(command)
        run_command(command)
