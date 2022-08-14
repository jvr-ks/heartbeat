; heartbeat.ahk

/*
 Under construction (for later use in ClickAndSleep):
 
 Try to make multible timings (in realm of seconds, 1 tick = 1 second) with only one timer: heartbeat().
 Heartbeat calls itself once a second.
 The only function of heartbeat is to call the function scheduler() once every second.
 Scheduler has a counter and a list of active tasks called "schedulerList".
 Each task has a value and if the counter-reading is equal or higher this value (execution is guaranteed therefore),
 the task specific operations is executed.
 The callback from the scheduler is the function Task-name(), so it does not jump after the scheduler() command
 (an entrypoint inside a function would be nice ...) but a the beginning of the function, with an empty parameter.
 So a switch must be build into the function to jump over part 1 of the function if the parameter is empty
 and the function is called again via the scheduler to execute part 2 then.
 Variables used in both parts must be static or global therefor!
 The function call:
 scheduler("Task-name", value)
 adds a task to the list and removes it, if value is < 0
 This demo uses 2 tasks:
 The first "countDown" has a value of 10, so the task specific operation (continue in program flow) 
 becomes active after 10 ticks, i.e. 10 seconds later,
 the second "displayRemaining" becomes active every 1 tick and just displays the remaining time/ticks.

*/

#NoEnv
#Warn
#SingleInstance Force
#InstallKeybdHook

appName := "heartbeat"
appnameLower := "heartbeat"
appVersion := "0.003"
usedebugger := false

showControlWindow("Init!")

; dbgClear()


heartbeat()

