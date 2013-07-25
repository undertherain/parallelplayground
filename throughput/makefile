CFLAGS = -Wall -fopenmp -O3
CPPFLAGS :=  -xhost  -openmp -Wall -O3
#CPPFLAGS :=  -mmic  -openmp

mic_tp: mic_tp.cpp
	icc $(CPPFLAGS) -o $@ $^

run:
	export LD_LIBRARY_PARH=${LD_LIBRARY_PARH}:/opt/intel/composer_xe_2013.0.079/compiler/lib/intel64/
	source /opt/intel/composerxe/bin/compilervars.sh intel64
	#sudo micctrl -s