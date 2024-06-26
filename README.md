# PowerShell File Integrity Monitor

This PowerShell script is designed to monitor files in a specified directory for changes, deletions, and new additions. It can also create and manage a baseline of file hashes for comparison.


https://github.com/Kmac907/File-Integrity-Monitor/assets/120307903/1d5b87f4-e381-4566-9411-0f3696ba25a3


## Functions
- `Calculate-File-Hash`: Calculates the hash of a file using the SHA512 algorithm.
- `Erase-Baseline-If-Already-Exists`: Checks if a baseline file exists and deletes it if it does.
- `Initialize-LogFile`: Initializes a log file for monitoring activities.

## Changing Monitored Folder

To change the folder that the monitor is watching for file changes, follow these steps:

1. Open the PowerShell script in a text editor.
2. Locate the lines where the `Get-ChildItem` cmdlet is used to retrieve files in the current monitoring directory(Line 47):

   ```powershell
   $files = Get-ChildItem -Path .\Files
3. Modify the -Path parameter to specify the desired directory. For example, to monitor files in the "Documents" directory, you would change it to:

   ```powershell
   $files = Get-ChildItem -Path .\Documents
4. Scroll further down the script to find any other instances where the monitoring directory is referenced. For instance, on line 80:
   ```powershell
   $currentFiles = Get-ChildItem -Path .\Files | Select-Object -ExpandProperty FullName
5. Update the -Path parameter in this line to match the directory you specified in step 3.
   ```powershell
   $currentFiles = Get-ChildItem -Path .\Documents | Select-Object -ExpandProperty FullName
6. Save the changes to the script.
   Keep in mind that these are RELATIVE paths. If the directory you are monitoring is not in the same directory as the script. Be sure to specify the full path(recommended), or put the script in the same directory as the one you are monitoring(not recommended) 

## Script Execution
- Prompts the user to choose between collecting a new baseline (option A) or beginning file monitoring with a saved baseline (option B).

### Option A: Collect New Baseline
- Erases the existing baseline file, if it exists.
- Retrieves a list of files from the specified directory.
- Calculates the hash of each file and appends it to the baseline file.
![baseline](https://github.com/Kmac907/File-Integrity-Monitor/assets/120307903/8c43cc80-a316-4fcb-900c-cd8469bfadb4)
![hash](https://github.com/Kmac907/File-Integrity-Monitor/assets/120307903/9c231197-0b13-4ef6-810f-3fab9b147d5b)

### Option B: Begin Monitoring with Saved Baseline
- Initializes a log file for monitoring activities.
- Loads the baseline file hashes into a dictionary.
- Enters an infinite loop to continuously update another dictionary with hash values.
  - Basline hash dictionary and monitoring hash dictionary are compared every second.
  - If file integrity is compromised, information is logged along with the actions in the monitoring log file.
![monitoring](https://github.com/Kmac907/File-Integrity-Monitor/assets/120307903/9961f8fc-6934-4aa1-a906-5b8cbee2e6bd)
![log](https://github.com/Kmac907/File-Integrity-Monitor/assets/120307903/5758883e-e27f-4ac8-81b5-06c53622022f)

## Data Structures and Algorithms
- **Dictionary**: A hashtable (`$fileHashDictionary`) used to store file paths and their corresponding hashes for efficient lookup and comparison.
- **SHA512 Algorithm**: Utilized for calculating the hash of files, ensuring data integrity and security.
- **Error Handling**: Try-catch blocks are implemented to handle exceptions gracefully, providing informative error messages to the user.

This script provides a robust solution for monitoring files in a directory, detecting any changes made to them, and maintaining a record of these activities for auditing purposes.

