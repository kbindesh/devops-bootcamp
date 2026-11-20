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

#### The POM and `pom.xml` file

- Think of the Maven POM (Project Object Model) as the blueprint and single source of truth for a Java project.
- In the DevOps world, we don’t manually click "Build" in an IDE—we automate everything on build servers like Jenkins, GitLab CI, or GitHub Actions.
- The `pom.xml` is the exact instruction manual those automated runners read to understand what the code is, what libraries it needs, how to test it, and how to package it for deployment.

- The `pom.xml` (Project Object Model) file lives at the absolute root of your project directory.

- It defines your project's name, version, and dependencies (external libraries your project needs, like a database driver or a utility tool).
- Instead of downloading .jar files manually, you list them here, and Maven downloads them for you automatically.

1. Project Coordinates (The "GAV")
   - Every artifact built in a pipeline needs a unique identity so it can be stored in an artifact repository (like Nexus, JFrog Artifactory, or AWS CodeArtifact) without overwriting something else.
   - We call this GAV:
     1. groupId: Usually your organization's reverse domain name (e.g., com.company.payments)
     2. artifactId: The specific name of the application or microservice (e.g., billing-service).
     3. version: The release version (e.g., 1.0.0-SNAPSHOT for active development, or 1.0.0 for production releases).
2. Dependencies (The Supply Chain)
   - Instead of committing heavy .jar files into Git, developers list the external libraries their code relies on inside the `<dependencies>` block.
   - How it works in CI?: When your pipeline runs mvn package, Maven checks a local cache on the build agent. If the library isn't there, it reaches out to Maven Central (or your company's internal Nexus/Artifactory) and downloads it automatically.
   - DevOps Tip: You can control when a dependency is used via <scope>. For example, <scope>test</scope> ensures testing libraries like JUnit aren't bundled into your final production artifact, keeping your Docker images lean.
3. Build & Plugins (The Automation Engine)
   - The `<build>` section tells Maven how to compile, test, and package the code. Maven itself is mostly a framework; the actual heavy lifting is done by Plugins.
   - Packaging (<packaging>): Defines the final output—usually a .jar (for microservices/Spring Boot) or a .war (for traditional web servers like Tomcat).
   - Plugins: Tools like the maven-compiler-plugin (sets the Java version), maven-surefire-plugin (runs unit tests and generates reports for your CI dashboard), or jib-maven-plugin (builds Docker images directly without needing a Dockerfile).

4. Anatomy of a Basic pom.xml

```xml
<project xmlns="http://apache.org">
    <modelVersion>4.0.0</modelVersion>

    <!-- 1. GAV Coordinates -->
    <groupId>com.devops.training</groupId>
    <artifactId>user-api</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <!-- 2. Variables -->
    <properties>
        <java.version>21</java.version>
    </properties>

    <!-- 3. External Libraries -->
    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <!-- 4. Build Instructions & Plugins -->
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

5. Why This Matters for Your Day-to-Day DevOps Work?
   - When a build breaks in Jenkins or GitHub Actions, 80% of the time, the answer is in the **pom.xml**.
   - Whether it's a version mismatch between the build agent's JDK and the POM's `<java.version>`, a missing repository credential in **settings.xml** failing to pull a dependency, or a failing test plugin, knowing how to read this file lets you troubleshoot pipelines without waiting on a Java developer.


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

### Verify Prerequisites

- Before generating a project, ensure your Windows 11 machine has Java (JDK) and Maven installed and added to your System PATH.

```bash
java -version

mvn -version

# Both commands should return version numbers
```

### Lab-01: Create a sample Maven Project

- Instead of manually creating folders and writing a pom.xml from scratch, we use a Maven Archetype (a project template).
- Navigate to a clean workspace folder (e.g., Desktop or C drive):

```bash
cd C:\

mkdir mvn-project

cd mvn-project

# Open mvn-project directory in visual studio code
code .
```

- Demonstrate the Build Lifecycle Phases

```bash
# validate (Checks project structure) | Maven reads the pom.xml to verify the XML syntax is valid and all required project info is present
mvn validate

# compile (Translates Java code to Bytecode) | Maven runs validate first, then compiles src\main\java\...\App.java | a new target\classes folder has appeared containing App.class
mvn compile

# test (Runs Unit Tests) | Maven runs validate → compile → test-compile → test. It executes the sample unit test in src\test\java\...\AppTest.java
mvn test

# package (Creates the Deployable Artifact) | Runs everything up to test, then bundles the compiled code into the format specified in pom.xml (a .jar file)
mvn package

# You can actually run this built artifact right now on Windows
java -cp target\lifecycle-app-1.0-SNAPSHOT.jar com.devops.demo.App

# install (Publishes to Local Repository) | Runs everything up to package, then copies the .jar into your local machine's Maven cache so other local projects can use it as a dependency
mvn install

# clean (Wipes the Slate Clean) | clean is actually a separate lifecycle. It deletes the entire target\ directory so old build artifacts don't contaminate future builds.
mvn clean

# DevOps Best Practice: Always combine them in your CI scripts (mvn clean package or mvn clean test) to guarantee a fresh build every single time.
```

### Lab-02: Add a dependency (like JUnit), see it download into ~/.m2

### Lab-03: Run mvn test and mvn package to watch the build lifecycle execute sequentially

### Lab-04: Configure authentication to push that package to a shared server
