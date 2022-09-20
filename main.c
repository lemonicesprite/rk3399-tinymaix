#include <stdlib.h>
#include <sys/types.h>
#include <sys/sysinfo.h>
#include <unistd.h>
#include <stdio.h>

#define __USE_GNU
#include <sched.h>
#include <ctype.h>
#include <string.h>
#include <pthread.h>
#include "testdemo.h"

void* threadFun(void* arg)
{
    int cpucore = *(int*)arg;
    printf("bind %d cpu to this thread \n", cpucore);
    cpu_set_t mask;
    CPU_ZERO(&mask);
    CPU_SET(cpucore,&mask);

    printf("thread %lu, cpucore = %d\n", pthread_self(), cpucore);
    if(-1 == pthread_setaffinity_np(pthread_self() ,sizeof(mask),&mask)) {
        printf("bind error \n");
    }

    tinymaix_demo();

    return NULL;
}

int main(int argc, char* argv[])
{
    int cpucorenum;
    pthread_t thread;

    cpucorenum = TASKCPUCORE; 

    pthread_create(&thread,NULL,threadFun,(void*)&cpucorenum);

    pthread_join(thread,NULL);

    return 0;
}
