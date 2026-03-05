# Setting-up environment for `Maven`

- For setting-up Apache Maven on Windows 11, kindly follow this official documentation link: https://maven.apache.org/download.cgi

## 01. Setting-up Maven on Windows system

### Install Java

- Java 21 or above
- As a prerequisite to install Maven, in this section we will install java.
- Before you install Java, kindly check if you already have java installed on your system.
  - Command Prompt/Terminal/Powershell >> Run following command:

  ```
  java --version

  [If you see the current installed version of java, you may continue using it and skip this step]

  [If you see any error, continue the java installation process]
  ```

- **Download Java**
  - https://www.oracle.com/in/java/technologies/downloads/

- Here, I'm installing Java 21
  - https://www.oracle.com/in/java/technologies/downloads/#jdk21-windows
  - Download the `x64 Installer` (.exe) file i.e. https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe and Install.

- As the Java installation completes, kindly launch command prompt/terminal to verify the installation by checking java version:

```
java --version
```

### Download and Configure `Maven`

- Navigate to https://maven.apache.org/download.cgi and download the Latest Maven `Binary zip archive` file e.g. apache-maven-3.9.12-bin.zip

- Extract the downloaded .zip file and and extract it to **C:\binaries** folder

### Set `Environment variables` for Maven and Java

- Navigate to Start Menu >> Search **Edit the system environment variables** >> **Advanced** tab >> Click on **Environment Variables** button >> Under **System variables** section
  - Click on **New** button:
    - **M2 variable**
      - Variable Name = M2
      - Variable Value = C:\Binaries\apache-maven-3.9.12\bin
      - Click _Ok_ button
  - Click on **New** button:
    - **M2_HOME varialble**
      - Variable Name = M2_HOME
      - Variable Value = %M2%\apache-maven-3.9.12
      - Click _Ok_ button
  - Double click on **Path** variable to edit it:
    - Click on **New** button
    - Paste the location of Maven bin directory: C:\Binaries\apache-maven-3.9.12\bin
    - Click _Ok_ button

- Now, to check the Maven installtion, launch command prompt/powershell terminal and check the Maven version:

```
mvn --version

[This command should return installed Maven version]
```

### Install Visual Studio Code (IDE)

- Official Download page: https://code.visualstudio.com/download

- Once the VS Code instanallation completes, launch VS Code and install the following extensions:
  1. [Extension Pack for Java](https://marketplace.visualstudio.com/items/?itemName=vscjava.vscode-java-pack)
  2. [Maven for Java](https://marketplace.visualstudio.com/items/?itemName=vscjava.vscode-maven)

### Test the above setup

- Launch VS Code >> **View** menu >> **Terminal** >> Run the following commands to ensure Java and Maven is accessible from VS Code:

```
# Check installed java version
java --version

# Check configured maven version
mvn --version

[Both the above command should return respective tool versions]
```

## 02. Setting-up Maven on Linux (Amazon Linux) system

## 03. References
