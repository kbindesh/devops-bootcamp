# Git Branch Merging

- Git merging is the process of combining changes from two different branches into one unified history.

- It allows developers to work on new features or bug fixes in isolation and then integrate those changes back into the main codebase

## Lab: Merging a Feature Branch

- In this example, we wills learn how to merge a _feature-branch_ into the _master_ branch:

- Switch to the target branch (the branch you want to merge into, here master):

```
git switch master
```

- Merge the feature branch into the current (master) branch:

```
git merge feature-branch
```

- Resolve conflicts (if any)
  - If both branches changed the same lines in the same file, Git will pause the merge and notify you of a conflict.
  - You must manually edit the conflicted files to choose which changes to keep, then git add the resolved files and run git commit to finalize the merge.
