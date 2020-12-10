#!/bin/bash

sudo docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan jupyter/scipy-notebook:399cbb986c6b start.sh jupyter lab --LabApp.token=''
