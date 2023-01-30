#!/bin/bash
#SBATCH --job-name=r_kraken
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --mail-user="b.a.companjen@library.leidenuniv.nl"
#SBATCH --mail-type="ALL"
#SBATCH --mem=6G
#SBATCH --time=0:10:00
#SBATCH --partition=gpu-short
#SBATCH --ntasks=1
#SBATCH --gpus=1

# load modules (assuming you start from the default environment)
# we explicitely call the modules to improve reproducability
# in case the default settings change
module load tensorboardX/2.2-fosscuda-2020b-PyTorch-1.7.1
module load torchvision/0.8.2-fosscuda-2020b-PyTorch-1.7.1

# Ben set up a virtual environment with packages required by kraken,
# that are not loaded by the torchvision module
source $HOME/venvs/kraken42/bin/activate

echo "[$SHELL] #### Starting GPU Kraken training"
echo "[$SHELL] This is $SLURM_JOB_USER and my job has the ID $SLURM_JOB_ID"
# get the current working directory
# export CWD=$(pwd)
# echo "[$SHELL] CWD: "$CWD

# Which GPU has been assigned
echo "[$SHELL] Using GPU: "$CUDA_VISIBLE_DEVICES


# Create a directory of local scratch on the node
# echo "[$SHELL] Node scratch: "$SCRATCH
# export RUNDIR=$SCRATCH/yolov5
# cp -r $HOME/yolov5 $SCRATCH/
# echo "[$SHELL] Run directory: "$RUNDIR

# Training configuration
# export DATAYAML=$CWD/symbols2.yaml
# export HYPERYAML=$CWD/hyper_params.yaml
# export BASEMODEL=$HOME/models/yolov5l6.pt

# Directory for training results is created by the script
# export PROJECTDIR=$SCRATCH/training
# export PROJECTNAME=yolo_model_5

# Directory for training data must match $DATAYAML!
# export DATASETS=$SCRATCH/datasets
# mkdir -p $DATASETS
# cp -r $HOME/training_data $DATASETS/

# Change to $RUNDIR
cd $HOME/models/kraken

# Run the file
echo "[$SHELL] Run script"
python -m torch.utils.collect_env
python - <<EOF
import os
for k,v in sorted(os.environ.items()):
    print(k, v)

EOF
kraken -vvv -r -i $HOME/default.jpg $HOME/manu.xml -x -d cuda:0 binarize segment -bl ocr -m frolat_medieval_expan.mlmodel
echo "[$SHELL] Script finished"

# Move stat directory back to CWD
# echo "[$SHELL] Copy files back to cwd"
# cd $PROJECTDIR
# zip -r $SCRATCH/$PROJECTNAME-$SLURM_JOB_ID.zip ./ 
# cp -r $SCRATCH/$PROJECTNAME-$SLURM_JOB_ID.zip $CWD/

echo "[$SHELL] #### Finished GPU training."
