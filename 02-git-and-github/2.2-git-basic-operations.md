# Git Basics

## 01. Setup Git Repository (local)

### 1.1 Create a project folder/directory

- Git works by checking for changes to files within a certain _folder or a directory_.
- So let's create a folder to serve as our project directory and let Git know about it, so it can start tracking changes.
- Start by creating an empty folder for your project, and then initialize a Git repository inside it:

  ```
  # Create a folder
  mkdir <DIRECTORY_NAME>

  # Change the directory to our project directory
  cd <DIRECTORY_NAME>
  ```

### 1.2 `Initialize` the project folder as Git repo - `git init`

- Now, initialize your new repository and set the name of the default branch to main:

```
# Initialize a directory as git repo with a default branch created i.e master
git init

# (Optional) To initialize a repo create an initial branch
git init --initial-branch=<NEW_BRANCH_NAME>

# (Optional) Initialize a repo with an initial branch
git init -b <NEW_BRANCH_NAME>
```

- After initializing the repository, you should see output similar to this example:</br></br>

```
Initialized empty Git repository in /home/<user>/repository_name/.git/ </br>
  Switched to a new branch 'main'
```

### 1.3 Check the Git Repository status - `git status`

- Now, use a `git status` command to show the status of the working tree:
- git status gives information on the current status of a git repository and it's contents.

```
git status
```

## 02. Understanding `.git` folder (hidden)

- `git init` command creates an empty repository - basically a `.git` directory (hidden) with subdirectories for objects, refs/heads, refs/tags, and template files.
- An initial branch without any commits will be created.
- If you want to initialize a repo and at the same time create an initial branch, use `--initial-branch` option, as follows:

## 03. `Git Workflow` - Work on stuff >> Stage it >> Commit it

### 3.1 Start a new Project folder/directory

- Create a new folder/directory for application files, say **MyFirstApp**.

### 3.2 Initilize the Repository - `git init`

```
# Get inside above created folder
cd MyFirstApp

# Initialize the directory as a git repo
git init

# (Optional) To initialize a repo create an initial branch
git init --initial-branch=<NEW_BRANCH_NAME>
```

### 3.3 Add the code files to the Project directory

- Create few app files (e.g. html, css) in the project folder and save it.

### 3.4 Check the Status of a Repo - `git status`

```
git status
```

### 3.5 Stage the changes - `git add`

```
# To stage all the untracked changes
git add .

# (Optional) To stage a particular file/s
git add <UNTRACKED_FILE_01_NAME> <UNTRACKED_FILE_02_NAME>
```

### 3.6 (Optional) Unstage the changes - reset | restore | rm

- You can unstage a file in the Git index and undo a _git add_ operation, any of the following three commands will work:
  1. git reset
  2. git restore
  3. git rm

- **Method-01**: Using `git reset`

  ```
  # Undo the last 'git add' and keep changes in the working dir
  git reset --soft HEAD

  # Unstage specific file/s
  git reset <FILENAME_TO_UNSTAGE>

  # Unstage all the changes
  git reset

   # Discard all uncommitted changes in your working directory and staging area and take you to the state of the last commit
  git reset --hard HEAD
  ```

- **Method-02**: (_Recommended_) Using git restore

  ```
  # To unstage a specific file/s
  git restore --staged <FILENAME_TO_UNSTAGE>

  # To unstage all the changes
  git restore --staged .
  ```

### 3.7 Commit the changes - git commit

- Commit the changes which are staged before.

```
git commit -m "Start app development"
```

### 3.8 For getting the list of all the commits - `git log`

```
git log

git log --oneline

git log --all
```

### 3.9 Delete last commit if the commit is only on your local machine (not pushed yet)

```
# To delete the commit but keep the changes in your working directory (unstaged)
git reset HEAD~1
```

### 3.10 Delete last commit if the commit has already been pushed to a remote repository

```
git revert HEAD
git push
```

## Hands-on Excersice - Committing changes using Git

1. Create a new folder called `Shopping`
2. Initialize the `Shopping` folder as a Git repo (make sure you are inside of a Git repo)
3. Create a new file called `yard.txt`
4. Create another new file called `groceries.txt`
5. Commit both the empty files. The message should be "create yard and groceries lists"
6. In the `yard.txt` file, add the following text:

```
- 2 bags of potting soil
- 1 bag of worm castings
```

7. In the groceries.txt file, add the following:

```
- 4 tomatoes
- 6 shallots
- 1 fennel bulb
```

8. Make a new commit, including **ONLY the changes from the `groceries.txt` file.** The commit message should be "add ingredients for tomato soup"
9. Make a second commit including **ONLY the changes to the `yard.txt` file.** It should have the commit message "add items needed for garden box"
10. Next up, add the following line to the end of `groceries.txt`
11. In the yard.txt file, change the first line so that it says "3 bags of potting soil" instead of "2 bags of potting soil"
12. **Make a commit that includes the changes to BOTH files.** The message should read "add items needed to grow potatoes"
13. **Use a Git command to display a list of the commits. You should see 4!**

## 04. One Commit for One type of change - Keep commits Atomic

## 05. Committing the changes using Git GUI Client (GitKraken/SourceTree/GitHub Desktop)

## 06. Modify the most recent commit - `git commit --ammend`
