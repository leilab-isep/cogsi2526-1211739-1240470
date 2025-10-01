# CA1 Technical Report

## Part 2: Branches

### 1. Create a branch named email-field

Create a branch to add support for an email field for a vet

``` bash
git branch email-field
```



### 2. Switch to the email-field branch
Switch to the newly created branch to start working on it.

``` bash
git checkout email-field
```
output:
``` 
PS C:\cogsi2526-1211739-1240470\CA1> git branch email-field
PS C:\cogsi2526-1211739-1240470\CA1> git checkout email-field
M       CA1/README.md
Switched to branch 'email-field'

````

### Commit changes to the email-field branch

```
PS C:\cogsi2526-1211739-1240470\CA1> git add -A
PS C:\cogsi2526-1211739-1240470\CA1> git commit -m "Create a branch named emailField" 
[email-field 13191e7] Create a branch named emailField
 12 files changed, 74 insertions(+), 33 deletions(-)

```

```
PS C:\cogsi2526-1211739-1240470\CA1> git checkout main            
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
PS C:\Users\delci\Documents\ISEP\MEI\2oAno\COGSI\Projects\cogsi2526-1211739-1240470\CA1> git pull
remote: Enumerating objects: 85, done.
remote: Counting objects: 100% (84/84), done.
remote: Compressing objects: 100% (25/25), done.
remote: Total 49 (delta 29), reused 34 (delta 19), pack-reused 0 (from 0)
Unpacking objects: 100% (49/49), 8.74 KiB | 38.00 KiB/s, done.
From https://github.com/leilab-isep/cogsi2526-1211739-1240470
   0d1b22c..b8d0b57  main       -> origin/main
 * [new branch]      dependabot/maven/hibernate.version-7.1.1.Final -> origin/dependabot/maven/hibernate.version-7.1.1.Final
 * [new branch]      dependabot/maven/jakarta.activation-jakarta.activation-api-2.1.4 -> origin/dependabot/maven/jakarta.activation-jakarta.activation-api-2.1.4
 * [new branch]      dependabot/maven/org.hibernate.validator-hibernate-validator-9.0.1.Final -> origin/dependabot/maven/org.hibernate.validator-hibernate-validator-9.0.1.Final
 * [new branch]      dependabot/maven/org.postgresql-postgresql-42.7.8 -> origin/dependabot/maven/org.postgresql-postgresql-42.7.8
 * [new branch]      dependabot/maven/tomcat.version-11.0.11 -> origin/dependabot/maven/tomcat.version-11.0.11
Updating 0d1b22c..b8d0b57
Fast-forward
 .../org/springframework/samples/petclinic/model/Vet.java | 16 ++++++++++------
 .../petclinic/repository/jdbc/JdbcVetRepositoryImpl.java |  2 +-
 CA1/src/main/resources/db/h2/data.sql                    | 12 ++++++------
 CA1/src/main/resources/db/h2/schema.sql                  |  3 ++-
 CA1/src/main/resources/db/hsqldb/data.sql                | 12 ++++++------
 CA1/src/main/resources/db/hsqldb/schema.sql              |  3 ++-
 CA1/src/main/resources/db/mysql/data.sql                 | 12 ++++++------
 CA1/src/main/resources/db/mysql/schema.sql               |  1 +
 CA1/src/main/resources/db/postgresql/data.sql            | 12 ++++++------
 CA1/src/main/resources/db/postgresql/schema.sql          |  1 +
 CA1/src/main/webapp/WEB-INF/jsp/vets/vetList.jsp         |  4 ++++
 11 files changed, 45 insertions(+), 33 deletions(-)
 
PS C:\cogsi2526-1211739-1240470\CA1> git checkout email-field                          
Switched to branch 'email-field'

PS C:\cogsi2526-1211739-1240470\CA1>  git push --set-upstream origin email-field
Enumerating objects: 73, done.
Counting objects: 100% (73/73), done.
Delta compression using up to 16 threads
Compressing objects: 100% (34/34), done.
Writing objects: 100% (39/39), 3.71 KiB | 948.00 KiB/s, done.
Total 39 (delta 23), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (23/23), completed with 20 local objects.
remote: 
remote: Create a pull request for 'email-field' on GitHub by visiting:
remote:      https://github.com/leilab-isep/cogsi2526-1211739-1240470/pull/new/email-field
remote:
To https://github.com/leilab-isep/cogsi2526-1211739-1240470.git
 * [new branch]      email-field -> email-field
