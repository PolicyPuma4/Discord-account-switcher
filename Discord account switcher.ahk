; Made by https://github.com/PolicyPuma4/Discord-account-switcher
; Repository https://github.com/PolicyPuma4/Discord-account-switcher

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include TrayIcon.ahk
#Persistent
#SingleInstance Force

EnvGet, A_LocalAppData, LocalAppData
global A_LocalAppData := A_LocalAppData


ProcessExist(ProcessName)
{
	Process, Exist, %ProcessName%
	return ErrorLevel
}


;~ Close Discord gracefully if it is running
CloseDiscord()
{
	if ProcessExist("Discord.exe")
	{
		if not WinExist("ahk_exe Discord.exe")
		{
			TrayIcon_Button("Discord.exe")
			WinWait, ahk_exe Discord.exe
		}
		WinActivate, ahk_exe Discord.exe
		WinWaitActive, ahk_exe Discord.exe
		ControlSend,, {Alt down}{F4 down}{F4 up}{Alt up}, ahk_exe Discord.exe
		Process, WaitClose, Discord.exe
	}
}


RefreshTray()
{
	Menu, Tray, DeleteAll
	Menu, Tray, Add
	FileRead, ActiveAccount, %A_LocalAppData%\Programs\Discord account switcher\Active account.txt
	Loop, Files, %A_LocalAppData%\Programs\Discord account switcher\*, D
	{
		Menu, Tray, Add, %A_LoopFileName%, MenuHandler
		if (A_LoopFileName = ActiveAccount)
		{
			Menu, Tray, Default, %A_LoopFileName%
		}
	}
}


Menu, Tray, Icon, %A_LocalAppData%\Discord\app.ico
IfNotExist, %A_LocalAppData%\Programs\Discord account switcher
{
	FileCreateDir, %A_LocalAppData%\Programs\Discord account switcher\Account 1
	FileCreateDir, %A_LocalAppData%\Programs\Discord account switcher\Account 2
	FileAppend, Account 1, %A_LocalAppData%\Programs\Discord account switcher\Active account.txt
}
RefreshTray()
return

MenuHandler:
FileRead, ActiveAccount, %A_LocalAppData%\Programs\Discord account switcher\Active account.txt
if (A_ThisMenuItem = ActiveAccount)
{
	if ProcessExist("Discord.exe")
	{
		if not WinExist("ahk_exe Discord.exe")
		{
			TrayIcon_Button("Discord.exe")
		}
		else
		{
			WinActivate, ahk_exe Discord.exe
		}
	}
	else
	{
		Run, %A_AppData%\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk
	}
}
else
{
	CloseDiscord()
	FileRemoveDir, %A_LocalAppData%\Programs\Discord account switcher\%ActiveAccount%
	FileMoveDir, %A_AppData%\discord, %A_LocalAppData%\Programs\Discord account switcher\%ActiveAccount%
	FileMoveDir, %A_LocalAppData%\Programs\Discord account switcher\%A_ThisMenuItem%, %A_AppData%\discord
	FileCreateDir, %A_LocalAppData%\Programs\Discord account switcher\%A_ThisMenuItem%
	FileDelete, %A_LocalAppData%\Programs\Discord account switcher\Active account.txt
	FileAppend, %A_ThisMenuItem%, %A_LocalAppData%\Programs\Discord account switcher\Active account.txt
	RefreshTray()
	Run, %A_AppData%\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk
}
return
