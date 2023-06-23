#!/usr/bin/env python3

import subprocess, os

def setup ():
    os.chdir("../")
    subprocess.call ("mv OpenLane-flow/cvc_pdk .", shell=True)
    subprocess.call ("mv OpenLane-flow/makefile .", shell=True)
    subprocess.call ("mv OpenLane-flow/config.json .", shell=True)
    subprocess.call ("mv OpenLane-flow/time_sim.py .", shell=True)
    # Only exists for TA example
    subprocess.call ("rm -rf src", shell=True)
    subprocess.call ("mv OpenLane-flow/src .", shell=True)
    subprocess.call ("rm -rf OpenLane-flow", shell=True)


if __name__ == "__main__":
    setup ()
