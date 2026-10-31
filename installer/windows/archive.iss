; Build via tool/build_windows.ps1. Keep AppId and user-data locations stable.
#ifndef AppVersion
  #error AppVersion must be supplied
#endif
#ifndef AppBuild
  #error AppBuild must be supplied
#endif
#ifndef SourceDir
  #error SourceDir must be supplied
#endif
#ifndef OutputDir
  #error OutputDir must be supplied
#endif

[Setup]
AppId={{D06872CE-DFD6-4D97-9B8B-C06E2B91EBE7}
AppName=Archive
AppVersion={#AppVersion}
AppVerName=Archive {#AppVersion}
VersionInfoVersion={#AppVersion}.{#AppBuild}
DefaultDirName={localappdata}\Programs\Archive
DefaultGroupName=Archive
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
DisableProgramGroupPage=yes
DisableDirPage=auto
UninstallDisplayIcon={app}\archive_flutter.exe
SetupIconFile=..\..\archive_flutter\windows\runner\resources\app_icon.ico
OutputDir={#OutputDir}
OutputBaseFilename=Archive-Setup-{#AppVersion}-{#AppBuild}-x64
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no
SetupMutex=ArchiveWindowsSetup

[Languages]
Name: "uk"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "Створити ярлик на робочому столі"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
; Only the installer's own asset tree. Never delete AppData or the whole app dir.
Type: filesandordirs; Name: "{app}\data\flutter_assets"

[Icons]
Name: "{userprograms}\Archive"; Filename: "{app}\archive_flutter.exe"
Name: "{userdesktop}\Archive"; Filename: "{app}\archive_flutter.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\archive_flutter.exe"; Description: "Відкрити Архів"; Flags: nowait runasoriginaluser

[Code]
function OpenProcess(DesiredAccess: LongWord; InheritHandle: Boolean; ProcessId: LongWord): THandle;
  external 'OpenProcess@kernel32.dll stdcall';
function WaitForSingleObject(Handle: THandle; Milliseconds: LongWord): LongWord;
  external 'WaitForSingleObject@kernel32.dll stdcall';
function CloseHandle(Handle: THandle): Boolean;
  external 'CloseHandle@kernel32.dll stdcall';

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ProcessId: Integer;
  Handle: THandle;
begin
  Result := '';
  ProcessId := StrToIntDef(ExpandConstant('{param:ARCHIVEPID|0}'), 0);
  if ProcessId > 0 then begin
    Handle := OpenProcess($00100000, False, ProcessId);
    if Handle <> 0 then begin
      try
        if WaitForSingleObject(Handle, 60000) <> 0 then begin
          Result := 'Закрийте Архів і запустіть встановлення ще раз.';
          Exit;
        end;
      finally
        CloseHandle(Handle);
      end;
    end;
  end;
  if CheckForMutexes('Local\ArchiveDesktopD06872CE') then
    Result := 'Закрийте Архів перед встановленням оновлення.';
end;
