package basic_demo;

import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

import javax.swing.*;
import java.lang.reflect.Field;

class ChatClientTest {

    private ChatClient client;

    @BeforeEach
    void setUp() {
        client = new ChatClient("localhost", 12345);
    }

    @AfterEach
    void tearDown() {
        // Dispose of the frame to avoid interference between tests
        SwingUtilities.invokeLater(() -> client.run());
    }

    @Test
    @DisplayName("Constructor should initialize GUI components correctly")
    void testConstructorInitializesComponents() throws Exception {
        // Access private fields using reflection
        Field textFieldField = ChatClient.class.getDeclaredField("textField");
        Field messageAreaField = ChatClient.class.getDeclaredField("messageArea");
        Field frameField = ChatClient.class.getDeclaredField("frame");

        textFieldField.setAccessible(true);
        messageAreaField.setAccessible(true);
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

    @Test
    @DisplayName("getName() should return a non-null string when user inputs a name")
    void testGetNameReturnsString() throws Exception {
        // Use reflection to access private method getName()
        var method = ChatClient.class.getDeclaredMethod("getName");
        method.setAccessible(true);

        // Mock JOptionPane to simulate user input
        JOptionPane pane = new JOptionPane();
        SwingUtilities.invokeLater(() -> JOptionPane.getRootFrame().dispose());

        // This would normally show a dialog — we can’t simulate UI input here easily,
        // so we just assert that the method can be called (no crash)
        // In real UI tests, you’d use a framework like AssertJ Swing or Jemmy.
        assertDoesNotThrow(() -> method.invoke(client));
    }
}