branch 'email-field' set up to track 'origin/email-field'.

PS C:\COGSI\Projects\cogsi2526-1211739-1240470\CA1> git push                                   
Everything up-to-date

PS C:\cogsi2526-1211739-1240470\CA1> git checkout main                          
Switched to branch 'main'
Your branch is up to date with 'origin/main'.

PS C:\cogsi2526-1211739-1240470\CA1> git merge email-field
Auto-merging CA1/src/main/java/org/springframework/samples/petclinic/model/Vet.java
CONFLICT (content): Merge conflict in CA1/src/main/java/org/springframework/samples/petclinic/model/Vet.java
Auto-merging CA1/src/main/java/org/springframework/samples/petclinic/repository/jdbc/JdbcVetRepositoryImpl.java
CONFLICT (content): Merge conflict in CA1/src/main/java/org/springframework/samples/petclinic/repository/jdbc/JdbcVetRepositoryImpl.java
Auto-merging CA1/src/main/resources/db/h2/data.sql
CONFLICT (content): Merge conflict in CA1/src/main/resources/db/h2/data.sql
Auto-merging CA1/src/main/resources/db/h2/schema.sql
CONFLICT (content): Merge conflict in CA1/src/main/resources/db/h2/schema.sql
Auto-merging CA1/src/main/resources/db/hsqldb/data.sql
CONFLICT (content): Merge conflict in CA1/src/main/resources/db/hsqldb/data.sql
Auto-merging CA1/src/main/resources/db/hsqldb/schema.sql
CONFLICT (content): Merge conflict in CA1/src/main/resources/db/hsqldb/schema.sql
Auto-merging CA1/src/main/resources/db/mysql/data.sql
CONFLICT (content): Merge conflict in CA1/src/main/resources/db/mysql/data.sql
Auto-merging CA1/src/main/resources/db/mysql/schema.sql
CONFLICT (content): Merge conflict in CA1/src/main/resources/db/mysql/schema.sql
Auto-merging CA1/src/main/resources/db/postgresql/data.sql
CONFLICT (content): Merge conflict in CA1/src/main/resources/db/postgresql/data.sql
Auto-merging CA1/src/main/resources/db/postgresql/schema.sql
CONFLICT (content): Merge conflict in CA1/src/main/resources/db/postgresql/schema.sql
Auto-merging CA1/src/main/webapp/WEB-INF/jsp/vets/vetList.jsp
CONFLICT (content): Merge conflict in CA1/src/main/webapp/WEB-INF/jsp/vets/vetList.jsp
Automatic merge failed; fix conflicts and then commit the result.

PS C:\cogsi2526-1211739-1240470\CA1> notepad "C:\cogsi2526-1211739-1240470\CA1\src\main\resources\db\h2\data.sql"


<<<<<<< HEAD
INSERT INTO vets VALUES (default, 'James', 'Carter', '123456789');
INSERT INTO vets VALUES (default, 'Helen', 'Leary', '987654321');
INSERT INTO vets VALUES (default, 'Linda', 'Douglas', '456789123');
INSERT INTO vets VALUES (default, 'Rafael', 'Ortega', '789123456');
INSERT INTO vets VALUES (default, 'Henry', 'Stevens', '321654987');
INSERT INTO vets VALUES (default, 'Sharon', 'Jenkins', '654987321');
=======
INSERT INTO vets VALUES (default, 'James', 'Carter','JamesCarter@email.com');
INSERT INTO vets VALUES (default, 'Helen', 'Leary','HelenLeary@email.com');
INSERT INTO vets VALUES (default, 'Linda', 'Douglas','LindaDouglas@email.com');
INSERT INTO vets VALUES (default, 'Rafael', 'Ortega','RafaelOrtega@email.com');
INSERT INTO vets VALUES (default, 'Henry', 'Stevens','HenryStevens@email.com');
INSERT INTO vets VALUES (default, 'Sharon', 'Jenkins','SharonJenkins@email.com');
>>>>>>> email-field

```

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

