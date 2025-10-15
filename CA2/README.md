Gradle Basic Demo
===================

This is a demo application that implements a basic multithreaded chat room server.

The server supports several simultaneous clients through multithreading. When a client connects the server requests a screen name, and keeps requesting a name until a unique one is received. After a client submits a unique name, the server acknowledges it. Then all messages from that client will be broadcast to all other clients that have submitted a unique screen name. A simple "chat protocol" is used for managing a user's registration/leaving and message broadcast.


Prerequisites
-------------

 * Java JDK 17
 * Apache Log4J 2
 * Gradle 8.9 (if you do not use the gradle wrapper in the project)
   

Build
-----

To build a .jar file with the application:

    % ./gradlew build 

Run the server
--------------

Open a terminal and execute the following command from the project's root directory:

    % java -cp build/libs/basic_demo-0.1.0.jar basic_demo.ChatServerApp <server port>

Substitute <server port> by a valid por number, e.g. 59001

Run a client
------------

Open another terminal and execute the following gradle task from the project's root directory:

    % ./gradlew runClient

The above task assumes the chat server's IP is "localhost" and its port is "59001". If you whish to use other parameters please edit the runClient task in the "build.gradle" file in the project's root directory.

To run several clients, you just need to open more terminals and repeat the invocation of the runClient gradle task


# CA1 Technical Report

## Part 1: Build Tools

### Adding and Executing the `runServer` Task in Gradle

In this activity, we configured a new Gradle task named **`runServer`** that will call the ChatServerApp class.
It will allow the chat server to be executed directly from the command line instead of running the Java class manually each time.
The task was added to the `build.gradle` file of the project as follows:


```groovy
    task runServer(type:JavaExec, dependsOn: classes){
        group = "DevOps"
        description = "Launches a chat server that connects to a server on localhost:59001 "
    
        classpath = sourceSets.main.runtimeClasspath
    
        mainClass = 'basic_demo.ChatServerApp'
    
        args 'localhost', '59001'
    }
```

To run the task, we executed the `./gradlew runServer --args="59001"` command from the terminal:

![img.png](images/img.png)

Then, by running the `./gradlew runClient` command from another terminal, 'John' was able to connect to the server:
![img_5.png](images/img_5.png)
As shown in the image, the server requested a screen name, and kept requesting a name until a unique one was received. After 'John' submitted a unique name, the server acknowledged it.
![img_4.png](images/img_4.png)
And then 'Leila' connected to the server from another terminal. The server was notified everytime a new client joined and left the chat room.
![img_1.png](images/img_1.png)


### Run unit tests

First, we create a small test suite. Create a file named "AllTests.java" in the "src/test/java/basic_demo" directory with the following content:

```java

    @Test
    @DisplayName("Constructor should initialize GUI components correctly")
    void testConstructorInitializesComponents() throws Exception {
        // Access private fields using reflection
        Field textFieldField = ChatClient.class.getDeclaredField("textField");
        Field messageAreaField = ChatClient.class.getDeclaredField("messageArea");
        Field frameField = ChatClient.class.getDeclaredField("frame");

        textFieldField.setAccessible(true);
        messageAreaField.setAccessible(true );
        frameField.setAccessible(true);

        JTextField textField = (JTextField) textFieldField.get(client);
        JTextArea messageArea = (JTextArea) messageAreaField.get(client);
        JFrame frame = (JFrame) frameField.get(client);

        assertNotNull(textField, "Text field should be initialized");
        assertNotNull(messageArea, "Message area should be initialized");
        assertNotNull(frame, "Frame should be initialized");

        assertFalse(textField.isEditable(), "Text field should not be editable initially");
        assertFalse(messageArea.isEditable(), "Message area should not be editable");
        assertTrue(frame.isVisible(), "Frame should be visible after creation");
    }

```

To run the unit tests:

    % ./gradlew test

### Task of type Copy to backup source files

To create a new task that copies the contents of the `src` folder to a `backup` folder, we added the following code to the `build.gradle` file:

```groovy
task backupSources(type: Copy) {
    group = "Backup"
    description = "Copies the contents of src to backup folder"
    from 'src'
    into 'backup'
}
```
To execute the task, we ran the command `./gradlew backupSources` from the terminal:
![img_2.png](images/img_2.png)

And as shown in the image below, the contents of the `src` folder were successfully copied to the `backup` folder:

![img_3.png](images/img_3.png)



### Task of type Zip to be used to make an archive 

````groovy

task zipBackup(type: Zip, dependsOn: backupSources) {
    group = 'Backup'
    description = 'Creates a timestamped ZIP archive of the backup folder'

    from 'backup'
    archiveFileName = "backup.zip"
    destinationDirectory = file("/archives")

}

````

### How does  the Gradle Wrapper and the JDK Toolchain ensure the correct versions of Gradle and the Java Development Kit are used without requiring manual installation?

The **Gradle Wrapper** ensures that every developer uses the exact same Gradle version by automatically downloading and running the version defined in the project’s configuration, without requiring a manual installation.
Similarly, the **JDK Toolchain** allows Gradle to automatically detect or download the correct Java Development Kit version specified in the build file (for example, Java 17), ensuring the project is compiled and executed with the right JDK even if different versions are installed on the system.

To verify which toolchains are available, we ran the following command from the project root:

```bash
./gradlew javaToolchains
```
The output was:
```bash

> Task :javaToolchains

 + Options
     | Auto-detection:     Enabled
     | Auto-download:      Enabled

 + Amazon Corretto JDK 1.8.0_422-b05
     | Location:           /Users/leilaboaze/.sdkman/candidates/java/8.0.422-amzn
     | Language Version:   8
     | Vendor:             Amazon Corretto
     | Architecture:       aarch64
     | Is JDK:             true
     | Detected by:        SDKMAN!

 + Amazon Corretto JDK 11.0.25+9-LTS
     | Location:           /Users/leilaboaze/.sdkman/candidates/java/11.0.25-amzn
     | Language Version:   11
     | Vendor:             Amazon Corretto
     | Architecture:       aarch64
     | Is JDK:             true
     | Detected by:        SDKMAN!

 + Amazon Corretto JDK 17.0.12+7-LTS
     | Location:           /Users/leilaboaze/.sdkman/candidates/java/17.0.12-amzn
     | Language Version:   17
     | Vendor:             Amazon Corretto
     | Architecture:       aarch64
     | Is JDK:             true
     | Detected by:        SDKMAN!

 + Amazon Corretto JDK 21.0.5+11-LTS
     | Location:           /Users/leilaboaze/.sdkman/candidates/java/21.0.5-amzn
     | Language Version:   21
     | Vendor:             Amazon Corretto
     | Architecture:       aarch64
     | Is JDK:             true
     | Detected by:        Current JVM


BUILD SUCCESSFUL in 351ms
1 actionable task: 1 executed

```

This output lists all JDK versions that Gradle detected on the system.
It shows that auto-detection and auto-download are **enabled**, which means Gradle can automatically find or retrieve the required JDK version.

The system has several Amazon Corretto JDK versions installed:

* JDK 8
* JDK 11
* JDK 17
* JDK 21 (the current active JDK)

Since the project specifies JDK **17** in the toolchain configuration, Gradle will select that version automatically when compiling and running the application.
This ensures that the build always uses the expected Java version, even if other versions (like 21) are available.
