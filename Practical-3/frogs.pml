//There are 5 positions for the frogs to be in.
#define POSITIONS 5

//mtypes for describing the positions
mtype = { none, frog1, frog2, frog3, frog4};

//This will hold the frogs
byte position[POSITIONS];

//booleans to see if a frog has moved (useful for `START` statements which are used BEFORE a frog moves)
bool frog1Moved = false;
bool frog2Moved = false;
bool frog3Moved = false;
bool frog4Moved = false;

//mtypes for the mutex
mtype = {locked, unlocked}; // enum

// mutex declared and initialised as unlocked
mtype mutex = unlocked; 

// mutex id, current owner
int mid; 

// initial (main) thread id
int init_id; 

//mutex_lock
inline lock(m) 
{
  atomic
  {
    (m == unlocked);
    m = locked;
    mid = _pid;
  }
}

//mutex_unlock
inline unlock(m) 
{
  atomic
  {
    assert(mid == _pid);
    m = unlocked;
    mid = init_id;
  }
}


//Process for frog 1 which moves right
proctype Frog1(byte currentPosition)
{

//The do-loop with the end label to show that the process can NOT be at the end of the code AND STILL be a valid output.
end:do
    //There is only one option inside of the do-loop starting from the :: below !
    ::  if  //We check if the `START` statement has been printed already
        :: (frog1Moved == false) -> printf( "START FROG %d AT %d GOING RIGHT\n", 1, position[frog1-1]); frog1Moved = true;
        :: else -> skip;
        fi
        
        //Now we LOCK THE MUTEX before comparing positions - this is vital because if we compare positions AND THEN try to lock the mutex,
        //there is a possibility that another thread locks the mutex before it, and renders the "if-condition" false when it tries again, 
        //hence we may have two frogs in the same position ~ something we DO NOT want.
        lock(mutex);

        if
        //The frog has two possible ways of jumping:
        //OPTION 1: The frog can jump 1 position to the right
        ::((currentPosition < POSITIONS) && (position[none-1] == currentPosition+1)) ->
            //Print the move statement for the frog - It is going to move to the right by 1 position!!
            printf( "MOVE FROG%d FROM %d TO %d\n", 1, currentPosition, currentPosition+1);

            //This is a critical region, but we are still locked by the mutex
            position[none-1] = currentPosition;
            currentPosition = currentPosition + 1;
            position[frog1-1] = currentPosition; 

            //Print the current status of the positions to the user
            printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);

            //Now we can UNLOCK THE MUTEX after changing the position of the frog -> we DO NOT want this to happen concurrently
            unlock(mutex);

        //OPTION 2: The frog can jump 2 positions to the right
        ::((currentPosition < POSITIONS-1) && (position[none-1] == currentPosition+2)) ->
            //Print the move statement for the frog - It is going to move to the right by 2 positions!!
            printf( "MOVE FROG%d FROM %d TO %d\n", 1, currentPosition, currentPosition+2);

            //This is a critical region, but we are still locked by the mutex
            position[none-1] = currentPosition;
            currentPosition = currentPosition + 2;
            position[frog1-1] = currentPosition; 
            //Print the current status of the positions to the user
            printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);
            
            //Now we can UNLOCK THE MUTEX after changing the position of the frog -> we DO NOT want this to happen concurrently
            unlock(mutex);
        fi
        //The if-condition above will BLOCK if both it's conditions are not true - allowing other threads (i.e. frogs) to move and possibly let them become true!
    od;
}

