# Gitch

Niche file managing script for mirroring files structures.

I use it to manually sync with OneDrive.

## Usage

```
GITCH <command> [file/folder name]
```

If no argument is passed, the current folder will be used as the argument.

### Commands

-`CLONE [path]`
    - Copies the specified folder into the current folder and sets up gitch.txt files for other commands.
    - If no path is specified, user input will be prompted for.
-`OPEN [file/folder name]`
    - Opens the corresponding specified file or folder in the mirror using the default program.
-`PULL [file/folder name]`
    - Copies the specified file or folder from the mirror into the current folder.
-`PUSH [file/folder name]`
    - Copies the specified file or folder into the mirror.
    - If the current folder does not exist in the mirror, the folder, and any parent folders that also do not exist, will be made in the mirror.
-`REMOVE [file/folder name]`
    - Deletes the specified file or folder from the mirror.

## Context Menu

On selected files and folders, this will give access to `open`, `pull`, `push`, and `remove`.

Within folders, this will give access to `open`, `pull`, `push`, `remove`, and `clone`.