package fsm.pa;

import java.awt.Canvas;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.util.ArrayList;
import java.util.LinkedList;

import fsm.IFSM;
import fsm.IMessage;

class Chart extends Canvas implements MouseListener {
	public LinkedList<IFSM> fsmlist;
	public LinkedList<IMessage> msglist;
	public ArrayList<Integer> x = new ArrayList<Integer>();
	public ArrayList<Integer> y = new ArrayList<Integer>();
	public ArrayList<Integer> width = new ArrayList<Integer>();
	public ArrayList<Integer> messageId = new ArrayList<Integer>();
	public ArrayList<Integer> sIdMchn = new ArrayList<Integer>();
	public ArrayList<Integer> dIdMchn = new ArrayList<Integer>();
	public ArrayList<String> gettoaddress = new ArrayList<String>();
	public ArrayList<String> fromaddress = new ArrayList<String>();
	public ArrayList<byte[]> buildtransportmessage = new ArrayList<byte[]>();

	Chart(LinkedList<IFSM> fsmlist, LinkedList<IMessage> msglist) {
		this.fsmlist = fsmlist;
		this.msglist = msglist;
		addMouseListener(this);
	}

	public void addMachine(Graphics g, int mchnId, String mchnDesc, int X, int Y) {

		g.setColor(Color.black);

		g.drawRect(2 * mchnId * 100 - X + 200, 100 - Y, 150, 70);
		g.drawString("" + mchnDesc, 200 * mchnId + 25 - X + 200, 150 - Y);
		g.drawLine(mchnId * 200 + 75 - X + 200, 170 - Y, mchnId * 200 + 75 - X
				+ 200, 1000);
	}

	public void addMsg(Graphics g, int sourceIdMchn, int destIdMchn,
			int msgNum, int msgId, String msgDescr, String GTA, String GFA, byte[] btm, int X,
			int Y) {
		g.setColor(Color.red);
		int a;
		a = (sourceIdMchn + destIdMchn) * 200 / 2;

		messageId.add(msgId);
		sIdMchn.add(sourceIdMchn);
		dIdMchn.add(destIdMchn);
		gettoaddress.add(GTA);
		fromaddress.add(GFA);
		buildtransportmessage.add(btm);

		if (sourceIdMchn < destIdMchn) {
			g.drawLine(200 * sourceIdMchn + 75 - X + 200,
					msgNum * 50 + 190 - Y, destIdMchn * 200 + 75 - X + 200,
					msgNum * 50 + 190 - Y);
			g.drawLine(200 * destIdMchn + 65 - X + 200, msgNum * 50 + 200 - Y,
					destIdMchn * 200 + 75 - X + 200, msgNum * 50 + 190 - Y);
			g.drawLine(200 * destIdMchn + 65 - X + 200, msgNum * 50 + 180 - Y,
					destIdMchn * 200 + 75 - X + 200, msgNum * 50 + 190 - Y);

			g.drawString("" + msgDescr, a + 40 - X + 200, msgNum * 50 + 189
					- Y);
			x.add(200 * sourceIdMchn + 76 - X + 200);
			y.add(msgNum * 50 + 177 - Y);
			width.add((destIdMchn - sourceIdMchn) * 200 - 2);
			g.setColor(Color.white);
			g.drawRect(200 * sourceIdMchn + 76 - X + 200,
					msgNum * 50 + 177 - Y,
					(destIdMchn - sourceIdMchn) * 200 - 2, 24);

		}
		if (sourceIdMchn > destIdMchn) {
			g.drawLine(200 * sourceIdMchn + 75 - X + 200,
					msgNum * 50 + 190 - Y, destIdMchn * 200 + 75 - X + 200,
					msgNum * 50 + 190 - Y);
			g.drawLine(200 * destIdMchn + 85 - X + 200, msgNum * 50 + 200 - Y,
					destIdMchn * 200 + 75 - X + 200, msgNum * 50 + 190 - Y);
			g.drawLine(200 * destIdMchn + 85 - X + 200, msgNum * 50 + 180 - Y,
					destIdMchn * 200 + 75 - X + 200, msgNum * 50 + 190 - Y);
			g.drawString("" + msgDescr, a + 40 - X + 200, msgNum * 50 + 189
					- Y);
			x.add(200 * destIdMchn + 76 - X + 200);
			y.add(msgNum * 50 + 177 - Y);
			width.add((sourceIdMchn - destIdMchn) * 200 - 2);
			g.setColor(Color.white);
			g.drawRect(200 * destIdMchn + 76 - X + 200, msgNum * 50 + 177 - Y,
					(sourceIdMchn - destIdMchn) * 200 - 2, 24);

		}
		if (sourceIdMchn == destIdMchn) {
			g.drawLine(200 * destIdMchn + 75 - X + 200, msgNum * 50 + 190 - Y,
					destIdMchn * 200 + 90 - X + 200, msgNum * 50 + 190 - Y);
			g.drawLine(200 * destIdMchn + 75 - X + 200, msgNum * 50 + 170 - Y,
					destIdMchn * 200 + 90 - X + 200, msgNum * 50 + 170 - Y);
			g.drawLine(200 * destIdMchn + 90 - X + 200, msgNum * 50 + 170 - Y,
					destIdMchn * 200 + 90 - X + 200, msgNum * 50 + 190 - Y);
			g.drawLine(200 * destIdMchn + 85 - X + 200, msgNum * 50 + 200 - Y,
					destIdMchn * 200 + 75 - X + 200, msgNum * 50 + 190 - Y);
			g.drawLine(200 * destIdMchn + 85 - X + 200, msgNum * 50 + 180 - Y,
					destIdMchn * 200 + 75 - X + 200, msgNum * 50 + 190 - Y);

			g.drawString("" + msgDescr, 200 * destIdMchn + 87 - X + 200, msgNum
					* 50 + 185 - Y);
			x.add(200 * destIdMchn + 76 - X + 200);
			y.add(msgNum * 50 + 177 - Y);
			width.add(32);
			g.setColor(Color.white);
			g.drawRect(200 * destIdMchn + 76 - X + 200, msgNum * 50 + 169 - Y,
					32, 32);
		}
	}

