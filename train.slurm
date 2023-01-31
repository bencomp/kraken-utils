#!/bin/bash
#SBATCH --job-name=t_kraken
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-user="b.a.companjen@library.leidenuniv.nl"
#SBATCH --mail-type="ALL"
#SBATCH --mem=10G
#SBATCH --time=6:00:00
#SBATCH --partition=gpu-medium
#SBATCH --ntasks=1
#SBATCH --gpus=1

# load modules (assuming you start from the default environment)
# we explicitely call the modules to improve reproducability
# in case the default settings change
# module list
env | sort
module load tensorboardX/2.2-fosscuda-2020b-PyTorch-1.7.1
module load torchvision/0.8.2-fosscuda-2020b-PyTorch-1.7.1
module unload gcc/8.2.0
echo "[$SHELL] what Python packages have been loaded so far?"
# pip3 list
# Ben set up a virtual environment with packages required by kraken,
# that are not loaded by the torchvision module
echo "[$SHELL] Activating my virtual environment"
source $HOME/venvs/kraken42/bin/activate

echo "[$SHELL] #### Starting GPU Kraken training"
echo "[$SHELL] This is $SLURM_JOB_USER and my job has the ID $SLURM_JOB_ID"
# get the current working directory
export CWD=$(pwd)
echo "[$SHELL] CWD: "$CWD

# Which GPU has been assigned
echo "[$SHELL] Using GPU: "$CUDA_VISIBLE_DEVICES

export MODEL_PREFIX=de_fr
# Create a directory of local scratch on the node
echo "[$SHELL] Node scratch: "$SCRATCH
export RUNDIR=$SCRATCH/kraken
mkdir -p $RUNDIR
echo "[$SHELL] Run directory: "$RUNDIR

cp $HOME/ocr-data/lines.zip $SCRATCH/
cd $SCRATCH
unzip -q $SCRATCH/lines.zip

# Change to $RUNDIR
cd $RUNDIR
which python
# pip list
# module list

export NCCL_IB_DISABLE=1
export NCCL_DEBUG=INFO

# Run the file
echo "[$SHELL] Run script"
python -m torch.utils.collect_env
python - <<EOF
import os
for k,v in sorted(os.environ.items()):
    print(k, v)

EOF
ketos -vvv train -d cuda:$CUDA_VISIBLE_DEVICES -o $MODEL_PREFIX $SCRATCH/linegen-output/*/*.png
echo "[$SHELL] Script finished"

# Move stat directory back to CWD
echo "[$SHELL] Copy files back to cwd"
# cd $PROJECTDIR
# zip -r $SCRATCH/$PROJECTNAME-$SLURM_JOB_ID.zip ./ 
cp -r $RUNDIR/*_best.mlmodel $CWD/

echo "[$SHELL] #### Finished GPU training."
