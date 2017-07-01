using System;
using System.Net;
using System.Collections.Generic;

using UnityEngine;
using UnityOSC;

public class OSCTest : MonoBehaviour {

	OSCClient client;
	OSCServer server;


	// Use this for initialization
	void Start () {
		client = new OSCClient(IPAddress.Parse("127.0.0.1"), 12000); // send message to arduino through 12000
		server = new OSCServer(11000); // receive message from processing through 11000
		server.PacketReceivedEvent += OnPacketReceived;
	}
	
	// Update is called once per frame
	void Update () {
		if(Input.GetKeyDown(KeyCode.K)) {
			OSCMessage msg = new OSCMessage("/arduinoCtrl");
			msg.Append("test"); //add a string
			client.Send(msg);			
		}		
		else if(Input.GetKeyDown(KeyCode.T)) {
			OSCMessage msg = new OSCMessage("/arduinoCtrl");
			msg.Append("blend"); //add a string
			client.Send(msg);	
		}
	}

	void OnApplicationQuit() {
		if(client != null)
			client.Close();
		if(server != null) 
			server.Close();
	}

	void OnPacketReceived(OSCServer server, OSCPacket packet)
    {
		//if a packet is received from arduino, this function will be called
		Debug.Log("addr:" + packet.Address);
		List<object> dataList = packet.Data;
		for(int i = 0;i < dataList.Count;i++) {
			Debug.Log("data " + i + ":" + dataList[i].ToString());
		}

    }
}
