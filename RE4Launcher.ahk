#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Mengatur jalur direktori tujuan dan symlink
saveGameDir := A_ScriptDir . "\_JulianNizah_\SaveGame"
targetDir := "%PUBLIC%\Documents\EMPRESS\2050650\remote\2050650\remote\win64_save"
symlinkName := "win64_save"

; Membuat perintah mklink
command := "cmd.exe /c mklink /D """ . saveGameDir . "\" . symlinkName . """ """ . targetDir . """"

; Menjalankan perintah mklink melalui Command Prompt
RunWait, %command%,, Hide


; Mendapatkan jalur lengkap ke file settings.ini
settingsFilePath := A_ScriptDir . "\_JulianNizah_\settings.ini"

; Menjalankan perintah CMD untuk mendapatkan alamat IP
RunWait, cmd.exe /c ipconfig | findstr IPv4 > ip.txt,, Hide
FileRead, ipFile, ip.txt
StringSplit, ipLines, ipFile, `n
Loop, %ipLines0%
{
    ipLine := ipLines%A_Index%
    if InStr(ipLine, "IPv4") {
        IPAddress := RegExReplace(ipLine, ".*:\s*([^ ]+).*", "$1")
        break
    }
}
FileDelete, ip.txt

; Menyimpan alamat IP ke file settings.ini
if (IPAddress != "") {
    IniWrite, %IPAddress%, %settingsFilePath%, General, ipClient
}

; Membaca alamat IP dari file settings.ini
IPAddress := ""
IniRead, IPAddress, %settingsFilePath%, General, ipClient

; Menambahkan angka setelah titik terakhir ke SteamID
if (IPAddress != "") {
    LastDigit := RegExReplace(IPAddress, ".*\.(\d+)$", "$1")
    SteamIdPrefix := "76561199760110"
    FormattedLastDigit := Format("{:03}", LastDigit)

    SteamId := SteamIdPrefix . FormattedLastDigit

    ; Menulis ke file steam_api64.ini
    IniWrite, 2050650, steam_api64.ini, Settings, AppId
    IniWrite, %SteamId%, steam_api64.ini, Settings, SteamId
    IniWrite, 0, steam_api64.ini, Settings, Offline
    IniWrite, 47584, steam_api64.ini, Settings, ListenPort
    IniWrite, english, steam_api64.ini, Settings, Language
    IniWrite, %A_UserName%, steam_api64.ini, Settings, UserName
    IniWrite, 0, steam_api64.ini, Settings, UnlockAllDLCs

    ; Membaca nama dari file settings.ini
    IniRead, launcherName, %settingsFilePath%, General, LauncherName
    IniRead, steamApiDir, %settingsFilePath%, General, SteamApiDir

	; Menampilkan splash screen
	Gui, +E0x20 -Caption
	Gui, Add, Picture, x0 y0 w800 h258, _JulianNizah_\Image\splash.png

	; Mendapatkan ukuran layar
	SysGet, MonitorWorkArea, MonitorWorkArea
	GuiWidth := 800
	GuiHeight := 258

	; Menghitung posisi layar tengah
	GuiX := (MonitorWorkAreaRight - GuiWidth) / 2
	GuiY := (MonitorWorkAreaBottom - GuiHeight) / 2

	; Memindahkan jendela ke posisi tengah layar
	WinMove, %launcherName%,, GuiX, GuiY

	; Versi Launcher
	version := 1.4

	; Author
	authorname := "JulianNizah"

	; Membuat teks watermark
	WatermarkText := "Created by: " . authorname
	Gui, Font, s10 cWhite, Arial Bold
	Gui, Add, Text, x10 y230 w780 h20 Center BackgroundTrans, %WatermarkText%
	Gui, Show, x0 y0 h258 w800, %launcherName% Launcher %version%

    ; Memindahkan jendela ke posisi tengah layar
    WinMove, %launcherName%,, GuiX, GuiY

    ; Tunggu selama 5 detik (5000 milidetik)
    Sleep, 5000

	; Menjalankan game dan menunggu sampai selesai
	Run, re4.exe, , , gameProcessID
	Process, Wait, %gameProcessID%
	
	; Tunggu selama 3 detik (2000 milidetik)
    Sleep, 5000
	
	; Menutup splash screen
	Gui, Destroy

	; Menjalankan perintah setelah game selesai
	ExitApp
}
