# Resolving Merge Conflicts

- A _Git merge conflict_ occurs when two branches being merged have different changes to the same lines in a file, or when one branch modifies a file that the other branch deletes.

- Git cannot automatically decide which change to keep, so it pauses the merge process and requires a developer to resolve the conflict manually.

## Lab: How a `Merge Conflict` happens and how to resolve it?

- Consider a file named `team_contact_info.txt` on a master branch, with the following content:

```
# Initialize the repository
git init

# Create a new file and add some content to it
echo "If you have questions, please contact our support team." > team_contact_info.txt

# Stage the changes and commit
git add team_contact_info.txt
git commit -m "Initial contact info"
```

- Now, _developer1_ creates a his new branch called `dev1-update` and make changes to the same file `team_contact_info.txt`:

```
# Developer1 creates a new branch from master
git branch dev1-update

# Switch to dev1-update branch
git switch dev1-update

# Edit the file | change the line to "If you have questions, please open an issue."
echo "If you have questions, please open an issue." > team_contact_info.txt

# Stage the changes and commit
git add team_contact_info.txt
git commit -m "Update contact info for dev1 suggestion"
```

- _Developer2_ creates another branch called 'dev2-update' form orignal master branch:

```
git checkout master

git branch dev2-update

git switch dev2-update

# Edit the file | change the line to "If you have questions, please open an issue."
echo "If you have questions, please open an issue." > team_contact_info.txt

# Stage and Commit the changes
git add team_contact_info.txt
git commit -m "Update contact info for dev2 suggestion"
```

- Now, developer1 tries to merge dev2-update branch in dev1-branch:

```
git switch dev1-branch

git merge dev2-branch

[Git will output a message indicating a merge conflict:

Auto-merging team_contact_info.txt
CONFLICT (content): Merge conflict in team_contact_info.txt
Automatic merge failed; fix conflicts and then commit the result.]
```

### Resolving the Conflict

- Developer1 must manually edit the file to resolve the conflict. He decides to incorporate both suggestions into a single, cohesive sentence:

```
If you have questions, please open an issue or ask your question in IRC if it's more urgent.
```

- State the file and commit
