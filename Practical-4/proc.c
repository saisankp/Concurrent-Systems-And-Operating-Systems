// +++++++ ONLY MODIFY BELOW LINE 39 BELOW
#include "types.h"
#include "defs.h"
#include <stdio.h>
#include "proc.h"

#define NCPU 1

struct cpu cpus[NCPU];
int ncpu;

void printstate(enum procstate pstate){ // DO NOT MODIFY
  switch(pstate) {
    case UNUSED   : printf("UNUSED");   break;
    case EMBRYO   : printf("EMBRYO");   break;
    case SLEEPING : printf("SLEEPING"); break;
    case RUNNABLE : printf("RUNNABLE"); break;
    case RUNNING  : printf("RUNNING");  break;
    case ZOMBIE   : printf("ZOMBIE");   break;
    default       : printf("????????");
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.

// local to scheduler in xv6, but here we need them to persist outside,
// because while xv6 runs scheduler as a "coroutine" via swtch,
// here swtch is just a regular procedure call.
struct proc *p;
struct cpu *c = cpus;

//  Add in any global variables and functions you need below.
// +++++++ ONLY MODIFY BELOW THIS LINE ++++++++++++++++++++++

//This Function is for ensuring the index wraps around the array
int getIndexForProcesses(int index){
  if(index >= NPROC){
    index = index - NPROC;
  }
  return index;
}

void
scheduler(void)
{ int runnableFound; // DO NOT MODIFY/DELETE

  //c refers to the CPU (we only have one for this assignment) -> proc is the process that we're planning to run (0 is the array index of the processes that the scheduler has chosen to run)
  c->proc = 0;
  runnableFound = 1 ; // force one pass over ptable

  //Create an array to keep track of the number of runs for each process
  //We can access this number for each process by indexing with it's pid
  //We start off with the number of runs for every process being 0.
  int numberOfRunsForProcess [NPROC];
  for(int i=0; i< NPROC; i++){
    numberOfRunsForProcess[i] = 0;
  }

  //start off the variable as -1 to then start off with 0 inside the loop (i.e [-1] + 1 = 0)
  int processRunLeastOften = -1;

  while(runnableFound){ // DO NOT MODIFY
    // Enable interrupts on this processor.
    // sti();
    runnableFound = 0; // DO NOT MODIFY
    // Loop over process table looking for process to run.
    // acquire(&ptable.lock);

    //Now we can find the process we want to run using load balancing.
    processRunLeastOften = processRunLeastOften + 1;
    int testProcessRunLeastOften = processRunLeastOften;
    for(int i = 0; i < NPROC; i++){
      p = &ptable.proc[getIndexForProcesses(processRunLeastOften+i)];
      if(p->state != RUNNABLE){
          continue;
      }
      else if((&ptable.proc[testProcessRunLeastOften])->state != RUNNABLE){
        testProcessRunLeastOften = p->pid;
      }
      else if((numberOfRunsForProcess[p->pid] < numberOfRunsForProcess[testProcessRunLeastOften])){
        testProcessRunLeastOften = p->pid;
      }
    }

    //Change the process run least option variable if we found a new process to change it.
    processRunLeastOften = testProcessRunLeastOften;

    //Use that variable as an index into the ptable.
    p = &ptable.proc[processRunLeastOften];

    //If the process is not runnable, then we just skip this iteration of the loop.
    if(p->state != RUNNABLE){
       continue;
    }

    runnableFound = 1; // DO NOT MODIFY/DELETE/BYPASS

    //Increment the element with index processRunLeastOften in the numberOfRunsForProcess array
    numberOfRunsForProcess[processRunLeastOften]++;

    // Switch to chosen process.  It is the process's job
    // to release ptable.lock and then reacquire it
    // before jumping back to us.
    c->proc = p;
    //switchuvm(p);
    p->state = RUNNING;

    //This would usually be switch.s in assembly code, but we have a function for it.
    swtch(p);
    // p->state should not be running on return here.
    //switchkvm();
    // Process is done running for now.
    // It should have changed its p->state before coming back.
    c->proc = 0;
    // release(&ptable.lock);
  }
  printf("No RUNNABLE process!\n");
}
