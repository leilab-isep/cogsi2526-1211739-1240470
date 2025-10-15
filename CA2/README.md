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

Run unit tests
------------------
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


Task of type Zip to be used to make an archive 
-----------------------------------------------

````groovy

task zipBackup(type: Zip, dependsOn: backupSources) {
    group = 'Backup'
    description = 'Creates a timestamped ZIP archive of the backup folder'

    from 'backup'
    archiveFileName = "backup.zip"
    destinationDirectory = file("/archives")

}

````
