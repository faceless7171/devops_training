#!/bin/bash

set -e

if [ $(id -u) -eq 0 ]; then
    read -p "Enter username: " username
    read -s -p "Enter password: " password_1
    read -s -p "Re-enter password: " password_2
    if [ "$password_1" != "$password_2" ]; then
        echo "Password should be equal to Re-enter password."
        exit 1
    fi
    if [ -n "$(grep -E '^$username' /etc/passwd)" ]; then
        echo "Username '$username' already exists."
        exit 1
    else
        useradd -m -p $(openssl passwd -1 $password_1) $username
        [ $? -eq 0 ] && echo "User has been added." || echo "Failed to add a user."; exit 1
    fi
else
    echo "Run script as root"
    exit 1
fi