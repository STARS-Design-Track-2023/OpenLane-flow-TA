#!/usr/bin/env python3

# Import the required libraries
import subprocess as s
import os

def main ():

    # Move dependencies and the pdk to the home directory
    s.call ("mv pdk ~/.", shell=True)
    s.call ("mv build ~/.", shell=True)

    # Change the directory
    os.chdir("../")

    # Clone the OpenLane github repo
    s.call ("git clone https://github.com/The-OpenROAD-Project/OpenLane.git", shell=True)
    
    # Setup the environment
    s.call ('echo "export PDK_ROOT=~/pdk" >> ~/.bashrc', shell=True)
    os.system ("source ~/.bashrc")

    # Change into the OpenLane directory
    os.chdir("OpenLane/")
    
    # Test the flow 
    s.call ("make test", shell=True)

if __name__ == "__main__":
    main ()
