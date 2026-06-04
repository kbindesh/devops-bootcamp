# Hands-on Lab: Create a simple Freestyle Jenkins Job

## Prerequisites

- Jenkins Server with Admin access

## Step-01: Create a freestyle Jenkins Job

_[ General ] ➔ [ Source Code Management ] ➔ [ Build Triggers ] ➔ [ Build Environment ] ➔ [ Build Steps ] ➔ [ Post-build Actions ]_

### 1.1: Initialize the Job

- Navigate to your Jenkins Dashboard.
- Click **New Item** in the top left menu.
- **Name**: (e.g., prod-web-app-deploy).
- **Project type**: Freestyle project &rarr; click **OK**

### 1.2: General Configuration

- Contains basic properties including the project name, descriptions, and operational constraints like parameterizations.
- `Leave this section to defaults.`

### 1.3: Source Code Management (SCM)

- Defines where Jenkins pulls your application source files.
- It handles credential validation and pulls data from repositories like Git or Subversion.
- `Leave this section to defaults.`

### 1.4: Build Triggers

- Defines the exact events that launch the build task automatically.
- Options include _manual triggers, scheduling via Cron syntax, webhooks,_ or _polling your repository_ for changes.
- `Leave this section to defaults.`

### 1.5: Build Environment

- Configures specialized environments required by the code.
- Examples include injecting environment variables, clearing the workspace, or configuring passwords.

### 1.6: Build Steps

- Executes sequential steps using the underlying system shell or pre-defined tools.
- You can invoke Maven targets, run Windows Batch commands, or execute shell commands (npm install, docker run).

- Click the **Add build step** dropdown menu.
- For Linux/macOS: Select Execute shell.
- In the command text box, enter a simple script to verify it functions properly:

```
whoami
pwd
hostname
echo "Hello World! The Jenkins job is running successfully."
```

### 1.7: Post-build Actions

- Specifies what happens immediately after the execution phase ends.
- This includes:
  - archiving build logs
  - generating code test reports
  - triggering other jobs
  - utilizing plugins to send email notifications
- `Leave this section to defaults.`

## Step-02: Save and Run the Jenkins Job

- Click **Save** at the bottom of the page to apply the settings.
- On the job's main layout view, click **Build Now** on the left menu to run it manually.

## Step-03: Verify the Jenkins Build status and Logs

- Look at the Build History section on the lower-left pane.
- Click on the specific _build number_ (e.g., #1) that appears.

- Select **Console Output** from the dropdown menu to see your execution logs and look for a `SUCCESS` confirmation message.
