# Apache Maven

## Setting-up _Apache Maven_

### Prerequisites

- Java ( jdk 21 or above) - https://www.oracle.com/in/java/technologies/downloads/

- Visual Studio Code (IDE) - https://code.visualstudio.com/download

### Setup Maven on Windows 11

For setting-up apache maven on windows 11, kindly follow this official download link: https://maven.apache.org/download.cgi

#### Step-01: Download and Configure Maven

- Navigate to [Apache Maven](https://maven.apache.org/download.cgi) official download page and download the Apache maven _Binary zip_ archive file.

- Unzip/extract the downloaded **apache-maven-3.x.x-bin.zip** file.
- Create a new folder **c:\binaries** and move the extracted sub-folder i.e `apache-maven-3.x.x` in it.

- The updated location of Apache Maven utility would be `c:\binaries\apache-maven-3.x.x`

#### Set Environment variables for Maven and Java

- We need to set the following three environment variables:
  1. M2_HOME
  2. M2
  3. PATH
  4. JAVA_HOME (optional)

- On your system, navigate to Start Menu >> Search **Edit the system environment variables** >> **Advanced** tab >> Click on **Environment Variables** button >> Under **System variables** section.
  - **M2_HOME** variable
    - Variable Name = `M2_HOME`
    - Variable Value = `c:\binaries\apache-maven-3.x.x`

  - **M2** variable
    - Variable Name = `M2`
    - Variable Value = `%M2_HOME%\bin`

  - **PATH** variable
    - Double click on **Path** variable to edit it &rarr; Click on **New** button
    - Paste the location of _Maven_ bin directory: `%M2_HOME%\bin`

#### Install VS Code extensions for Maven

1. [Extension Pack for Java](https://marketplace.visualstudio.com/items/?itemName=vscjava.vscode-java-pack)
2. [Maven for Java](https://marketplace.visualstudio.com/items/?itemName=vscjava.vscode-maven)

#### Test the above setup

- Launch VS Code >> **View** menu >> **Terminal** >> Run the following commands:

```bash
# Check installed version of Java
java --version

# Check installed version of Apache Maven
mvn --version
```

### Setup Maven on MacOS

```bash
brew install maven
```

- Alternatively, you can use sdk install maven via SDKMAN!

### Setup maven on Linux/Unix Systems

- **Using Package Managers**

```bash
# On Ubuntu/Debian
sudo apt update && sudo apt install maven -y

# On Fedora / RHEL / CentOS
sudo dnf install maven -y
```

- **Manual Installation**

If you prefer to install a specific version or don't want to use package managers, follow these steps:

- Go to the [Apache Maven Download Page](https://maven.apache.org/download.cgi) and download the _Binary tar.gz_ archive file.
- Open your terminal and extract the archive to your preferred directory (typically /opt or /usr/local):
  ```bash
  sudo tar -xvf apache-maven-*.tar.gz -C /opt
  ```
- Configure Environment Variables

  ```bash
  # Update the bash profile with Maven path
  vi ~/.bash_profile

  # Create M2_HOME and M2 variable with maven location specs
  M2_HOME=/opt/apache-maven-3.x.x
  M2=/opt/apache-maven-3.x.x/bin

  # Update the PATH variable | Add Maven path
  PATH=$PATH:$M2_HOME:$M2

  [Save the file and exit]

  source ~/.bash_profile

  # Verify the PATH with java and maven variables
  echo $PATH
  ```

## Apache Maven - Key concepts

### The Foundations - Directory Structure & Files

In Apache Maven, the way you organize your project files matters.

- Maven uses a concept called Convention over Configuration. This means it provides a standard, pre-made blueprint for where files should go.

- If you follow this blueprint, Maven automatically knows how to build, test, and package your software without you having to write complex configuration scripts.
- When you create a standard Maven project, the folder layout looks like this:

```
my-app/
├── pom.xml
└── src/
    ├── main/
    │   ├── java/
    │   └── resources/
    └── test/
        ├── java/
        └── resources/
```

#### The Core File: `pom.xml`

- The pom.xml (Project Object Model) file lives at the absolute root of your project directory.

- It defines your project's name, version, and dependencies (external libraries your project needs, like a database driver or a utility tool).
- Instead of downloading .jar files manually, you list them here, and Maven downloads them for you automatically.

#### 📂 `src/` - The Source Folder

- The src (source) folder contains all the code and assets that you actually write.
- It is strictly split into two main buckets:
  1. main (your actual application)
  2. test (your testing code)

- `src/main/java/` - The Source Code
  - This is where your actual Java source code files (.java) go.
  - You must organize them inside their package folders (e.g., com/example/myapp/Main.java).

- `src/main/resources/`
  - This holds non-Java files that your code needs to run.
  - Examples include configuration files (.properties, .yml), database scripts, or images.
  - When Maven builds your app, everything here is copied directly into the final package.

#### 📂 `src/test/` - The Test Code (e.g. Unit Tests)

- None of this code is included when you ship your app to users.

- `src/test/java/`
  - This is where your unit tests (like JUnit or TestNG classes) live.
  - For example, if you have Calculator.java in src/main/java, you will put CalculatorTest.java here.

- `src/test/resources/`
  - This holds files needed only during testing.
  - For example, a mock dataset or a special test configuration file.

#### `target/` - The output folder

- Once you run a Maven command to compile or build your project (like mvn package), Maven automatically creates a new folder at the root level called `target/`.
- It stores compiled Java .class files and the final packaged version of your application (like a .jar or .war file).

### Repositories

- Think of an _Apache Maven Repository_ as a giant, structured digital warehouse for Java libraries (JAR files).

- When building a Java application, you often need third-party code—like code to connect to a database or run unit tests.
- Instead of manually downloading these files from websites and pasting them into your project folder, Maven manages them automatically using **Repositories**.

#### The Three Types of Maven Repositories

- Maven uses three layers of repositories to find and store your project files.
- It checks them in a specific order:
  1. Local Repository

  2. Central Repository

  3. Remote Repository

### Build Lifecycles and Phases

#### The 3 Built-in Lifecycles
Maven comes with three standard lifecycles, each handling a distinct job:
  1. Default (Build): The main assembly line. It handles compiling, testing, packaging, and deploying your application.
  2. Clean: Wipes out previous build outputs (like deleting the target/ directory) so you start fresh.
  3. Site: Generates HTML project documentation and reports.

#### Key Phases of the Default Lifecycle

The Default lifecycle has over 20 phases, but in real-world DevOps pipelines, you will interact with these 7 core phases 99% of the time:

| Order | Phase    | What Happens at This Station                                                       | DevOps Pipeline Context                                                        |
| ----- | -------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| 1     | validate | Checks if pom.xml is valid and all required project info is present.               | Fails fast if configuration syntax is broken.                                  |
| 2     | compile  | Translates human-readable .java source code into .class bytecode.                  | Catches syntax and compilation errors early.                                   |
| 3     | test     | Runs unit tests (using frameworks like JUnit) against the compiled code.           | Stops the pipeline immediately if a unit test fails.                           |
| 4     | package  | Bundles compiled code into a distributable format (e.g., .jar or .war).            | Creates the artifact ready for containerization (Docker) or staging.           |
| 5     | verify   | Runs integration tests and quality checks on the packaged artifact.                | Often integrated with tools like SonarQube for code quality gates.             |
| 6     | install  | Copies the packaged artifact into your local machine's repository (~/.m2).         | Allows other local projects on the same build agent to use it as a dependency. |
| 7     | deploy   | Pushes the final artifact to a remote repository (e.g., Nexus, JFrog Artifactory). | Makes the release available to other teams and production servers.             |

#### How Plugins Fit In (Goals)

Phases are just empty placeholders; Plugins do the actual work. Every phase is bound to one or more plugin goals.
- For example, during the compile phase, Maven triggers the maven-compiler-plugin:compile goal.
- You can also run a plugin goal directly without triggering a lifecycle phase (e.g., mvn sonar:sonar to run a SonarQube scan).

## Hands-on Labs

### Lab-01: Create a sample Maven Project

### Lab-02: Add a dependency (like JUnit), see it download into ~/.m2

### Lab-03: Run mvn test and mvn package to watch the build lifecycle execute sequentially

### Lab-04: Configure authentication to push that package to a shared server
