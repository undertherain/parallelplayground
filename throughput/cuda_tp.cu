#include <iostream>
#include <cuda.h>
#include <cstdio>
#include <unistd.h>
#include <sys/times.h>
#include <omp.h>

typedef unsigned long long Index;

int main()
{
  	int devCount;
    cudaGetDeviceCount(&devCount); //random thing to avoid latency of a first call to device

	size_t size=2LL*1024*1024*1024;
	unsigned char *cpuBuf = new unsigned char[size];
	unsigned char * gpuBuf;
    clock_t clockStart, clockStop;
    tms tmsStart, tmsStop;

    std::cerr<<"creating array of random numbers \n";
    std::cerr<<"size = "<<static_cast<double>(size)/(1024*1024*1024)<<"G \n";

 	clockStart = times(&tmsStart);
    unsigned char * array = new unsigned char [size];
    for (Index i=0;i<size;i++)
        array[i]= rand()%256; //not the best way to generate random nubers
    clockStop = times(&tmsStop);
    std::cerr << "Done in " << (clockStop - clockStart)/static_cast<double>(sysconf(_SC_CLK_TCK)) << " seconds\n\n";
    std::cerr<<"offloading to GPU \n";


    clockStart = times(&tmsStart);

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaMalloc((void**)&gpuBuf, size);
	cudaEventRecord(start, 0);
    cudaMemcpy(gpuBuf,cpuBuf, size,cudaMemcpyHostToDevice);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);

    clockStop = times(&tmsStop);
    std::cerr << "Done in " ;
    double secs= (clockStop - clockStart)/static_cast<double>(sysconf(_SC_CLK_TCK));
    std::cerr << secs << " seconds\n" << std::endl;

	float elapsedTime;
	cudaEventElapsedTime(&elapsedTime, start, stop); // that's our time!
	std::cout<<"elapsed gpu time= "<<elapsedTime/1000<<"s"<<std::endl;

	cudaFree (gpuBuf);
	delete[] cpuBuf;
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	return 0;
}
