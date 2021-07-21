#!/bin/bash
verilator --cc --Wno-lint ../core.sv -exe test.cpp -I../ \
	&&  make -C obj_dir -f Vcore.mk CXXFLAGS="-std=c++11" \
	&& ./obj_dir/Vcore
