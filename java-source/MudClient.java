// Java Mud Client, by Thomas Boutell, 10/11/96. 

import java.awt.*;
import java.util.Vector;
import java.lang.Integer;
import java.util.Hashtable;
import java.util.Enumeration;
import java.lang.String;
import java.net.*;
import java.io.InputStream;

public class MudClient extends java.applet.Applet implements Runnable {
	Socket socket;
	public String serverHost;
	int serverPort;
	SlaveFrame frame;
	Hashtable topicToFrame;
	Hashtable frameToTopic;
	Panel loginPanel;
	Panel controlPanel;
	Button connectButton, helpButton, quitButton;
	Choice topicList;
	Label namePrompt, passwordPrompt, statusPrompt;
	Label statusLabel;
	TextField nameField, passwordField;
	TextArea outputText;
	boolean validating = false;
	Thread inputThread;
	String inputLine;
	final int outputBufferHigh = 4096 + 2048;
	final int outputBufferLow = 4096;
	String topicPrefix = "[{}]";
	public void run() {
		if (Thread.currentThread() == inputThread) {
			inputRun();
			return;
		}	
	}
	public void init() {
		serverHost = getParameter("serverHost");	
		if (serverHost == null) {
			System.out.println("No serverHost <param> tag!");
			return;
		}
		String serverPortString = getParameter("serverPort");	
		serverPort = 4096;
		if (serverPortString != null) {
			try {
				serverPort = Integer.parseInt(serverPortString); 
			} catch (java.lang.NumberFormatException e) {
				System.out.println("No serverPort <param> tag!");
				return;
			}	
		}
		setBackground(Color.white);
		setForeground(Color.black);
		topicToFrame = new Hashtable();
		frameToTopic = new Hashtable();
		layoutLogin();
		setStatus("Not Connected");
	}
	public void layoutLogin() {
		// setFont(new Font("Helvetica", Font.PLAIN, 12));
		if (frame != null) {
			frame.hide();
		}
		GridBagLayout gridbag = new GridBagLayout();
		setLayout(gridbag);
		GridBagConstraints c = new GridBagConstraints();
		
		c.fill = GridBagConstraints.BOTH;
		c.gridwidth = 1;
		c.gridheight = 1;
		c.weightx = 1.0;
		c.weighty = 0.0;
		c.gridx = 0;
		c.gridy = 0;
		namePrompt = new Label("Character Name:");
		gridbag.setConstraints(namePrompt, c);
		add(namePrompt);
		c.gridx = 1;
		c.gridy = 0;
		nameField = new TextField();
		gridbag.setConstraints(nameField, c);
		add(nameField);
		c.gridx = 0;
		c.gridy = 1;
		passwordPrompt = new Label("Character Password:");
		gridbag.setConstraints(passwordPrompt, c);
		add(passwordPrompt);
		c.gridx = 1;
		c.gridy = 1;
		passwordField = new TextField();
		passwordField.setEchoCharacter('*');
		gridbag.setConstraints(passwordField, c);
		add(passwordField);
		c.gridx = 0;
		c.gridy = 2;
		c.gridwidth = 1;
		c.weightx = 0;
		c.weighty = 0;
		statusPrompt = new Label("Status:");
		gridbag.setConstraints(statusPrompt, c);
		add(statusPrompt);
		c.gridx = 1;
		statusLabel = new Label("");
		gridbag.setConstraints(statusLabel, c);
		add(statusLabel);
		c.gridx = 0;
		c.gridy = 3;
		c.gridwidth = 2;
		c.weightx = 0;
		c.weighty = 0;
		connectButton = new Button("Connect");
		gridbag.setConstraints(connectButton, c);
		add(connectButton);
		c.gridy = 4;
		c.weighty = 1.0;
		Label spacer = new Label("");
		gridbag.setConstraints(spacer, c);
		add(spacer);
	}
	public void layoutConnected(SlaveFrame frame, boolean topic) {
		Toolkit toolkit = java.awt.Toolkit.getDefaultToolkit();
		int size = 12;
		Font font = new Font("Times Roman", Font.PLAIN, size);
		GridBagLayout gridbag = new GridBagLayout();
		frame.setLayout(gridbag);
		GridBagConstraints c = new GridBagConstraints();
		c.gridwidth = 1;
		c.gridheight = 1;
		c.weightx = 1.0;
		c.weighty = 1.0;
		c.gridx = 0;
		c.gridy = 0;
		frame.inputText = new TextArea(frame.rowsShown, frame.colsShown);
		frame.inputText.setEditable(false);
		frame.inputText.setFont(font);
		gridbag.setConstraints(frame.inputText, c);
		frame.add(frame.inputText);
		if (!topic) {
			c.gridx = 0;
			c.gridy++;
			c.fill = GridBagConstraints.HORIZONTAL;
			c.weightx = 1.0;
			c.weighty = 0.0;
			outputText = new TextArea(1, frame.colsShown);
			outputText.setEditable(false);
			outputText.setText("");
			gridbag.setConstraints(outputText, c);
			frame.add(outputText);
		}
		c.gridx = 0;
		c.gridy++;
		c.fill = GridBagConstraints.HORIZONTAL;
		c.weightx = 1.0;
		c.weighty = 0.0;
		frame.outputField = new TextField();
		frame.outputField.setEditable(true);
		gridbag.setConstraints(frame.outputField, c);
		frame.add(frame.outputField);		
		frame.outputField.requestFocus();

		if (!topic) {
			c.gridx = 0;
			c.gridy++;
			c.weightx = 1.0;
			c.weighty = 0.0;
			c.fill = GridBagConstraints.HORIZONTAL;
			controlPanel = new Panel();
			gridbag.setConstraints(controlPanel, c);
			layoutControlPanel();
			frame.add(controlPanel);
		}
		c.gridy++;
		c.gridx = 0;
		c.gridwidth = 1;
		c.fill = GridBagConstraints.HORIZONTAL;
		frame.urlButton = new Button("Last Mentioned URL");
		frame.urlButton.disable();
		gridbag.setConstraints(frame.urlButton, c);
		frame.add(frame.urlButton);
		frame.inputText.setText("");
		frame.outputField.setText("");
		frame.pack();
	}
	void layoutControlPanel()
	{
		controlPanel.hide();
		controlPanel.removeAll();

		helpButton = new Button("Help");
		controlPanel.add(helpButton);

		quitButton = new Button("Quit");
		controlPanel.add(quitButton);

		topicList = new Choice();
		topicList.addItem("Topic Windows");
		controlPanel.add(topicList);
		controlPanel.layout();
		controlPanel.show();
	}	
	public void start() {
		// Nothing to see here, move along
	}
//	public void frameGotFocus()
//	{
//		if (socket != null) {
//			outputField.requestFocus();
//		} 
//	}
	public boolean slaveHandleEvent(SlaveFrame f, Event evt) {
		if (f == frame) {
			if ((evt.target == (Object) frame) && 
				(evt.id == Event.WINDOW_DESTROY)) {
				close();	
				setStatus("Connection Closed");
				if (frame != null) {
					frame.hide();
				}
				return true;
			}
		} else {
			if ((evt.target == f) && 
				(evt.id == Event.WINDOW_DESTROY)) {
				f.hide();
				return true;
			}
		}
		return false;
	}
	public boolean slaveAction(SlaveFrame f, Event evt, Object arg) {
		int i;
		if (evt.target == (Object) quitButton) {
			close();
			setStatus("Connection Closed");
			if (frame != null) {
				frame.hide();
			}
			return true;
		} else if (evt.target == (Object) f.urlButton) {
			if (f.lastUrl != null) {
				launchUrl(f.lastUrl);
			}
			f.outputField.requestFocus();
			return true;
		} else if (evt.target == (Object) helpButton) {
			outputCommand("help");
			f.outputField.requestFocus();
			return true;
		} else if (evt.target == (Object) topicList) {
			SlaveFrame sf = (SlaveFrame)
				topicToFrame.get(arg);
			if (sf != null) {
				// Remap the topic's window
				sf.show();
			}
			// Reselect the first item, which acts as a label
			topicList.select(0);
		} else if (evt.target == (Object) f.outputField) {
			if (f.topic != null) {
				String s = (String) arg;
				if (s.startsWith(":")) {
					outputCommand(";" + f.topic + " " + 
						s.substring(1));
				} else if (s.startsWith(":")) {
					outputCommand("," + f.topic + " " + 
						s.substring(1));
				} else {
					outputCommand("," + f.topic + " " + s);
				}
			} else {
				outputCommand((String) arg);
			}
			f.outputField.setText("");
			return true;
		}
		return false;
	}
	public boolean action(Event evt, Object arg) {
		if ("Connect".equals(arg)) {
			close();
			if (frame == null) {
				frame = new SlaveFrame(this, null, serverHost);
				layoutConnected(frame, false);
				setStatus("Not Connected");
			}	
			frame.show();	
			setStatus("Connecting");
			if (!connectRemote()) {
				setStatus("Connection Failed");
				if (frame != null) {
					frame.hide();
				}
			}
			return true;
		}
		return false;
	}
	void launchUrl(String urlString)
	{
		try {
			URL url = new URL(urlString);
			getAppletContext().showDocument(
				url, "_new");
		} catch (MalformedURLException e) {
			setStatus("Sorry, Bad URL");
		}
	}
	public void outputCommand(String arg)
	{
		if (socket != null) {
			String text = (String) arg;
			outputText.appendText("\n" + text);
			scrollOutputToEnd();
			try {
				writeln(text);
			} catch (java.io.IOException e) {
				close();
				setStatus("Connection Closed");
				if (frame != null) {
					frame.hide();
				}
			}
		}	
	}
	public void close() {
		closeWithoutStop();
		if (inputThread != null) {
			inputThread.stop();
		}
	}	
	public void closeWithoutStop() {
		if (socket != null) {
			try {
				socket.close();
			} catch (java.io.IOException e) {
				// So what am I supposed to do about this?
			}
			socket = null;
		}
	}
	public void stop() {
		// Do nothing. The user often wants to
		// look at other web pages without
		// dropping the connection.
	}
	public void destroy() {
		close();
	}
	public boolean connectRemote()
	{
		try {
			socket = new Socket(serverHost, serverPort);
			writeln("smartclient");
			writeln("connect " + nameField.getText() +
				" " + passwordField.getText());			
		} catch (java.io.IOException e) {
			return false;
		}
		setStatus("Validating");
		validating = true;
		inputThread = new Thread(this);
		inputThread.start();
		return true;
	}
	public void inputRun()
	{
		byte buf[] = new byte[1024];
		inputLine = "";
		InputStream stream;
		try {
			stream = socket.getInputStream();
		} catch (java.io.IOException e) {
			closeWithoutStop();
			setStatus("Connection Closed");
			if (frame != null) {
				frame.hide();
			}
			// Stop ourselves
			inputThread.stop();
			return;
		}
		while (inputThread != null) {
			int rec = 0;
			int av = 0;
			try {
				// Strategy to try to cope with
				// both dumb and smart implementations
				// of sockets: ask how many bytes
				// are available. If we get back zero,
				// try to read just one on this pass,
				// which will block until data is ready.
				// Otherwise read as many as are
				// available or stop short at 1024.
				av = stream.available();
				if (av == 0) {
					av = 1;
				} else if (av > 1024) {
					av = 1024;
				}	
				rec = socket.getInputStream().read(
					buf, 0, av);
				if (rec != -1) {
					inputDisplay(new String(
						buf, 0, 0, rec));
				}
			} catch (java.io.IOException e) {
				closeWithoutStop();
				setStatus("Connection Closed");
				if (frame != null) {
					frame.hide();
				}
				// Stop ourselves
				inputThread.stop();
				return;
			}	
		}
	}	
	public void inputDisplay(String s) {
		inputLine += s;
		int cr;
		while ((cr = inputLine.indexOf("\r\n")) != -1) {
			String l = inputLine.substring(0, cr);
			boolean found = false;
			String topic = null;
			if (l.startsWith(topicPrefix)) {
				l = l.substring(
					topicPrefix.length());
				Enumeration topics = topicToFrame.keys();
				int sat = l.lastIndexOf(' ');
				if (sat != -1) {
					topic = l.substring(sat + 1);
					System.out.print("*");
					System.out.println(topic);
				}	
				if (topic != null) {
					if (topic.startsWith("<") &&
						topic.endsWith(">")) {
						topic = topic.substring(1, 
							topic.length() - 1);	
					} else {
						topic = null;
					}
				}
				if (topic != null) {
					while (topics.hasMoreElements()) {
						String tn;
						tn = (String) topics.nextElement();
						if (topic.equals(tn)) {
							SlaveFrame sf = (SlaveFrame)
								topicToFrame.get(tn);
							sf.inputWrapLine(l.substring(
								0, sat));
							found = true;
							break;
						}
					}
					if (!found) {
						SlaveFrame sf = new SlaveFrame(this,
							topic, topic);
						topicList.addItem(topic);
						layoutConnected(sf, true);
						topicToFrame.put(topic, sf);
						frameToTopic.put(sf, topic);
						sf.inputWrapLine(l.substring(
							0, sat));
						sf.show();	
					}
				}
			}
			if (topic == null) {
				frame.inputWrapLine(l);
			}
			inputLine = inputLine.substring(cr + 2);
		}	
	}
	public void writeln(String text) throws java.io.IOException {
		int len = text.length();
		byte buf[] = new byte[len + 1];
		int i;
		for (i = 0; (i < len); i++) {
			buf[i] = (byte) text.charAt(i);
		}
		buf[len] = '\n';
		socket.getOutputStream().write(buf);
	}
	public void setStatus(String text) {
		statusLabel.setText(text);
	}
	boolean validateLine(Frame f, String l) {
		if (f != frame) {
			return true;
		}
		if (validating) {
			if (l.equals(
				"Login Failed")) {
				closeWithoutStop();
				setStatus("Wrong Name or Password");
				if (frame != null) {
					frame.hide();
				}
				// Stop ourselves
				inputThread.stop();
				return false;
			} else if (l.equals(
				"Login Succeeded")) {
				validating = false;
				setStatus("Connected");
				return false;
			}
		}
		return true;
	}
	public void scrollOutputToEnd() 
	{
		int len = outputText.getText().length();
		int remove = 0;
		String text = outputText.getText();
		if (len > outputBufferHigh) {
			while (len > outputBufferLow) {
				int cr = text.indexOf('\n');
				if (cr == -1) {
					remove = len - outputBufferLow;
					len -= remove;
					break;
				}
				remove += (cr + 1);		
				text = text.substring(0, cr + 1);
				len -= (cr + 1);	
			}
		}
		if (remove > 0) {
			outputText.replaceText("", 0, remove);
		}
		outputText.select(len, len);		
	}
}

