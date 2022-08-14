; SimulateMultitasking.ahk
; under construction (for later use in ClickAndSleep)

; try to make multible timings with only one timer (heartbeat)
; heartbeat() loops itself via a timer after a second,
; it calls scheduler() once
; scheduler() has a counter and a list [schedulerList] of active tasks
; each task has a value, if the counter reading is equal (or higher)
; the task is executed
; task are functions which must meet special conditions.
; 

#NoEnv
#Warn
#SingleInstance Force
#InstallKeybdHook

appName := "Heartbeat"
appnameLower := "heartbeat"
appVersion := "0.002"

simulateMultitasking := false
task2HasMsgbox := false

showWindow()

speedscale := 5
heartbeat()

return

;------------------------------- demoGuiEscape -------------------------------
demoGuiEscape(){
exit()
}
;------------------------------- demoGuiClose -------------------------------
demoGuiClose(){
exit()
}
;-------------------------------- showWindow --------------------------------
showWindow(textnumber := "init", text := ""){
  global text1
  global text2
  global text3
  global text4
  global text5
  global text6
  global button1
  global button2
  global button3
  global button4
  global button1s
  global button2s
  global button3s
  global button4s
  global button5
  global button6
  global simulateMultitasking
  global task2HasMsgbox
  

  if (textnumber == "init"){
    gui,demo:destroy
    gui,demo:new
    gui,demo:font,s12, Calibri
    gui,demo:add, text, Vtext1 w500
    gui,demo:add, text, Vtext2 w500
    gui,demo:add, text, Vtext3 w500
    gui,demo:add, text, Vtext4 w500
    gui,demo:add, text, Vtext5 w500
    gui,demo:add, text, Vtext6 w500
    
    gui,demo:add, button, Vbutton1 Gtask1Start xm w300,Task1 every 1 seconds
    gui,demo:add, button, Vbutton1s Gtask1Stop x+m yp+0,Stop
    gui,demo:add, button, Vbutton2 Gtask2Start xm w300,Task2 every 4 seconds
    gui,demo:add, button, Vbutton2s Gtask2Stop x+m yp+0,Stop
    gui,demo:add, button, Vbutton3 Gtask3Start xm w300,Task3 every 6 seconds
    gui,demo:add, button, Vbutton3s Gtask3Stop x+m yp+0,Stop
    gui,demo:add, button, Vbutton4 Gtask4Start xm w300,Task4 every 10 seconds
    gui,demo:add, button, Vbutton4s Gtask4Stop x+m yp+0,Stop
    gui,demo:add, button, Vbutton5 GsimulateMultitaskingToggle xm w300, % simulateMultitasking?"Simulating Multitasking":"Not simulating Multitasking"
    gui,demo:add, button, Vbutton6 Gtask2InsertMsgbox xm w300,% task2HasMsgbox?"Remove msgbox from Task 2":"Insert msgbox in Task 2"
    
    gui, demo:add, StatusBar, 0x800 hWndhMainStatusBarHwnd
    SB_SetParts(500)
    SB_SetText("Pause: Capslock, exit: Ctrl + c (hold)")
    gui,demo:show, autosize y10 xCenter
  } else {
    guicontrol, demo:, text%textnumber%,%text%
  }

  return
}
;------------------------ simulateMultitaskingToggle ------------------------
simulateMultitaskingToggle(){
  global simulateMultitasking
  
  simulateMultitasking := !simulateMultitasking
  guicontrol,Text,button5,% simulateMultitasking?"Simulating Multitasking":"Not simulating Multitasking"

  ; reset
  ; scheduler("",0,true)
  ; showwindow("init")
  
  return
}

