# Hearbeat 
Windows 10+, 64 bit only  
 
  
#### Description  
**Under construction!**  
The purpose of Hearbeat is to execute (or delayed/repeated execution) functions (= task-functions) at specific times (in the range of seconds),  
with possible delaying or aborting the execution of all tasks.  
  
There are two important variables:  
"counter" which is incremented every heartbeat (via "getsetCounter(getsetCounter() + 1)" inside "pollKeyboard()") and  
"schedulerList" which holds the name of the function to be executed.  
  

The function "heartbeat()" checks the keyboard (via pollKeyboard()) if Capslock (= PAUSE) or Ctrl+c (= ABORT) are pressed,  
otherwise the function "scheduler()" is called.
"heartbeat()" calls itself after a delay of 1 second then.  
  
The function "scheduler()" has two purposes,  
First, if it is called with parameters "taskName" and "counterUntil",
a new task is added to the list of task "schedulerList",  
with "taskName" as the key and "counterUntil" as the value.  
"taskName" is the name of the task-function that should be executed if the counter reaches the counterUntil value.  
Secondly, if it called without a paramter (as by heartbeat() -> pollKeyboard() -> scheduler()),  
it checks each entry in the schedulerList if the counterUntil value is >= value of the "counter" variable,  
and calls the task-function "taskName" immediately (via settimer,%key%, -1),  
using only the default function-parameter then.  
  
Different task types:  
Type 1: Run once only at a specific time (n seconds later then the current time) 
Type 2: Run repeated every n seconds  
Type 3: Run repeated every n seconds, start after a delay (n seconds later then the current time) 
Type 4: Additionally have a delay in "the middle" (a countDown)

The task-function must meet certain requirements regarding its parameters.  
It must be possible to distinguish between the following three calls:
- with counterUntil parameter
- without parameter
- without abort request parameter
In addition, in case of type 3, it must be possible to distinguish between the first call and all others.  

Type 1 to type 3 take a look at "SimulateMultitasking.ahk"
Type 4 take a look at "heartbeat.ahk"



Autohotkey is singlethreaded, but has two additional timer-threads: countdown-timer and repeat-timer.  
Heartbeat uses only the countdown-timer. 
I'm not shure if a function calling itself via "settimer,functionname, -1"  
is running on the timer thread the second time?
  
##### License: MIT, -> MIT_License.txt  
Copyright (c) 2021 J. v.Roos  
  



