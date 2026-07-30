# Git and GitHub

In this section, you will learn how git works and it's core concepts. It covers the following Git and GitHub topics:

- Git Flow

- Branches
- Branching Strategies
- Resolving Merge Conflicts
- GitHub
- GitHub Pull Request
- GitHub Webhooks
- GitHub Releases and Tags

## 01. What are Version Control Systems (VCS)?

- Version Control Systems (VCS) and Git are tools that track changes to files over time, allowing you to recall specific versions later and collaborate with others.

## 02. What is `Git`?

- `Git` is a distributed version control system designed to track changes in files and coordinate work among multiple people.

- Unlike older centralized systems, with Git every developer has a complete copy of the project history on their local computer.

- Understanding Git requires mastering its localized architecture (Stages) and how teams organize their work (Workflows like Git Flow).

## 03. Git Architecture Stages

Your files live in one of four distinct zones as you write, save, and share code:

```
Working Directory ] -------- git add -------> [ Staging Area ]

        |                                              |
    (Changes)                                      (Prepared)

        |                                              |
        <------------ git checkout/switch -------------+--------- git commit --------> [ Local Repository ]
                                                                                               |
                                                                                           (Snapshots)
                                                                                               |
                                                                                           git push
                                                                                               v
                                                                                       [ Remote Repository ]
```

### 3.1 Working Directory (Untracked / Modified)

- This is your local project directory where you actively add, edit, or delete files.
- Changes here are not tracked by Git until you explicitly ask it to.

### 3.2 Staging Area (Index)

- A temporary preparation zone.
- When you run `git add`, you take a snapshot of specific changes and put them here, deciding exactly what goes into your next save point.

### 3.3 Local Repository (Committed)

- When you run `git commit`, Git permanently stores the staged snapshot inside a hidden _.git_ folder on your hard drive.
- Every commit gets a unique cryptographic hash ID.

### 3.4 Remote Repository (Shared)

- A hosted version of your project on platforms like GitHub, GitLab, or Bitbucket.
- Running `git push` uploads your local commits so team members can access them.

## 🌿What is Git Branch?

- A branch is a lightweight, moveable pointer to a specific snapshot (commit) of your code.
- It creates an isolated timeline where you can write code freely without impacting the primary code baseline.

### Structure of a Git Branch

Every time you save your work (commit), Git creates a snapshot of your files and links it to the previous commit (the parent).

- The _Pointer_
  - A branch is just a label pointing to the latest commit in a given timeline.
- The _HEAD_ Pointer
  - Git uses a special internal pointer called HEAD to keep track of which branch you are currently working on.
- The _Lineage_
  - When you make a new commit, Git creates the new snapshot, links it back to its parent, and automatically moves the current branch pointer (and HEAD) forward to this new commit.

### Create a Branch

### Switch to another Branch

### Merge a branch

## 🌿Git Branching Strategies

### Git Flow Strategy

### GitHub Flow Strategy

### Trunk-Based Development (TBD) Strategy

## What is Git "detached HEAD" state?

- A Git "_detached HEAD_" state occurs when your HEAD pointer points directly to a specific commit hash rather than to a branch label.

- In normal Git operations, HEAD points to a branch (like main), and the branch points to a commit.
- When HEAD is detached, the branch middleman is removed.

### How It Happens?

You enter a _detached HEAD_ state anytime you **checkout** or **switch** to something that is not a local branch.

- Checking out a specific commit `git checkout <commit-id>` (e.g., git checkout 7a3f2b1)

- Checking out a tag
  `git checkout v1.0.0`
- Checking out a remote branch
  `git checkout origin/main` (without tracking it locally)

### How to Fix or Exit?
