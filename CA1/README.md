# CA1 Technical Report


## GIT  Alternative

### Mercurial Version Control
Mercurial is a distributed revision control tool designed for software developers. 
It was initially released on April 19, 2005, and is supported on various operating systems, including Microsoft Windows, Linux, and macOS.

Mercurial's primary goals include high performance, scalability, decentralization, and robust handling of both plain text and binary files. 
It also offers advanced branching and merging capabilities while maintaining conceptual simplicity.

### 1. Setup and Installation

To install Mercurial, follow the instructions below based on your operating system:

#### Windows
``` bash
winget install Mercurial.Mercurial -e
```

#### Linux
``` bash 
apt install mercurial
```

### 2. Prepare Mercurial
Setting up developer's name on Mercurial. 
For that open the file ~/.hgrc (or mercurial.ini in your home directory for Windows) with a text-editor and add the ui section (user interaction) with your username:

``` 
[ui]
username = Mr. Johnson <johnson@smith.com>
````

### 3. Initialize the project
Now add the working directory to the repository:

``` bash
hg init project
```

### 4. Add files and track them
To add files to the repository, use the `hg add` command:

``` bash
hg add
````

### 5. Commit changes
To commit changes to the repository, use the `hg commit` command with a descriptive message:

``` bash

hg commit -m "Initial commit"
```
Just like Git, Mercurial uses a commit message to describe the changes made in that commit.
### 6. View commit history
To view the commit history, use the `hg log` command:

``` bash
hg log
```
### 7. Create and switch branches
To create a new branch, use the `hg branch` command followed by the branch name:

``` bash
hg branch new-feature
```
To switch to an existing branch, use the `hg update` command followed by the branch name:

``` bash
hg update new-feature
```
### 8. Merge branches
To merge changes from one branch into another, first switch to the target branch and then use the `hg merge` command followed by the source branch name:

``` bash
hg update main
hg merge new-feature
```
### 9. Push changes to a remote repository
To push changes to a remote repository, use the `hg push` command:

``` bash
hg push
```
### 10. Pull changes from a remote repository
To pull changes from a remote repository, use the `hg pull` command:

``` bash
hg pull
```
### Conclusion
Mercurial is a powerful and flexible version control system that offers many features similar to Git.


Students:
- Student 1: Délcio Monjane, 1211739
- Student 2: Leila Boaze, 1240470

