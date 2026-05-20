# Install and Configure `Git`

In this section, we will learn following topics:

_1. Install and Configure Git on Linux_

_2. Install and Configure Git on Windows_

## 01. Install and Configure `Git` on Linux

### 1.1 Install `Git`

- Install Git on Amazon Linux/CentOS/RHEL

  ```
  sudo yum install -y git
  OR
  sudo dnf install -y git
  ```

- For installing Git on other linux distributions, kindly refer this link: https://www.git-scm.com/download/linux

### 1.2 Verify the `Git` installation

- On terminal, run following command to check if the _git_ is properly installed on the system:

```
# Display the current installed version of the Git
git --version
```

### 1.3 Configure Git

- To configure Git, you must define some global variables:
  1. **user.name**
  2. **user.email**
- Both are required for you to make commits.

```
# Replace <USER_NAME> with the user name
git config --global user.name "<USER_NAME>"

# Replace <USER_EMAIL> with your e-mail address
git config --global user.email "<USER_EMAIL>"
```

- You may run the following command to check all the git variables (including email and name):

```
git config --list
OR
git config -l

# You must see "user.name" and "user.email" variables updated with your details
```

## 02. Install and Configure `Git` on Windows

### 2.1 Download, Install and Configure Git

- Download the Git binary from https://git-scm.com/download/win
- Once the executable is download, click on it to launch the installation.

### 2.2 Verify the Git installation

- In order to check if the Git is properly installed navigate to **Start menu** >> **Command Prompt**

```
git --version

# Above command should give you current installed version of the Git; something like this
git version 2.41.0.windows.3
```

### 2.3 Configure Git

- To configure Git, you must define some global variables:
  1. **user.name**
  2. **user.email**
- Both are required for you to make commits.

```
# Replace <USER_NAME> with the user name
git config --global user.name "<USER_NAME>"

# Replace <USER_EMAIL> with your e-mail address
git config --global user.email "<USER_EMAIL>"
```

- You may run the following command to check all the git variables (including email and name):

```
git config --list
OR
git config -l

# You must see "user.name" and "user.email" variables updated with your details
```

## 03. git config and git help

### 3.1 Set default editor for git using `git config`

- With _git config_ command, you can tell Git to set your preferences and settings.
- For more details, you may refer https://git-scm.com/book/en/v2/Appendix-C%3A-Git-Commands-Setup-and-Config

### 3.2 Get help aroung git commands - git help

```
# Syntax
git help <command>
```