;----------------------------- task2InsertMsgbox -----------------------------
task2InsertMsgbox(){
  global task2HasMsgbox

  task2HasMsgbox := !task2HasMsgbox
  guicontrol,Text,button6,% task2HasMsgbox?"Remove msgbox from task 2":"Insert msgbox in task 2"
    
  return
}
;-------------------------------- task1Start --------------------------------
task1Start(){
  task1(1)
  return
}
task2Start(){
  task2(4)
  return
}
task3Start(){
  task3(6)
  return
}
task4Start(){
  task4(10)
  return
}
;--------------------------------- task1Stop ---------------------------------
task1Stop(){
  task1(0)
  return
}
task2Stop(){
  task2(0)
  return
}
task3Stop(){
  task3(0)
  return
}
task4Stop(){
  task4(0)
  return
}
;----------------------------------- task1 -----------------------------------
task1(run := ""){
  static waitticks := 0
  static task1Run := 0
  global speedscale
  
  if (run == "0"){
    task1Run := 0
    scheduler("task1", -1)
    showWindow("3", "Task1 finished!")
    return
  }
  if (run != "0" && run != ""){
    waitticks := 0 + run * speedscale
    task1Run := 1
    scheduler("task1", getsetCounter() + waitticks)
    showWindow("3","Task 1 activated, every " . waitticks . " seconds, next at: " . (getsetCounter() + waitticks))
    return
  }
  if (run == ""){
    if (task1Run > 0){
      showWindow("3", "Task 1 event occured, as every " . waitticks . " seconds, counter is: " . getsetCounter())
      ; task1Run += 1
      scheduler("Task1", getsetCounter() + waitticks) ; run again
    }
  }
  return
}
;----------------------------------- task2 -----------------------------------
task2(run := ""){
  static waitticks := 0
  static task2Run := 0
  global task2HasMsgbox
  global speedscale
  
  if (run == "0"){
    task2Run := 0
    scheduler("task2", -1)
    showWindow("4", "Task2 finished!")
    return
  }
  if (run != "0" && run != ""){
    waitticks := 0 + run * speedscale
    task2Run := 1
    scheduler("task2", getsetCounter() + waitticks)
    showWindow("4","Task 2 activated, every " . waitticks . " seconds, next at: " . (getsetCounter() + waitticks))
    return
  }
  if (run == ""){
     if (task2Run > 0){
      showWindow("4", "Task 2 event occured, as every " . waitticks . " seconds, counter is: " . getsetCounter())
      scheduler("task2", getsetCounter() + waitticks)
      ; task2Run += 1
      if (task2HasMsgbox){
        msgbox,1, Question,Task 2 shows this messagebox and is stopped therefor!`nWatch other Tasks (Multitasking on/off)!`n`n Continue task 2?
        IfMsgBox, OK
        {
          scheduler("task2", -1)
          showWindow("4","Task2 reactivated, next event at: " . (getsetCounter() + waitticks))
          scheduler("task2", getsetCounter() + waitticks) ; run again
        } else {
          task2Run := 0
          scheduler("task2", -1)
          showWindow("4", "Task2 finished!")
        }
      } else {
        scheduler("task2", getsetCounter() + waitticks) ; run again
      }
    }
  }
  return
}
;----------------------------------- task3 -----------------------------------
task3(run := ""){
  static waitticks := 0
  static task3Run := 0
  global speedscale
  
  if (run == "0"){
    task3Run := 0
    scheduler("task3", -1)
    showWindow("5", "Task3 finished!")
    return
  }
  if (run != "0" && run != ""){
    waitticks := 0 + run * speedscale
    task3Run := 1
    scheduler("task3", getsetCounter() + waitticks)
    showWindow("5","Task 3 activated, every " . waitticks . " seconds, next at: " . (getsetCounter() + waitticks))
    return
  }
  if (run == ""){
    if (task3Run == 1){ ; no action yet
      showWindow("5", "Task3 first event occured, as every " . waitticks . " seconds, counter is: " . getsetCounter())
      task3Run += 1
      scheduler("task3", getsetCounter() + waitticks) 
    }
    if (task3Run > 1){ ; trigger on 2nd++ only
      showWindow("5", "Task3 event occured, as every " . waitticks . " seconds, counter is: " . getsetCounter())
      task3Run += 1
      scheduler("task3", getsetCounter() + waitticks) ; run again
    }
  }
  return
}
;----------------------------------- task4 -----------------------------------
task4(run := ""){
  static waitticks := 0
  static task4Run := 0
  global speedscale
  
  if (run == "0"){
    task4Run := 0
    scheduler("task4", -1)
    showWindow("6", "Task4 finished!")
    return
  }
  if (run != "0" && run != ""){
    waitticks := 0 + run * speedscale
    task4Run := 1
    scheduler("task4", getsetCounter() + waitticks)
    showWindow("6","Task4 activated, every " . waitticks . " seconds, next at: " . (getsetCounter() + waitticks))
    return
  }
  if (run == ""){
    if (task4Run == 1){ ; no action yet
      showWindow("6", "Task4 no event triggered, on this first run!")
      scheduler("task4", getsetCounter() + waitticks)
      task4Run += 1
    }
    if (task4Run > 1){ ; trigger on 2nd++ only
      showWindow("6", "Task4 event occured, as every " . waitticks . " seconds, counter is: " . getsetCounter())
      task4Run += 1
      scheduler("task4", getsetCounter() + waitticks) ; run again
    }
  }
  return
}
;------------------------------- getsetCounter -------------------------------
getsetCounter(value := ""){
  static counter := 0
  
  Critical, On
  if (value != "")
    counter := 0 + value

  return counter
}
;--------------------------------- heartbeat ---------------------------------
heartbeat(run := ""){
  global textheartbeat
  global speedscale
  
  ticker := -1 * floor(1000/speedscale)
 
  if (getkeystate("Ctrl","P") == 1) && getkeystate("c","P") == 1{
    scheduler("",0,true)
    return
  }
  
  if (getkeystate("Capslock","T") == 1){
    showWindow("1", "Timing-Counter: paused!")
  } else {
    getsetCounter(getsetCounter() + 1)
    showWindow("1", "Timing-Counter " . Format("{1:010}",getsetCounter()) . ", speedscale is: x " . speedscale . "  [mem used: " . GetProcessMemoryUsage() . " MB]")
    scheduler()
  }
  if (run != "")
    return
    
   settimer,heartbeat, %ticker%, 10000
  
  return
}
;---------------------------------- scheduler ----------------------------------
scheduler(taskName := "", counterUntil := 0, closeall := false){
  global textscheduler
  global simulateMultitasking
  
  static schedulerList := {}
  
  if (closeall){
    for name in schedulerList {
      %name%("0")
    }
    showWindow("2", "scheduler tasks: " . Format("{1:02}", 0))
  } else {
    if (taskName != ""){
      if (counterUntil < 0){
        schedulerList.delete(taskName)
      } else {
        schedulerList[taskName] := counterUntil
        tasks := 0
        for key, value in schedulerList
        {
          tasks += 1
        }
        showWindow("2", "scheduler tasks: " . Format("{1:02}", tasks))
      }
    } else {
      tasks := 0
      if (simulateMultitasking){
        for key, value in schedulerList
        {
          if (getsetCounter() >= value){
            schedulerList.delete(key)
            settimer,%key%, -1
          }
          tasks += 1
        }
      } else {
        for key, value in schedulerList
        {
          if (getsetCounter() >= value){
            schedulerList.delete(key)
            %key%()
          }
          tasks += 1
        }
      }
        
      if (tasks == 0){
        showWindow("1", "Heartbeat: no tasks, reset counter to: " . Format("{1:010}",getsetCounter("0")))
        sleep,2000
      } else {
        showWindow("2", "scheduler tasks: " . Format("{1:02}", tasks))
      }
    }
  }
  
  return
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage(){

  OwnPID := DllCall("GetCurrentProcessId")
  static PMC_EX := "", size := NumPut(VarSetCapacity(PMC_EX, 8 + A_PtrSize * 9, 0), PMC_EX, "uint")

  if (hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", OwnPID)) {
    if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
      if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
        return (ErrorLevel := 2) & 0, DllCall("CloseHandle", "ptr", hProcess)
    DllCall("CloseHandle", "ptr", hProcess)
    return Round(NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") / 1024**2, 2)
  }
  return (ErrorLevel := 1) & 0
}

;------------------------------- debuggerCode -------------------------------
;------------------------------- getTimeStamp -------------------------------
getTimeStamp(){
    FormatTime, TimeString, %A_Now%, yyyy MM dd HH:mm:ss tt
    return TimeString
}
;--------------------------------- dbgClear ---------------------------------
dbgClear(){
  ; call after gui exists!
  currentWin := WinExist("A")
  if (WinExist("ahk_class dbgviewClass")){
      WinActivate,ahk_class dbgviewClass
      WinWaitActive,ahk_class dbgviewClass,,10
      ; debugger clear-screen
      SendInput,{Control Down}x{Control Up}
      WinActivate,ahk_id %currentWin%,,10
      WinWaitActive,ahk_id %currentWin%,,10
  }
   return
} 
;------------------------------- consoleWrite -------------------------------
consoleWrite(t := ""){
  ;console output
  FileAppend %t%, *
  return
}
;--------------------------------- dbgWrite ---------------------------------
dbgWrite(t := ""){
  ;debug output
  OutputDebug, %t%
  return
}
;----------------------------------- exit -----------------------------------
exit(){
  heartbeat(0)
  showWindow("1", "Closing the app, by by!")
  showWindow("2", "Closing the app, by by!")
  showWindow("3", "Closing the app, by by!")
  showWindow("4", "Closing the app, by by!")
  showWindow("5", "Closing the app, by by!")
  showWindow("6", "Closing the app, by by!")
  sleep,2000
  exitApp
  
  return
}












