package fsm;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.UnknownHostException;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public class TcpTransport implements IFSM, Runnable, Cloneable {
	private int id;
	private Dispatcher dispatcher;
	private IFSM receiver;
	private IMessage messageTemplate;
	private int port;
	private Thread runner = null;
	private ServerSocket server = null;
	private Socket client = null;
	private Socket data = null;
	private boolean done = false;
	private boolean twoWayClient;
	private String description = null;

	public TcpTransport(int id, IMessage messageTemplate, boolean twoWayClient) {
		this.id = id;
		this.messageTemplate = messageTemplate;
		this.twoWayClient = twoWayClient;
	}
	
	@Override
	public void setId(int id) {
		this.id = id;
	}

	@Override
	public int getId() {
		return id;
	}

	@Override
	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}
	
	public void setPort(int port) {
		this.port = port;
	}

	public int getPort() {
		return port;
	}

	@Override
	public void start() {
		if (runner == null) {
		    this.setPort(port);
		    try {
				server = new ServerSocket(getPort());
			} catch (IOException e) {
				e.printStackTrace();
			}
		    runner = new Thread(this);
		    runner.start();
		}
	}

	@Override
	public void stop() {
		done = true;
		try {
		    Thread.sleep(500);
		    server.close();
		} catch (Exception e) {
		    e.printStackTrace();
		}
		runner.interrupt();
	}

	@Override
	public void setDispatcher(Dispatcher dispatcher) {
		this.dispatcher = dispatcher;
	}

	@Override
	public Dispatcher getDispatcher() {
		return dispatcher;
	}

	public void setReceiver(IFSM receiver) {
		this.receiver = receiver;
	}

	public IFSM getReceiver() {
		return receiver;
	}

	@Override
	public void addMessage(IMessage message) {
		OutputStream outToServer;
		InputStream inFromServer = null;
		try {
			client = new Socket(message.getToAddress().split(":")[0], Integer.valueOf(message.getToAddress().split(":")[1]));
			if (twoWayClient)
				inFromServer = client.getInputStream();
			outToServer = client.getOutputStream();
			outToServer.write(message.buildTransportMessage());
			outToServer.flush();
			if (twoWayClient && message.getHasReturnMessage()) {
				ByteArrayOutputStream output = new ByteArrayOutputStream();			
				byte cbuf[] = new byte[1024];
				int len, cursor = 0;
				while((len = inFromServer.read(cbuf)) > 0) {
					output.write(cbuf, 0, len);
					cursor += len;
					if (inFromServer.available() == 0) 
						break;
				}
				
				messageTemplate.parseTransportMessage(output.toByteArray(), cursor);
				messageTemplate.setFromId(id);
				messageTemplate.setToId(receiver.getId());
				dispatcher.addMessage((IMessage)messageTemplate.clone());
			}
			outToServer.close();
			disconnect();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void connect(String host, int port) {
		if (client == null) {
			try {
				client = new Socket(host, port);
			} catch (UnknownHostException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public void disconnect() {
		try {
			client.close();
			client = null;
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public boolean isConnected() {
		return (client == null);
	}

	protected synchronized boolean getDone() {
		return done;
	}

	@Override
	public void run() {
		if (server != null) {
			while (!getDone()) {
				try {
					Socket datasocket = server.accept();
					TcpTransport newSocket = (TcpTransport) clone();
					newSocket.server = null;
					newSocket.data = datasocket;
					newSocket.runner = new Thread(newSocket);
					newSocket.runner.start();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		} else {
			run(data);
		}
	}

	public void run(Socket connectionSocket) {
		DataInputStream inFromClient;
		DataOutputStream outToClient;
		try {
			inFromClient = new DataInputStream(connectionSocket.getInputStream());
			outToClient = new DataOutputStream(connectionSocket.getOutputStream());
			
			ByteArrayOutputStream output = new ByteArrayOutputStream();			
			byte cbuf[] = new byte[1024];
			int len, cursor = 0;
			while((len = inFromClient.read(cbuf)) > 0) {
				output.write(cbuf, 0, len);
				cursor += len;
			}
			
			messageTemplate.parseTransportMessage(output.toByteArray(), cursor);
			messageTemplate.setFromId(id);
			messageTemplate.setToId(receiver.getId());
			dispatcher.addMessage((IMessage)messageTemplate.clone());
			
			outToClient.flush();
			outToClient.close();
			connectionSocket.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
