#!/bin/bash

multipass launch lts --name dev-machine \
                     --memory 8G \
                     --disk 60G \
                     --cpus 4 \
                     --mount ~/Development:/home/ubuntu/Development \
                     --mount ~/.lein:/home/ubuntu/.lein \
                     --mount ~/.vim:/home/ubuntu/.vim
