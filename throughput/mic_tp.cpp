#include <cstdio>
#include <unistd.h>
#include <iostream>
#include <sys/times.h>
#include <omp.h>
#include <offload.h>

#define MIC_DEV 0

int main(int argc, char *argv[])
{
    double sum=0.0;
    clock_t clockStart, clockStop;
    tms tmsStart, tmsStop;

	#pragma offload target(mic:MIC_DEV) // first call to device might take some time
	{
		#pragma omp parallel
		{
			#pragma omp master
			{
	    		printf ("num threads=%d\n", omp_get_num_threads());
	    	}
		}
	}

    //generate random data
    typedef unsigned long long Index;
    Index size=2LL*1024*1024*1024;
    std::cerr<<"creating array of random numbers \n";
    std::cerr<<"size = "<<static_cast<double>(size)/(1024*1024*1024)<<"G \n";

    clockStart = times(&tmsStart);
    unsigned char * array = new unsigned char [size];
    for (Index i=0;i<size;i++)
        array[i]= rand()%256; //not the best way to generate random nubers
    clockStop = times(&tmsStop);
    std::cerr << "Done in " << (clockStop - clockStart)/static_cast<double>(sysconf(_SC_CLK_TCK)) << " seconds\n\n";
    std::cerr<<"offloading to mic \n";
    clockStart = times(&tmsStart);
	#pragma offload target(mic:MIC_DEV) inout(sum)  in(array:length(size))
	{
    	//#pragma omp  parallel for reduction (+:sum)
   		//for (int i=0; i<size; i++)
   		//{
        //	sum = sum + array[i];
	    //}
	}
    clockStop = times(&tmsStop);
    std::cerr << "Avg=" <<sum/size<<"\n" ;

    std::cerr << "Done in " ;
    double secs= (clockStop - clockStart)/static_cast<double>(sysconf(_SC_CLK_TCK));
    std::cerr << secs << " seconds\n" << std::endl;
    return 0;
}