# Hands-on Lab: Configure local system for pushing the Application Code to GitHub securely

- Official Documentation: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

## Prerequisites

- GitHub Account
- Maven Project (tested locally)

## Step-01: Create a GitHub Repository

- Sign into your account on [GitHub.com](https://github.com/).
- Select **Repositories** tab -> Click on **New** button.
  - **Repository Name**: Enter a short, memorable Repository name (e.g. sample-maven-project)
  - **Description**: Sample Maven project
  - **Choose Visibility**: Private
  - Leave rest of the field (license, readme etc.) to defaults.

## Step-02: Authenticate local Git repository with GitHub using SSH Keys

### 2.1: Create the Custom Directory and Generate the Key

- Launch VS Code -> View Terminal -> Git Bash.
- Run the following commands to create your custom folder and generate a highly secure Ed25519 SSH key:

```bash
# 1. Create your custom directory (if it doesn't already exist)
mkdir -p /c/GitKeys

# 2. Generate the key directly into your custom folder with a blank passphrase
ssh-keygen -t ed25519 -C "your_email@example.com" -f /c/GitKeys/github_custom_key -N ""

# The -N "" flag automatically skips the passphrase prompt so you do not have to hit enter manually

# For Email address to use, navigate to GitHub Account -> Settings -> Emails
```

### 2.2: Configure the SSH Config File

- Because your key uses a custom name and location, Git needs an explicit instruction to find it.
- You must add it to your local SSH configuration file.
- Run this command in _Git Bash_ to open or create the config file using the built-in Nano text editor:

```bash
nano ~/.ssh/config

# Paste the following configuration block into the window. Ensure you use standard absolute paths (/c/...) for Git Bash compatibility

Host github.com
  HostName github.com
  User git
  IdentityFile /c/GitKeys/github_custom_key
```

To save and exit Nano

- Press Ctrl + O and hit Enter to save the file.
- Press Ctrl + X to exit the editor.

### 2.3: Add the Public Key to GitHub

- You must only share your public key (.pub) with GitHub.
- Run this command to copy the entire public key text directly to your Windows clipboard:

```bash
clip < /c/GitKeys/github_custom_key.pub
```

- Log into your GitHub account.
- Click your profile photo in the top-right corner and select **Settings**.
- In the left sidebar menu, click **SSH and GPG keys**.
- Click the green **New SSH key** button.
  - Title: dev-pc
  - Leave **Key type** as "Authentication Key"
  - Click into the Key box and paste (Ctrl + V) your clipboard contents.
- Click **Add SSH key**.

### 2.4: Test the Connection

- Verify that _Git Bash_ successfully routes your connection through your custom file path:

```bash
ssh -T git@github.com

# If the connection succeceeds, you will the following message:
# Hi <Github-Username>! You've successfully authenticated, but GitHub does not provide shell access.
```

## Step-03: Commit the changes locally and Check-in the code to GitHub

- Switch to your local system -> Open VS Code -> Open your Maven project you created in the [Develop Maven Project](./1-develop-mvn-project.md) lab.

- View menu &rarr; Terminal &rarr; Git Bash &rarr; Run the following commands to commit and push the changes to github:

```bash
git init

git add .

git commit -m "Initial Commit"

git remote add origin git@github.com:username/repository-name.git

git branch -M main

git push -u origin main
```

## Step-04: Verify the App Code on GitHub

- Switch to your GitHub repository and verify if you've recieved the code.