//Process for frog 2 which moves left
proctype Frog2(byte currentPosition)
{
end:do
    //There is only one option inside of the do-loop starting from the :: below !
    ::  if //We check if the `START` statement has been printed already
        :: (frog2Moved == false) ->  printf( "START FROG %d AT %d GOING LEFT\n", 2, position[frog2-1]); frog2Moved = true;
        :: else -> skip;
        fi

        //Now we LOCK THE MUTEX before comparing positions - this is vital because if we compare positions AND THEN try to lock the mutex,
        //there is a possibility that another thread locks the mutex before it, and renders the "if-condition" false when it tries again, 
        //hence we may have two frogs in the same position ~ something we DO NOT want.
        lock(mutex);

        if
        //The frog has two possible ways of jumping:
        //OPTION 1: The frog can jump 1 position to the left
        :: ((currentPosition > 1) && (position[none-1] == currentPosition-1)) ->
            //Print the move statement for the frog - It is going to move to the left by 1 position!!
            printf( "MOVE FROG%d FROM %d TO %d\n", 2, currentPosition, currentPosition-1);

            //This is a critical region, but we are still locked by the mutex
            position[none-1] = currentPosition;
            currentPosition = currentPosition - 1;
            position[frog2-1] = currentPosition; 

            //Print the current status of the positions to the user
            printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);

            //Now we can UNLOCK THE MUTEX after changing the position of the frog -> we DO NOT want this to happen concurrently
            unlock(mutex);

        //OPTION 2: The frog can jump 2 positions to the left
        :: ((currentPosition > 2) && (position[none-1] == currentPosition-2)) -> 
            //Print the move statement for the frog - It is going to move to the left by 2 positions!!
            printf( "MOVE FROG%d FROM %d TO %d\n", 2, currentPosition, currentPosition-2);

            //This is a critical region, but we are still locked by the mutex
            position[none-1] = currentPosition;
            currentPosition = currentPosition - 2;
            position[frog2-1] = currentPosition;
             //Print the current status of the positions to the user
            printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);

            //Now we can UNLOCK THE MUTEX after changing the position of the frog -> we DO NOT want this to happen concurrently
            unlock(mutex);
        fi
        //The if-condition above will BLOCK if both it's conditions are not true - allowing other threads (i.e. frogs) to move and possibly let them become true!
    od;
}

//Process for frog 3 which moves left
proctype Frog3(byte currentPosition)
{
end:do
    //There is only one option inside of the do-loop starting from the :: below !
    ::  if //We check if the `START` statement has been printed already
        :: (frog3Moved == false) ->  printf( "START FROG %d AT %d GOING LEFT\n", 3, position[frog3-1]); frog3Moved = true;
        :: else -> skip;
        fi

        //Now we LOCK THE MUTEX before comparing positions - this is vital because if we compare positions AND THEN try to lock the mutex,
        //there is a possibility that another thread locks the mutex before it, and renders the "if-condition" false when it tries again, 
        //hence we may have two frogs in the same position ~ something we DO NOT want.
        lock(mutex);

        if
        //The frog has two possible ways of jumping:
        //OPTION 1: The frog can jump 1 position to the left
        :: ((currentPosition > 1) && (position[none-1] == currentPosition-1)) ->
            //Print the move statement for the frog - It is going to move to the left by 1 position!!
            printf( "MOVE FROG%d FROM %d TO %d\n", 3, currentPosition, currentPosition-1);

            //This is a critical region, but we are still locked by the mutex
            position[none-1] = currentPosition;
            currentPosition = currentPosition - 1;
            position[frog3-1] = currentPosition;
            //Print the current status of the positions to the user
            printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);

            //Now we can UNLOCK THE MUTEX after changing the position of the frog -> we DO NOT want this to happen concurrently
            unlock(mutex);

        //OPTION 2: The frog can jump 2 positions to the left
        :: ((currentPosition > 2) && (position[none-1] == currentPosition-2)) -> 
            printf( "MOVE FROG%d FROM %d TO %d\n", 3, currentPosition, currentPosition-2);

            //This is a critical region, but we are still locked by the mutex
            position[none-1] = currentPosition;
            currentPosition = currentPosition - 2;
            position[frog3-1] = currentPosition;
            //Print the current status of the positions to the user
            printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);

             //Now we can UNLOCK THE MUTEX after changing the position of the frog -> we DO NOT want this to happen concurrently
            unlock(mutex);
        fi
        //The if-condition above will BLOCK if both it's conditions are not true - allowing other threads (i.e. frogs) to move and possibly let them become true!
    od;
}