class SlaveFrame extends java.awt.Frame {
	MudClient client;
	TextArea inputText;
	TextField outputField;
	Button urlButton;
	String lastUrl;
	String topic;
	int rowsShown = 20, colsShown = 80;
	final int inputBufferHigh = 4096 + 2048;
	final int inputBufferLow = 4096;
	// Redirect events to the owner.
	public SlaveFrame(MudClient clientArg, String topicArg, String title) {
		super(title);
		topic = topicArg;
		client = clientArg;
	}
	public boolean action(Event evt, Object arg) {
		if (client.slaveAction(this, evt, arg)) {
			return true;
		} else {
			return super.action(evt, arg);
		}
	}
	public boolean handleEvent(Event evt) {
		if (client.slaveHandleEvent(this, evt)) {
			return true;
		} else {
			return super.handleEvent(evt);
		}
	}
	public void inputWrapLine(String l) {	
		int len = l.length();
		int w = colsShown;
		int cr;
		while ((cr = l.indexOf('\r')) != -1) {
			l = l.substring(0, cr) + l.substring(cr + 1);
		}
		if (!client.validateLine(this, l)) {
			return;
		}
		boolean urlFound = false;
		int urlStart = l.indexOf("http:");
		if (urlStart == -1) {
			urlStart = l.indexOf("ftp:");
		}
		if (urlStart == -1) {
			urlStart = l.indexOf("gopher:");
		}
		if (urlStart == -1) {
			urlStart = l.indexOf("news:");
		}
		if (urlStart != -1) {
			lastUrl = l.substring(urlStart);
			urlFound = true;
		}
		if (urlStart != -1) {
			int urlEnd = lastUrl.indexOf(" ");
			if (urlEnd != -1) {
				lastUrl = lastUrl.substring(0, urlEnd);
			}
		}
		if (!urlFound) {
			// Any word with at least two dots, or a
			// dot and a slash, is a decent candidate 
			// for an http:// prefix.
			String c = l;
			while (true) {
				String word;
				int sat = c.indexOf(" ");
				if (sat == -1) {
					word = c;
					c = "";
				} else {
					word = c.substring(0, sat);
					c = c.substring(sat + 1);
				}	
				// Don't react to ellipsis
				if (word.indexOf("...") != -1) {
					if (sat == -1) {
						break;
					}
					continue;
				}
				// Don't trigger on trailing dots, etc.
				word = depunctuate(word);
				if (word.length() > 1) {
					int dot = word.indexOf(".");
					if (dot != -1) {
						if ((word.indexOf(".", dot + 1) 
							!= -1) ||
							(word.indexOf("/") 
								!= -1) ||
							(word.indexOf("@") 
								!= -1)) {
							if (word.indexOf("@") != -1) {
								lastUrl = "mailto:" + word;
							} else {
								lastUrl = "http://" +
									word;
							}
							urlFound = true;
							break;
						}
					}		
				}
				if (sat == -1) {
					break;
				}
			}
		}
		if (urlFound) {
			lastUrl = depunctuate(lastUrl);
			urlButton.setLabel(lastUrl);
			urlButton.enable();	
			urlButton.show();	
		}
		while (len > w) {
			int sp;
			String sub = l.substring(0, w);
			sp = sub.lastIndexOf(' ');
			if (sp == -1) {
				inputText.appendText("\n");
				inputText.appendText(sub);
				l = l.substring(w);
				len -= w;
			} else {
				inputText.appendText("\n");
				inputText.appendText(sub.substring(0, sp));
				l = sub.substring(sp + 1) + l.substring(w);
				len -= sp;
				len --;
			}
		}
		if (len > 0) {
			inputText.appendText("\n");
			inputText.appendText(l);
		}
		scrollInputToEnd();
	}
	public String depunctuate(String argIn)
	{
		boolean busy;
		String arg = argIn;
		do {
			if (arg.length() == 0) {
				return "";
			}
			busy = false;
			if (arg.substring(0, 1).equals(".") ||
				arg.substring(0, 1).equals("!") ||
				arg.substring(0, 1).equals("?") ||
				arg.substring(0, 1).equals(",") ||
				arg.substring(0, 1).equals("'") ||
				arg.substring(0, 1).equals("`") ||
				arg.substring(0, 1).equals("(") ||
				arg.substring(0, 1).equals(")") ||
				arg.substring(0, 1).equals("<") ||
				arg.substring(0, 1).equals(">") ||
				arg.substring(0, 1).equals(";") ||
				arg.substring(0, 1).equals(":") ||
				arg.substring(0, 1).equals("\""))
			{
				arg = arg.substring(1);
				busy = true;
			}			
			if (arg.endsWith(".") ||
				arg.endsWith("!") ||
				arg.endsWith("?") ||
				arg.endsWith(",") ||
				arg.endsWith("'") ||
				arg.endsWith("`") ||
				arg.endsWith("(") ||
				arg.endsWith(")") ||
				arg.endsWith("<") ||
				arg.endsWith(">") ||
				arg.endsWith(";") ||
				arg.endsWith(":") ||
				arg.endsWith("\""))
			{
				arg = arg.substring(
					0, arg.length() - 1);
				busy = true;
			}
		} while (busy);
		return arg;
	}
	public void scrollInputToEnd() 
	{
		int len = inputText.getText().length();
		int remove = 0;
		String text = inputText.getText();
		if (len > inputBufferHigh) {
			while (len > inputBufferLow) {
				int cr = text.indexOf('\n');
				if (cr == -1) {
					remove = len - inputBufferLow;
					len -= remove;
					break;
				}
				remove += (cr + 1);		
				text = text.substring(0, cr + 1);
				len -= (cr + 1);	
			}
		}
		if (remove > 0) {
			inputText.replaceText("", 0, remove);
		}
		inputText.select(len, len);		
	}
}
	
