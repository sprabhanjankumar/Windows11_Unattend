================================================================================
CUSTOM WINDOWS 10/11 UNATTENDED ISO CREATION GUIDE
================================================================================

[STEP 1: PREPARE ANYBURN]
* Extract your downloaded .zip file containing the tools.
* Launch Anyburn by running "Anyburn.exe".

[STEP 2: LOAD THE ISO]
* Select "Edit Image File" from the main menu options.
* Browse and select your source Windows 10 or Windows 11 ISO file.
* Click "Next" to open the ISO contents.

[STEP 3: ADD EXTRAS & AUTOMATION FILES]
* Click the "Add" button (or drag and drop files directly into AnyBurn).
* Add your highly configured "Autounattend.xml" file to the root directory.
* Add your "$OEM$" folder to the root directory.
  (Note: The Autounattend.xml will automatically wipe/clean Disk 0 completely).
* Click "Next" when all files are added.

[STEP 4: SAVE THE NEW ISO]
* Select the output destination folder and choose a new name for your ISO.
* Click "Create Now" to build and compile your custom automated ISO.
* Video Reference: https://youtube.com

================================================================================
CRITICAL WINDOWS INSTALLATION RULES (READ BEFORE BOOTING)
================================================================================

1. DISCONNECT INTERNET:
   * Keep your internet disconnected during the initial Windows Setup phase.
   * Do NOT connect to Wi-Fi or plug in your Ethernet cable yet.

2. CONNECT INTERNET AT USER CREATION:
   * Plug in your Ethernet cable or connect to Wi-Fi ONLY when you reach the 
     Username Creation screen.

3. SOFTWARE DEPLOYMENT:
   * Once internet is detected at this stage, 10 to 14 essential programs 
     (Chrome, Edge, VLC, WinRAR, etc.) will automatically install directly 
     into Windows 11.

4. WINDOWS 10 WORKAROUND:
   * Sometimes the direct software installer will fail on Windows 10.
   * If this happens, locate and run the "WinGET.cmd" file provided in your package 
     to complete the software installations manually.
================================================================================