//Process for frog 4 which moves left
proctype Frog4(byte currentPosition)
{
end:do
    //There is only one option inside of the do-loop starting from the :: below !
    ::  if //We check if the `START` statement has been printed already
        :: (frog4Moved == false) ->  printf( "START FROG %d AT %d GOING LEFT\n", 4, position[frog4-1]); frog4Moved = true;
        :: else -> skip;
        fi

        //Now we LOCK THE MUTEX before comparing positions - this is vital because if we compare positions AND THEN try to lock the mutex,
        //there is a possibility that another thread locks the mutex before it, and renders the "if-condition" false when it tries again, 
        //hence we may have two frogs in the same position ~ something we DO NOT want.
        lock(mutex);

        if
        //The frog has two possible ways of jumping:
        //OPTION 1: The frog can jump 1 position to the left
        :: ((currentPosition > 1) && (position[none-1] == currentPosition-1)) ->
            //Print the move statement for the frog - It is going to move to the left by 1 position!!
            printf( "MOVE FROG%d FROM %d TO %d\n", 4, currentPosition, currentPosition-1);

            //This is a critical region, but we are still locked by the mutex
            position[none-1] = currentPosition;
            currentPosition = currentPosition - 1;
            position[frog4-1] = currentPosition;
            //Print the current status of the positions to the user
            printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);

            //Now we can UNLOCK THE MUTEX after changing the position of the frog -> we DO NOT want this to happen concurrently
            unlock(mutex);

        //OPTION 2: The frog can jump 2 positions to the left
        :: ((currentPosition > 2) && (position[none-1] == currentPosition-2)) -> 
            //Print the move statement for the frog - It is going to move to the left by 2 positions!!
            printf( "MOVE FROG%d FROM %d TO %d\n", 4, currentPosition, currentPosition-2);

            //This is a critical region, but we are still locked by the mutex
            position[none-1] = currentPosition;
            currentPosition = currentPosition - 2;
            position[frog4-1] = currentPosition;
            //Print the current status of the positions to the user
            printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);

            //Now we can UNLOCK THE MUTEX after changing the position of the frog -> we DO NOT want this to happen concurrently
            unlock(mutex);
        fi
        //The if-condition above will BLOCK if both it's conditions are not true - allowing other threads (i.e. frogs) to move and possibly let them become true!
    od;
}


init
{
  init_id = _pid; //main thread pid
  mid = init_id; //mutex owned by main

  //The assignment spec requires a particular ordering of the frogs at the start of the model.
  //NOTE: The '-1' is used because of the way arrays work with Promela
  position[frog1-1] = 1; //FROG1 is in position 1
  position[none-1] = 2;  //NOTHING is in position 2
  position[frog2-1] = 3; //FROG2 is in position 3
  position[frog3-1] = 4; //FROG3 is in position 4
  position[frog4-1] = 5; //FROG4 is in position 5.

  //The `EMPTY` line is the first thing printed, as requested by the assignment spec.
  printf( "EMPTY %d, FROG1@%d, FROG2@%d, FROG3@%d, FROG4@%d\n" , position[none-1], position[frog1-1] , position[frog2-1],  position[frog3-1],  position[frog4-1]);

  //Run all 4 threads (i.e. frogs) concurrently and let them do their thing!
  run Frog1(1);
  run Frog2(3);
  run Frog3(4);
  run Frog4(5);

  //NOTE: I did not use atomic{} in the processes for the frogs to ensure that there is as much interleaving as possible to cover more possibilities for the frogs.
  
  //If we have gotten to the right answer, then we can assert false to report an assertion violation as the assignment specification desires.
  (position[3]==none)&&(position[4]==frog1)
   printf( "DONE!\n" );
   assert(false); //At this point, the booleans frogXMoved (for X = 1,2,3,4) should be 1 (true).
}