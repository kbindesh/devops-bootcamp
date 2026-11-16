# Static Code Analysis with `SonaQube`

- Official Documentation
  - https://docs.sonarsource.com/sonarqube-cloud

## 01. SonarQube - Fundamentals & Architecture

### What is _SonarQube_?

- _SonarQube_ is an open-source platform for continuous inspection of code quality and security

- It supports over 50 programming languages.
- It is a static application security testing (SAST) and code quality tool that catches bugs, vulnerabilities, and code smells early in the SDLC (Software Development Life Cycle).

### Core Architecture

- **SonarQube Server**
  - Consists of a Web Server (UI), Compute Engine (processes analysis reports), and an internal database (PostgreSQL, MS SQL, Oracle) to store metrics and history.

- **SonarQube Scanner**
  - A lightweight CLI or plugin tool installed on build agents to scan source code and send results to the server.

### SonarQube - Key Metrics & Concepts

### SonarQube Editions

- **SonarQube Server**
  - https://www.sonarsource.com/products/sonarqube/server/

- **SonarQube Cloud**
  - https://www.sonarsource.com/products/sonarqube/cloud/

## 02. Lab: Setup SonarQube

Here is the step-by-step process to get your cloud account running and connected to your repositories:

1. Navigate to the SonarCloud Login Page (https://sonarcloud.io/login).

2. Select the primary DevOps platform where your code is hosted, i.e GitHub &rarr; Enter GitHub credentials &rarr; Authorize SonarCloud.

## 03. Lab: Create _Organization_ and _Project_

### Create the Organization (manually)

1. Log in to your SonarQube Cloud Console (https://sonarcloud.io/login).

2. In the top-right corner of the interface, click on the ➕ (plus) icon menu and select **Create new organization**.

3. On the setup page, ignore the main third-party platform buttons (GitHub, GitLab, etc.). Instead, click the **create one manually** hyperlink located right below the import buttons.
4. Fill out the organization details:
   - **Name**: Give your organization a recognizable display name
   - **Key**: This is a unique identifier used in your URLs and configurations (e.g., my-custom-org-key)
   - **Select your plan**: Free
   - Click **Create Organization**
   - Your new manual organization will open automatically.

### Create the Project Manually (manually)

Once your organization is created, you can initialize an unbound, manual project within it:

1. ➕ (plus) icon again and select Analyze new project.
2. Choose the newly created _organization_ from your list &rarr; Click **create a project manually**.
3. Configure your project settings:
   - **Project Key**: Provide a unique string identifying this project.
   - **Display Name**: Enter the readable name for the project dashboard
   - **Visibility**: Set the project to Public or Private (Private requires a paid organization plan).

4. Click Set up or **Create project**.

## 03. Quality Gates, Quality Profiles and Rules

Let's break them down step-by-step from the ground up.

### Rule (The Inspection Manual)

Rules are the individual, granular coding standards, best practices, and security guidelines that SonarQube checks your code against.

- **The Analogy**
  - Think of **SonarQube Rules** as individual lines in a Kitchen Health & Safety Manual.
  - For example: "All chefs must wash hands for 20 seconds".
- **The Concept**
  - **SonarQube** has thousands of out-of-the-box rules for different programming languages (Java, Python, JavaScript, etc.). They look for:
    - **Bugs**: Code that will break or behave unexpectedly (e.g., a null pointer exception).
    - **Vulnerabilities**: Security flaws that hackers could exploit (e.g., hardcoded passwords).
    - **Code Smells**: Messy code that works but is hard to maintain (e.g., duplicated code or overly complex functions).

- **Example**
  - _Language_: Java
  - _Rule_: "Variables should not be just declared that are never used."
  - _Why?_: It wastes memory and confuses other developers.

### Quality Profiles (The Custom Menu & Recipe Standards)

A Quality Profile is a collection of specific Rules tailored for a particular programming language.

- **The Analogy**
  - A bakery and a konkani restaurant have different safety priorities.
  - The konkani restaurant needs strict rules about raw fish texure& temperature; the bakery cares about flour dust and oven safety.
  - A **Quality Profile** is the specific checklist chosen for that specific type of kitchen.
- **The Concept**
  - You don't always want to enforce every single rule SonarQube offers.
  - For a critical financial microservice, you want ultra-strict security rules.
  - For a quick internal prototype, you might turn off some minor formatting rules.
  - A **Quality Profile** allows you to activate or deactivate specific rules and set their severity (_Blocker, Critical, Major, Minor, Info_).

- **Example**
  - You create a **Quality Profile** named FinTech-App-Java-Profile.
  - Inside it, you activate all Security Vulnerability Rules as "_Blocker_", but change the formatting/naming convention rules to "_Minor_".

### Quality Gates (The Final Verdict)

A **Quality Gate** is the final pass/fail criteria that determines whether your code is good enough to be merged into production.

- It answers the question: "Did this code meet our organization's minimum quality threshold?"

- **The Analogy**
  - Even if a restaurant breaks a _minor rule_ (like a slightly scuffed floor tile), the inspector might still let them open.
  - But if they fail a _major rule_ (like having rats in the kitchen), the inspector shuts them down immediately.
  - The **Quality Gate** is the final scorecard: "If you get a score lower than 90%, or have even 1 major health violation, you FAIL."

- **The Concept**
  - In DevOps, the **Quality Gate** is the ultimate gatekeeper in your CI/CD pipeline.
  - If the code passes the **Quality Gate**, the pipeline continues to deployment.
  - If it _fails_, the pipeline stops immediately, preventing bad code from reaching your users.

- **Example**
  - A typical Quality Gate definition might look like this:
    - _New Bugs must be 0_.
    - _Code Coverage on new code must be greater than 80%_.
    - _Duplicated Lines on new code must be less than 3%_.

### Putting it All Together: The DevOps Workflow Example

Let's trace how these three concepts work together when a developer pushes code:

```
[Developer pushes Code]
          │
          ▼
[SonarQube Scanner runs] ───► Uses the [Quality Profile] (Looks up the specific Rules)
          │
          ▼
[Finds 4 Bugs & 79% Coverage]
          │
          ▼
[Evaluates against Quality Gate] ───► Gate says: "Min 80% Coverage required"
          │
          ▼
[RESULT: QUALITY GATE FAILED] ───► CI/CD Pipeline breaks 🛑 (Code is blocked from production)
```

1. Developer _Bindesh_ writes a Python script and creates a Pull Request (PR).

2. The Jenkins/GitHub Actions pipeline triggers a SonarQube scan.
3. SonarQube looks at the language (Python) and pulls the designated **Quality Profile** (Company-Standard-Python).
4. It checks Bindesh's code against all the Rules activated in that profile. It finds a hardcoded API key (a critical security rule violation).
5. SonarQube compares the overall results against the **Quality Gate**. Because the **Quality Gate** is configured to fail if any new vulnerabilities are introduced, the Quality Gate Fails.
6. The CI/CD pipeline turns red, blocks the merge, and alerts Bindesh to fix the API key before trying again.

## 03. Maven Integration (Build-Time Analysis)

### Step-XX: Setup SonarQube Organization & Project

- Project Name: `<sonarqube-project-name>`
- Organization Name: `<sonarqube-org-name>`
- Organization Key: `<sonarqube-org-key>`

### Step-XX: Generate SonarQube Access Token

To authenticate your Maven plugin execution securely without using your account password, you need an access token.

- Sign-in to your SonarQube Cloud Account &rarr; Click on User Setting button (top-right corner) &rarr; My Account.

- Select **Access Token** &rarr;
  - **Token Name**: maven-app
  - **Expires in**: 30 days

- Copy the generated token string immediately and save it somewhere secure &rarr; Click **Continue**.

### Step-XX: Configure your `pom.xml` for _SonarQube Integration_

- Open your _pom.xml_ file &rarr; Add the following properties into the `<properties>` block of your _pom.xml_:

```xml
<properties>
    <!-- Core Java settings (Ensure these match your actual JDK version) -->
    <maven.compiler.source>21</maven.compiler.source>
    <maven.compiler.target>21</maven.compiler.target>

    <!-- SonarQube Cloud Configurations -->
    <sonar.host.url>https://sonarcloud.io</sonar.host.url>
    <sonar.organization>your_sonarcloud_organization_key</sonar.organization>
    <sonar.projectKey>my-maven-archetype-app</sonar.projectKey>
</properties>
```

### Step-XX: Configure your `pom.xml` with _JaCoCo Maven plugin_ to generate a coverage report

To bind JaCoCo (Java Code Coverage) to this setup, you need to configure the JaCoCo Maven plugin to generate a coverage report before the Sonar scanner runs.

- SonarQube Cloud will automatically look for this report file and import the code coverage metrics seamlessly.

- Open your _pom.xml_ file and add the _JaCoCo plugin_ configuration inside the <build><plugins> block.
- This configuration ensures that JaCoCo hooks into your test execution phases automatically.

```xml
<project>
    <!-- ... existing configuration ... -->

    <build>
        <plugins>
            <!-- JaCoCo Maven Plugin Integration -->
            <plugin>
              <groupId>org.jacoco</groupId>
              <artifactId>jacoco-maven-plugin</artifactId>
              <version>0.8.12</version>
              <executions>
                  <!-- Prepares the property pointing to the JaCoCo runtime agent -->
                  <execution>
                      <id>prepare-agent</id>
                      <goals>
                          <goal>prepare-agent</goal>
                      </goals>
                  </execution>
                  <!-- Creates the coverage report after tests run -->
                  <execution>
                      <id>report</id>
                      <phase>test</phase>
                      <goals>
                          <goal>report</goal>
                      </goals>
                  </execution>
              </executions>
          </plugin>
        </plugins>
    </build>
</project>
```

How this configuration works:

1. prepare-agent
   - This goal runs before your unit tests start. It initializes a Java agent that observes which lines of code are executed during your test phase (mvn test).
2. report
   - This goal runs during the verify phase. It collects the raw execution data and generates an XML report file located at target/site/jacoco/jacoco.xml.
3. Auto-Detection
   - The SonarQube Maven plugin is smart. By default, it automatically looks into the target/site/jacoco/jacoco.xml path to parse your test coverage, so you don't even need to add extra properties pointing to the file

### Step-XX: Add SonarScanner plugin in pom.xml

- By explicitly declaring the plugin inside your project's `<build>` block, Maven registers the short prefix sonar for this specific project.

- Open your `pom.xml` and add this inside your `<plugins>` block (right next to the JaCoCo plugin you just added):

```xml
<build>
    <plugins>
        <!-- JaCoCo plugin here... -->

        <!-- Add this so you can use 'sonar:sonar' -->
        <plugin>
            <groupId>org.sonarsource.scanner.maven</groupId>
            <artifactId>sonar-maven-plugin</artifactId>
            <!-- Lock a version to prevent breaking changes -->
            <version>5.8.0.7211</version>
        </plugin>
    </plugins>
</build>
```

### Step-XX: Run the Maven Scan Command

- JaCoCo is now bound to the Maven lifecycles (test and verify), it will inject itself, execute your tests, write the coverage report, and pass it to SonarQube Cloud in one sweep:

```bash
mvn clean verify sonar:sonar -Dsonar.token=your_copied_secret_token
```

### Step-XX: View Your Review Results

- Once the command finishes executing, you will see a BUILD SUCCESS message in your console.
- In the very bottom of the log output, Maven will print a direct URL linking to your project report dashboard.

- Click that link or head back to your browser on SonarQube Cloud to view your bugs, code smells, and structural security ratings.

## 04. Jenkins CI/CD Pipeline Integration
