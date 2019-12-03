#!/bin/bash

set -e

add_files_to_folder() {
    local folder=${1:?"Specify folder path"}
    local file=${2:?"Please specify file name"}
    
    touch $folder/$file
}

old_folder() {
    mkdir -p /home/vagrant/prod/random-old /home/vagrant/prod/old
    add_files_to_folder /home/vagrant/prod/random-old new_old_file
    cp -r --preserve=all /home/vagrant/prod/random-old /home/vagrant/prod/old
}

current_folder() {
    mkdir -p /home/vagrant/prod/random-current /home/vagrant/prod/current
    add_files_to_folder /home/vagrant/prod/random-current new_current_file
    cp -r --no-preserve=all /home/vagrant/prod/random-old /home/vagrant/prod/old
}

new_folder() {
    mkdir -p /home/vagrant/prod/random-new /home/vagrant/prod/new
    add_files_to_folder /home/vagrant/prod/random-new new_new_file
    cp -r --preserve=timestamps /home/vagrant/prod/random-new /home/vagrant/prod/new
}

create_tar() {
    local tar_path=${1:?"Specify tar path"}
    local dirs_to_tar=${}
    tar -czvf $tar_path /home/vagrant/prod/new /home/vagrant/prod/current /home/vagrant/prod/old
}

old_folder
current_folder
new_folder
