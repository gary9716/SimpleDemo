import processing.serial.*;
import oscP5.*;
import netP5.*;

int choosingPort = 1;

OscP5 oscP5; //to receive message from unity
int listenPort = 12000; //port for listening message from Unity
NetAddress unityAddr; //unity osc server address
DisposeHandler dh;
Serial serial;

void setup() {
  strBuffer = new StringBuffer();
  dh = new DisposeHandler(this);
  oscP5 = new OscP5(this,listenPort);
  unityAddr = new NetAddress("127.0.0.1", 11000);
  if(choosingPort < 0) {
    println("please choose a port:");
    String[] ports = Serial.list();
    for(int i = 0;i < ports.length;i++) {
      println("port " + i + ":" +ports[i]);
    }
    
    exit();
  }
  else {
    try {
      String port = Serial.list()[choosingPort];
      
      //last parameter needs to be the same with Serial.begin in arduino;
      serial = new Serial(this, port, 9600); 
      serial.buffer(256);
      println(port + " connected");
    }
    catch(Exception e) {
      println(e.toString());
      serial = null;
      exit();
    }
  }

}

int lf = 10;    // Linefeed in ASCII

void draw() {
  while(serial.available() > 0) {
    String stringRead = serial.readStringUntil(lf);
    if(stringRead != null) {
      print("msg from arduino:" + stringRead); //dump message from arduino
      //send string read from arduino to Unity
      OscMessage oscMsg = new OscMessage("/ArduinoMsg");
      oscMsg.add(stringRead);
      oscP5.send(oscMsg, unityAddr);
    }
  }

}

StringBuffer strBuffer;
/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  theOscMessage.print();
  
  if(theOscMessage.addrPattern().equals("/arduinoCtrl")) {
    Object[] values = theOscMessage.arguments();
    strBuffer.setLength(0);
    strBuffer.append(values[0].toString());
    for(int i = 1;i < values.length;i++) {
      strBuffer.append(',');
      strBuffer.append(values[i].toString());
    }
    strBuffer.append('\n');
    serial.write(strBuffer.toString());
  }
  
}

//for testing
/*
void keyPressed() {

  if(key == 'b') {
    println("b pressed");
    serial.write("blend\n");
  }
  else if(key == 't') {
    println("t pressed");
    serial.write("test\n");
  }
  else if(key == 'u') {
    println("u pressed");
    OscMessage testMsg = new OscMessage("/ProcessingMsg");
    testMsg.add("foo");
    testMsg.add(456);
    oscP5.send(testMsg, unityAddr);
  }
}
*/


public class DisposeHandler {
   
  DisposeHandler(PApplet pa)
  {
    pa.registerMethod("dispose", this);
  }
   
  public void dispose()
  {      
    println("Closing sketch");
    // Place here the code you want to execute on exit
    if(serial != null) {
      serial.clear();
      serial.stop();
    }
    
    if(oscP5 != null)
      oscP5.stop();
  }
}