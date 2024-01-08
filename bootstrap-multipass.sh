#!/bin/bash

multipass launch lts --name dev-machine \
                     --memory 8G \
                     --disk 60G \
                     --cpus 4 \
                     --mount ~/Development:/home/ubuntu/Development \
                     --mount ~/.lein:/home/ubuntu/.lein \
                     --mount ~/.vim:/home/ubuntu/.vim

multipass set client.primary-name=dev-machine

multipass transfer user-data.sh dev-machine:/home/ubuntu
multipass exec dev-machine '/home/ubuntu/user-data.sh'

multipass transfer ~/.ssh/id_ed25519_sk.pub dev-machine:/tmp
multipass exec dev-machine 'echo /tmp/id_ed25519_sk.pub >> /home/ubuntu/.ssh/authorized_keys && rm /tmp/id_ed25519_sk.pub'
