package fsm.pa;

import javax.swing.*;

import java.awt.*;
import java.awt.event.*;

public class MessageDecoder extends JFrame implements ActionListener {
    
    public MessageDecoder(int msgId, int source, int destination, String gettoaddress, String fromaddress,byte[] btm)
    {
    	
    	super("Message review: "+msgId);
    		String message=new String(btm);
    		setLayout(new GridLayout(6,1));
            
            setVisible(true);
            setSize(300,200);
            Label label1 = new Label("Message ID: "+msgId);
            Label label2 = new Label("From ID: "+source);
            Label label3 = new Label("To ID: "+destination);
            Label label4 = new Label("To Address: "+gettoaddress);
            Label label5 = new Label("From Address: "+fromaddress);
            Label label6 = new Label("Transport Message: "+message);
            
            add(label1); 
            add(label2);
            add(label3);
            add(label4);
            add(label5);
            add(label6);
            
            
            
    }

    public void actionPerformed(ActionEvent event)
    {
            
    }
}
