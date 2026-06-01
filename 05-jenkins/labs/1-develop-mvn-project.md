# Develop a Maven Project

## 01. Prerequisites

- **Java Development Kit (JDK)**
  - Install JDK 21 or higher
  - Official download link: https://www.oracle.com/in/java/technologies/downloads/
  - To verify installation, run `java --version` command on the terminal

- **Environment Variable**
  - Set up **JAVA_HOME** pointing to your JDK installation directory

- **Apache Maven**
  - Official download link: https://maven.apache.org/download.cgi
  - To verify installation, run `mvn --version` command on the terminal

- **IDE** (Visual Studio Code)
  - Official download link: https://code.visualstudio.com/download
  - Install following Extensions:
    1. Extention Pack for Java
    2. Maven for Java

## 02. Step-by-Step Maven Project Development

### Step-2.1: Generate the sample Maven Project Code

- Open VS Code.
- Open the Command Palette by pressing `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS).
  - Type and select **Java: Create Java Project**...
  - **Project Type**: Maven
  - **archetype**: maven-archetype-quickstart
  - **version**: 1.4
  - **groupId**: Your organization's domain name (e.g., com.example).
  - **artifactId**: Your project application name (e.g., demo, myapp).

- Select a local storage folder where VS Code will generate your project directory.

- Press Enter in the integrated terminal to confirm the configuration parameters.

### Step-2.2: Open the Workspace in VS Code

- Navigate to **File** > **Open Folder** and select your newly created project folder.

### Step-2.3: Update the `pom.xml` file for configuring main class

1. **Check Your Main Class name**
   - Open your **App.java** file (in src/ directory) and look at the very first line.

   - If it says `package com.example;`, and your class name is `public class App`, then your **<mainClass>** tag must be `com.example.App`.
   - Case sensitivity matters. Ensure the capitalization matches your code perfectly.

2. **Verify and Update your pom.xml file structure**
   - Open your **pom.xml** file and ensure the `maven-jar-plugin` is placed exactly inside the `<build>` and `<plugins>` tags.
   - Then, add the `<configuration>` block with main class `<mainClass>` details based on the preceding step observation.

   - It should look precisely like this:

     ```xml
     <project>
     <!-- ... other configurations like dependencies ... -->
     <build>
       <plugins>
         <plugin>
           <groupId>org.apache.maven.plugins</groupId>
           <artifactId>maven-jar-plugin</artifactId>
           <version>3.4.2</version>
           <!-- start -->
           <configuration>
             <archive>
               <manifest>
                 <addClasspath>true</addClasspath>
                 <!-- ⚠️ CRITICAL: Ensure this matches your package + class name perfectly -->
                 <mainClass>com.example.App</mainClass>
               </manifest>
             </archive>
           </configuration>
           <!-- end -->
         </plugin>
       </plugins>
     </build>
     </project>
     ```

### Step-2.4: Compile Unit test and Package the Application

- Maven operates on a sequential build lifecycle where executing a later phase automatically runs all preceding phases.

- Because _verify_ occurs after package in this lifecycle, `mvn clean verify` performs everything `mvn clean package` does, plus critical integration tests and quality checks.

  ```
  mvn clean verify
  ```

- On successful execution of the above command, a new directory i.e. **target** will be automatically created in the root of the maven project which will generate compiled version of the program (.class) and the build artifact (.jar)

### Step-2.5: Running the packaged app (.jar file) locally to verify

- Open the VS Code integrated terminal (Ctrl + \`` or Cmd + ``) and execute the standard Java archive command:

```
java -jar target/demo-1.0-SNAPSHOT.jar
```

### Step-2.6: Create a `.gitignore` file to ignore _target_ directory

- In the root directory of your Maven project, create a plaintext file named exactly **.gitignore**.
- Make sure it has no .txt extension.

- Open the file and add the following line and save it:

  ```
  target/
  ```