	public void mouseClicked(MouseEvent me) {
		boolean thereWasClick = false;
		int clickedMsg = 0;
		int source = 0;
		int destination = 0;
		String GTA = "";
		String GFA = "";
		byte[] byt = new byte[0];

		int xpos = me.getX();
		int ypos = me.getY();
		for (int i = 0; i < messageId.size(); i++) {
			if (xpos > x.get(i) && xpos < x.get(i) + width.get(i)
					&& ypos > y.get(i) && ypos < y.get(i) + 20) {
				thereWasClick = true;
				clickedMsg = messageId.get(i);
				source = sIdMchn.get(i);
				destination = dIdMchn.get(i);
				GTA = gettoaddress.get(i);
				GFA = fromaddress.get(i);
				byt = buildtransportmessage.get(i);

			}
		}
		if (thereWasClick) {
			new MessageDecoder(clickedMsg, source, destination, GTA, GFA, byt);
		}
	}

	public void mousePressed(MouseEvent me) {
	}

	public void mouseReleased(MouseEvent me) {
	}

	public void mouseEntered(MouseEvent me) {
	}

	public void mouseExited(MouseEvent me) {
	}

	/* Declaration */
	private int X;
	private int Y;

	public void setOval(int H, int V) {
		X = H;
		Y = V;
	}

	public void paint(Graphics g) {

		for (int i = 0; i < fsmlist.size(); i++) {
			IFSM ma = fsmlist.get(i);

			addMachine(g, ma.getId(), ma.getDescription(), X, Y);
		}
		for (int i = 0; i < msglist.size(); i++) {
			IMessage msg = msglist.get(i);
			addMsg(g, msg.getFromId(), msg.getToId(), i + 1,
					msg.getMessageId(), msg.getMessageDescription(), msg.getToAddress(), msg
							.getFromAddress(), msg.buildTransportMessage(), X,
					Y);
		}

	}

}
