# Pytorch Cuda Opencv FFCV Docker
This repo contains a Dockerfile to build a docker image with opencv with cuda enabled, pytorch and ffcv.

# Why this docker
[FFCV](https://ffcv.io/) provides a powerful drop-in replacement for datasets and dataloaders, to significantly speed up training.
However, it requires opencv as dependency. Installing opencv via apt breaks cuda / mpi, which defeats the purpose. 
Conda may be an option, but is not always available. 

# What this docker image does
The docker image provided here extends the NVIDIA Pytorch docker with opencv + ffcv. Opencv is build from source to enable cuda support. 
