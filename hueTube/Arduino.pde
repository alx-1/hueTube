/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour with Robocut Studio
 * @version   0.1
 * @since     2017-01-28
 */

 import processing.serial.*;

/**
 * This class manages the communication with the Arduino.
 * The poll method should not be called at more then 20Hz.
 */
class Arduino {
	Serial serialPort;
	PApplet parent;
	boolean enabled;
	String portPath;
	int baudRate;
	/**
	 * Constructor.
	 * @param PApplet parent applet
	 */
	public Arduino(PApplet _pa){
		parent = _pa;
		enabled = false;
	}

	/**
     * Get information from the serialPort.
     * @return int[] data
     */
	public String poll(){
		// return testMode();
		if(enabled){
			return getMessage('*');
		}
		else return null;
	}

	/**
     * Poll the Arduino for data.
     * @return String message received
     */
	public String getMessage(char _f){
		String buff = "";
		try {
			serialPort.write(_f);
			while(serialPort.available() != 0) buff += char(serialPort.read());
		} catch(Exception e){
			println("Arduino not connected, attempting reconnect");
		}
		// if(buff.equals("")) connect(portPath, baudRate);
		return buff;
	}

	/**
     * Send a byte to the serialPort.
     * @param byte
     */
	public void send(byte _b){
		if(enabled && serialPort != null){
			serialPort.write(_b);
		}
	}

    public void close(){
        serialPort.stop();
        enabled = false;
    }

	/**
	 * Open a connection with the serialPort.
	 */
	void connect(String _port, int _rate){
		if(serialPort != null) serialPort.stop();
		serialPort = null;
		try {
			for(String _ser : Serial.list()){
				if(_ser.contains(_port)){

					portPath = _ser;
					baudRate = _rate;
					serialPort = new Serial(parent, portPath, baudRate);
					enabled = true;
					println("Arduino connected : "+_ser);
					delay(2000); // let the Arduino MEGA wait for a second
				}
			}
		} catch(Exception e){
            println("Failed to connect to :"+_port);
		}
		if(!enabled) println("WARNING : Arduino not connected");
	}
}
