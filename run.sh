#!/bin/bash
sudo docker build . -t automode # --no-cache
sudo docker run -v ./output/:/app/data -v ./output/results:/app/PonyGE2/results automode