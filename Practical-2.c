#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "cond.c"
#include <stdbool.h>

//output from program:
//cond1:
//1to10.txt: 25
//1to20.txt: 100
//cond2:
//1to10.txt: 18
//1to20.txt: 63
//cond3: 
//1to10.txt: 12
//1to20.txt: 60

int pnum;  // number updated when producer runs.
int csum;  // sum computed using pnum when consumer runs.

//initialize our mutex
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

//initialize our condition variables
pthread_cond_t PNUMConsumed = PTHREAD_COND_INITIALIZER;
pthread_cond_t PNUMProduced = PTHREAD_COND_INITIALIZER;

//make a boolean variable
bool consumed = true;

int (*pred)(int); // predicate indicating if pnum is to be consumed

int produceT() {
  //pre-condition: mutex was initialised.
  //post-condition: mutex is locked, and the calling thread “owns” that lock.
  pthread_mutex_lock(&mutex);
  //code between the mutex lock and mutex unlock is essentially sequential code.

  while(!consumed){ //while what we produced is NOT consumed yet, we must wait for the condition variable!

    //mutex is locked by this thread here

    //precondition: condition variable PNUMConsumed is initialised, and mutex is locked. Also the calling thread “owns” the lock.
    //postcondition: mutex is locked, and the calling thread “owns” that lock. (time may have passed until another thread signalled to PNUMConsumed.)
    pthread_cond_wait(&PNUMConsumed, &mutex);

    //mutex is locked by this thread here
  }

  //access and modify shared resource, in this case, pnum!
  scanf("%d",&pnum); // read a number from stdin

  //precondition: a previous call to pthread_cond_wait, usually by some other thread, has associated PNUMProduced with mutex. Also mutex is locked and “owned” by the calling thread.
  //postcondition: a signal has been sent to PNUMProduced to tell it to wake a thread sleeping on it. Also mutex is still locked and “owned” by the calling thread.
  pthread_cond_signal(&PNUMProduced);
  
  //update boolean which keeps track of the number being consumed. Now it is produced by the producer so it is false.
  consumed=false;

  //precondition: mutex is locked and calling thread “owns” that lock
  //postcondition: this thread no longer “owns” the lock
  pthread_mutex_unlock(&mutex);
  return pnum;
}

void *Produce(void *a) {
  int p;

  p=1;
  while (p) {
    printf("@P-READY\n");
    p = produceT();
    printf("@PRODUCED %d\n",p);
  }
  printf("@P-EXIT\n");
  pthread_exit(NULL);
}


int consumeT() {
  //pre-condition: mutex was initialised.
  //post-condition: mutex is locked, and the calling thread “owns” that lock.
  pthread_mutex_lock(&mutex);

  while(consumed){ //while what was produced is consumed, we must wait for the producer to produce something for us to consume!

    //mutex is locked by this thread here

    //precondition: condition variable PNUMProduced is initialised, and mutex is locked. Also the calling thread “owns” the lock.
    //postcondition: mutex is locked, and the calling thread “owns” that lock. (time may have passed until another thread signalled to PNUMProduced.)
    pthread_cond_wait(&PNUMProduced, &mutex);

    //mutex is locked by this thread here
  }

  //access shared resource, in this case, pnum!
  if ( pred(pnum) ) { csum += pnum; }

  //precondition: a previous call to pthread_cond_wait, usually by some other thread, has associated PNUMConsumed with mutex. Also mutex is locked and “owned” by the calling thread.
  //postcondition: a signal has been sent to PNUMConsumed to tell it to wake a thread sleeping on it. Also mutex is still locked and “owned” by the calling thread.
  pthread_cond_signal(&PNUMConsumed);

  //update boolean which keeps track of the number being consumed. Now it is consumed by the produced so it is true!
  consumed = true;
  
  //precondition: mutex is locked and calling thread “owns” that lock
  //postcondition: this thread no longer “owns” the lock
  pthread_mutex_unlock(&mutex);
  
  return pnum;
}

void *Consume(void *a) {
  int p;

  p=1;
  while (p) {
      printf("@C-READY\n");
    p = consumeT();
    printf("@CONSUMED %d\n",csum);
  }
  printf("@C-EXIT\n");
  pthread_exit(NULL);
}


int main (int argc, const char * argv[]) {
  // the current number predicate
  static pthread_t prod,cons;
	long rc;

  pred = &cond1;
  if (argc>1) {
    if      (!strncmp(argv[1],"2",10)) { pred = &cond2; }
    else if (!strncmp(argv[1],"3",10)) { pred = &cond3; }
  }


  pnum = 999;
  csum=0;
  srand(time(0));

  printf("@P-CREATE\n");
 	rc = pthread_create(&prod,NULL,Produce,(void *)0);
	if (rc) {
			printf("@P-ERROR %ld\n",rc);
			exit(-1);
		}


  printf("@C-CREATE\n");
 	rc = pthread_create(&cons,NULL,Consume,(void *)0);
	if (rc) {
			printf("@C-ERROR %ld\n",rc);
			exit(-1);
		}

  printf("@P-JOIN\n");
  pthread_join( prod, NULL);
  printf("@C-JOIN\n");
  pthread_join( cons, NULL);

  //destroy the mutex object referenced by mutex; the mutex object becomes, in effect, uninitialized.
  pthread_mutex_destroy(&mutex);
  //destroy the given condition variable specified by PNUMConsumed; the object becomes, in effect, uninitialized.
  pthread_cond_destroy(&PNUMConsumed);
    //destroy the given condition variable specified by PNUMProduced; the object becomes, in effect, uninitialized.
  pthread_cond_destroy(&PNUMProduced);

  printf("@CSUM=%d.\n",csum);

  return 0;
}
