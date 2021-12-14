#!/bin/bash
iverilog-vpi better_base.c
iverilog -g2012 -o Connect4Sim.Part4.vvp Connect4Sim.Part4.v
vvp -M. -mbetter_base Connect4Sim.Part4.vvp
