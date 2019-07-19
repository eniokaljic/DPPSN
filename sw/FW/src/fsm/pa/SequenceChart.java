package fsm.pa;

import java.applet.Applet;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Font;
import java.awt.Label;
import java.awt.LayoutManager;
import java.awt.Scrollbar;
import java.awt.event.AdjustmentEvent;
import java.awt.event.AdjustmentListener;
import java.util.LinkedList;

import fsm.IFSM;
import fsm.IMessage;

public class SequenceChart extends Applet implements AdjustmentListener {
	public LinkedList<IFSM> fsmlist = new LinkedList<IFSM>();
	public LinkedList<IMessage> msglist = new LinkedList<IMessage>();
	Color redColor;
	Color weirdColor;
	Color bgColor;
	Font bigFont;

	public void init() {
		// Here we will define the varibles further
		// Will use Arial as type, 16 as size and bold as style
		// Italic and Plain are also available
		bigFont = new Font("Arial", Font.BOLD, 16);
		// Standard colors can be named like this
		redColor = Color.black;
		// lesser known colors can be made with R(ed)G(reen)B(lue).
		weirdColor = new Color(60, 60, 122);
		bgColor = Color.white;
		// this will set the backgroundcolor of the applet
		setBackground(bgColor);

	}

	public void stop() {
	}

	/* Declaration */
	private LayoutManager Layout;
	private Scrollbar HSelector;
	private Scrollbar VSelector;
	private Chart Pad;
	private Label Report;

	public void addFSM(IFSM newFSM) {
		fsmlist.add(newFSM);
		Pad.repaint();
	}

	public void addMessage(IMessage newMessage) {
		msglist.add(newMessage);
		Pad.repaint();
	}

	public SequenceChart() {
		/* Instantiation */
		Layout = new BorderLayout();
		HSelector = new Scrollbar();
		VSelector = new Scrollbar(Scrollbar.VERTICAL);
		Pad = new Chart(fsmlist, msglist);
		Report = new Label();

		/* Decoration */
		HSelector.setMaximum(700);
		HSelector.setOrientation(Scrollbar.HORIZONTAL);
		VSelector.setMaximum(700);
		Report.setAlignment(Label.CENTER);
		Pad.setBackground(Color.white);

		/* Location */
		setLayout(Layout);
		add("South", Report);
		add("North", HSelector);
		add("West", VSelector);
		add("Center", Pad);

		/* Configuration */
		HSelector.addAdjustmentListener(this);
		VSelector.addAdjustmentListener(this);

		/* Initialization */
		HSelector.setValue(0);
		VSelector.setValue(0);
		Pad.setOval(0, 0);
		Report.setText("H = " + HSelector.getValue() + ", V = "
				+ VSelector.getValue());
	}

	public void adjustmentValueChanged(AdjustmentEvent e) {
		Report.setText("H = " + HSelector.getValue() + ", V = "
				+ VSelector.getValue());
		Pad.setOval(HSelector.getValue(), VSelector.getValue());
		Pad.repaint();
	}
}