return
;---------------------------- controlGuiGuiEscape ----------------------------
controlGuiGuiEscape(){
  exitApp
}
;---------------------------- controlGuiGuiClose ----------------------------
controlGuiGuiClose(){
  exitApp
}
;----------------------------- showControlWindow -----------------------------
showControlWindow(text := "", delete := false){
  global countDownText
  global buttoncountDownStart
  global buttoncountDownStop
  global buttonExit
  static controlWindowShown := false

  if (delete){
    if (controlWindowShown){
      gui,controlGui:destroy
      controlWindowShown := false
    }
  } else {
    if (!controlWindowShown){
      gui,controlGui:new
      gui,controlGui:font,s12, Calibri
      gui,controlGui:add, text, VcountDownText w500
      gui,controlGui:add, button, VbuttoncountDownStart GcountDownStart xm w300,Test: Sleep (Countdown) 10 seconds
      gui,controlGui:add, button, VbuttoncountDownStop GcountDownStop x+m yp+0,Stop
      gui,controlGui:add, button, VbuttonExit GcontrolGuiGuiClose x+m yp+0,Exit
      
      gui, controlGui:add, StatusBar, 0x800 hWndhMainStatusBarHwnd
      SB_SetParts(500)
      SB_SetText("Pause: Capslock, Cancel: Ctrl + c (hold)")
      gui,controlGui:show, autosize xCenter ycenter
      guicontrol, controlGui:, countDownText, %text%
      controlWindowShown := true
    } else {
      guicontrol, controlGui:, countDownText, %text%
    }
  }
  return
}
;----------------------------- showDisplayWindow -----------------------------
showDisplayWindow(text := "", delete := false){
  global sdwcountDownText
  static displayWindowShown := false

  if (delete){
    if (displayWindowShown){
      gui,displayGui:destroy
      displayWindowShown := false
    }
  } else {
    if (!displayWindowShown){
      gui,displayGui:destroy
      gui,displayGui:new, -Caption +ToolWindow +border +AlwaysOnTop
      gui,displayGui:font,s12, Calibri
      gui,displayGui:add, text, VsdwcountDownText w300
      gui,displayGui:show,xcenter y10
      displayWindowShown := true
      guicontrol,displayGui:,sdwcountDownText,%text%
    } else {
      guicontrol,displayGui:,sdwcountDownText,%text%
    }
  }
  
  return
}
;------------------------- countDownRun -------------------------
countDownRun(continue := false, value := "0"){
  static workcounter := 1
  
  if (!continue){
    loop,3 {
      showControlWindow("Simulate working ..." . workcounter)
      workcounter +=1
      sleep,1000
    }
    showDisplayWindow("Pause 10 seconds")
    countDown(value)
  } else {
    showDisplayWindow("", true)
    loop,3 {
      showControlWindow("Continue working ..." . workcounter)
      workcounter +=1
      sleep,1000
    }
    showControlWindow("Working finished!")
  }
  
  return
}
;------------------------------ countDownStart ------------------------------
countDownStart(){
  global appName
  
  msg := appName . " (" . getTimeStamp() . "): TEST started!"
  dbgWrite(msg)
  countDownRun(false, "10")
  return
}
;------------------------------- countDownStop -------------------------------
countDownStop(){
  countDown("0")
  sleep,2000
  showDisplayWindow("", true)
  return
}
;--------------------------- countDown ---------------------------
countDown(run := ""){
  static waitticks := 0
  
   if (run == "0"){
    ; stop
    countDown := 0
    scheduler("countDown", -1)
    showDisplayWindow("countDown canceled!")
    return
  }
  if (run != "0" && run != ""){
    ; set
    waitticks := 0 + run
    untilCount := getsetCounter() + waitticks
    scheduler("countDown", untilCount)
    displayRemaining(untilCount)
    return
  }
  if (run == ""){
    ; action is continue
    countDownRun(true)
    ; run only once, no scheduler call
  }
  return
}
;----------------------------- displayRemaining -----------------------------
displayRemaining(run := ""){
  static untilCount := 0
  
   if (run == "0"){
    ; stop
    scheduler("displayRemaining", -1)
    return
  }
  if (run != "0" && run != ""){
    ; set
    untilCount := 0 + run
    remainigTicks := untilCount - getsetCounter()
    scheduler("displayRemaining", 1)
    return
  }
  if (run == ""){
    remainigTicks := untilCount - getsetCounter()
    if (remainigTicks <= 0){
      scheduler("displayRemaining", -1)
    } else {
      showDisplayWindow("CountDown: " . remainigTicks)
      scheduler("displayRemaining", 1)
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
heartbeat(){
  global textheartbeat
  
  pollKeyboard()

  ; settimer,heartbeat,delete
  settimer,heartbeat,-1000,10000
  
  return
}
;------------------------------- pollKeyboard -------------------------------
pollKeyboard(){
  if (getkeystate("Ctrl","P") == 1) && getkeystate("c","P") == 1{
    countDownStop()
    scheduler("","",true)
  }
  
  if (getkeystate("Capslock","T") == 1){
    showControlWindow("Heartbeat: paused!")
  } else {
    getsetCounter(getsetCounter() + 1)
    ; showControlWindow("Heartbeat: " . Format("{1:010}",getsetCounter()) . ",  [mem used: " . GetProcessMemoryUsage() . " MB]")
    scheduler()
  }
  return
}
;---------------------------------- scheduler ----------------------------------
scheduler(taskName := "", counterUntil := 0, closeall := false){
  global textscheduler
  
  static schedulerList := {}
  
  if (closeall){
    for name in schedulerList {
      %name%("0")
    }
    ; showControlWindow("scheduler tasks: " . Format("{1:02}", 0))
  } else {
    if (taskName != ""){
      if (counterUntil < 0){
        schedulerList.delete(taskName)
      } else {
      schedulerList[taskName] := counterUntil
      }
    } else {
      tasks := 0
      for key, value in schedulerList
      {
        if (getsetCounter() >= value){
          schedulerList.delete(key)
          settimer,%key%, -1
        }
        tasks += 1
      }
      if (tasks == 0){
        showControlWindow("Heartbeat: no tasks")
        sleep,2000
      }
      ; showControlWindow("scheduler tasks: " . Format("{1:02}", tasks))
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

;------------------------------- debugger Code -------------------------------
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
;--------------------------------- dbgWrite ---------------------------------
dbgWrite(t := ""){
	global usedebugger
	global debuggerconsole

	if (usedebugger){
		OutputDebug, %t%
		if (debuggerconsole){
			FileAppend %t%, *
		}
	}
return
}















