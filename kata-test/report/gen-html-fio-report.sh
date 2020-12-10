#!/bin/bash
sudo docker run -ti --rm -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan jupyter/scipy-notebook:399cbb986c6b bash  -c 'jupyter nbconvert --execute fio.ipynb --to html'
