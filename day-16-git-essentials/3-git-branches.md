# Git Branches

## 01. What are Branches?

- Git branches are lightweight, movable pointers to commits that allow developers to diverge from the main line of development to work on new features or bug fixes in isolation.

- git branches keeps the main codebase stable and enables multiple people to work on a project simultaneously without interfering with each other's work.

### git branch - Key Concepts

- **Isolation**
  - Changes made on a branch do not affect other branches until they are merged.

- **Lightweight**
  - Creating and switching branches in Git is nearly instantaneous, which encourages developers to use them frequently, even for small changes.
- **HEAD Pointer**
  - Git uses a special pointer called HEAD to know which branch you are currently working on.
  - When you switch branches, your working directory is updated to reflect the state of that branch's last commit.
- **Merging**
  - Once work on a branch is complete, it can be merged back into a target branch (commonly main) using the git merge command

## 02. The Master branch (or main)

- The default branch name is _master_
- _master_ branch doesn't do anything very special.
- It is just like any other branch
- Many people designate master branch as a single source of truth
- In 2020, GitHub renamed the default branch from _master_ to _main_.
- The default git branch is still _master_.

## 03. What is HEAD?

- HEAD is simply a pointer that refers to the current "location" in the repository.
- It points/refers to a particular branch reference.

## 04. Working with the `Branches`

### View all the Branches - `git branch`

```
git branch
```

### Create & Switch Branches - `git branch <BRANCH_NAME>`

- **Create a Branch**

```
# Syntax - To create a new branch
git branch <BRANCH_NAME>
OR
git checkout <BRANCH_NAME>

# Examples
git branch development
git branch bugfix


# Create a branch & switch to it
git switch -c <BRANCH_NAME>
git switch -c integration

OR

git checkout -b <BRANCH_NAME>
git checkout -b integration
```

- **Switch to other branch** - `git switch` & `git checkout`

```
# Method-01: Switch to other git branch using 'git switch'
git switch <BRANCH_NAME_TO_SWITCH_TO>



# Method-02: Switch to other git branch using 'git checkout'
git checkout <BRANCH_NAME_TO_SWITCH_TO>
```

## 05. Deleting and Renaming Branches

- **Delete a Branch**

```
# Delete a Branch
git branch -d <BRANCH_NAME_TO_DELETE>
OR
git branch --delete <BRANCH_NAME_TO_DELETE>



# Forcefully deleting a branch if there is any dependencies
git branch -d <BRANCH_NAME> --force

OR

git branch -d <BRANCH_NAME> -D
```

- **Renaming a Branch** - `-m`

- IMP: To rename a branch you have to be on that branch.

```
# Switch to the branch you want to rename
git checkout <BRANCH_NAME>

# Rename the branch
git branch -m <BRANCH_NAME>
```

## 06. Switching Branches with unstaged changes

- The _git stash_ command temporarily saves your uncommitted (unstaged and staged) changes, allowing you to switch branches with a clean working directory and return to your work later.

### Example Scenario

- Initialize a repository and make an initial commit on the `master` branch:

```
mkdir git-example
cd git-example
git init
touch README.md
git add .
git commit -m "initial commit"
```

- Create and switch to a new branch called `feature-branch`:

```
git switch -c feature-branch
```

- Create a new file README.md and add some contents to it on the `feature-branch`:

```
echo "Adding new feature details." >> README.md

# Check the status | 'README.md' is modified but unstaged
git status
```

- Attempt to switch back to `master` branch

```
git switch master
```

- Since README.md on master branch has no changes that would conflict with your local modification (both are based on the initial version, and your changes are only local), Git allows the switch.
  - The switch will be successful.
  - When you check the contents of README.md on the master branch, you will still see the "Adding new feature details." line.
  - Your unstaged changes have been carried over.

- While Git often allows switching branches with unstaged changes, it can lead to confusion (e.g., unintentionally committing changes meant for one branch onto another). The recommended ways is to:
  1. Commit your changes
  2. Stash your changes
  3. Create a new branch with changes

## 07. Commonly used git Branch commands

```
# List all the local Branches
git branch

# List all local and remote branches
git branch -a

# Create a new branch from the currenly pointing branch
git branch <branch-name>

# Switch to a branch
git switch <branch-name>
OR
git checkout <branch-name>

# Create and switch to a new branch simultaneously
git switch -c <new-branch-name>
OR
git checkout -b <new-branch-name>

# Rename a local branch
git branch -m <old-branch-name> <new-branch-name>

# Delete a local branch | fails if unmerged
git branch -d <branch-name>
OR
# Delete a local branch | force delete
git branch -D <branch-name>

# Delete a remote branch
git push origin --delete <branch-name>
```
