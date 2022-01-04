import processing.serial.*;
import controlP5.*;
ControlP5 cp5;

DropdownList dpl;

int COMPort = 2;
int port = -1;

Serial myPort;	// The serial port
PFont f;

String inData;
String[] lines;
String[] data = {"0","0"};
int index = 0;
int recieve = 0;
int cnt = 0;

PGraphics plannedTemps;
PGraphics actualTemps;


void setup() {
	
	// List all the available serial ports
	printArray(Serial.list());
	// Open the port you are using at the rate you want:
	//myPort = new Serial(this, Serial.list()[COMPort], 115200);
	cp5 = new ControlP5(this);
	cp5.setAutoDraw(false);
	dpl = cp5.addDropdownList("COMPORTS")
				.setPosition(100,100);
	customize(dpl);
	
	frameRate(30);
	stroke(0);
	strokeWeight(5);
	size(800, 600);
	f = createFont("Arial",16,true);
	textFont(f,16);

	plannedTemps = createGraphics(700, height);
	actualTemps	= createGraphics(700, height);	

	initGraph();
//	myPort.write("rst" + '\0' + "x");
}

void draw() {
 
	
	background(204);
	if(port != -1){
		translate(0,height);
		scale(1,-1);
		
		image(plannedTemps, 50, 0);
		readSerial();
		addTempPoint();
		updateTime();
		updateTemp();
		writeSerial();
	}
	else{
		cp5.draw();
	}
//	println(port);
}

void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(30);
  ddl.setHeight(30*(Serial.list().length+1));
  ddl.setBarHeight(15);
  for (int i=0;i<Serial.list().length;i++) {
    ddl.addItem(Serial.list()[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.
 // myPort.stop();
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
  //  println("event from group : "+ theEvent.getGroup().getValue() +" from "+ theEvent.getGroup());
   port = (int)theEvent.getGroup().getValue();
    myPort = new Serial(this, Serial.list()[port], 115200);
  } 
  else if (theEvent.isController()) {
  //  println("event from controller : "+ theEvent.getController().getValue() +" from "+ theEvent.getController());
   port = (int)theEvent.getController().getValue();
    myPort = new Serial(this, Serial.list()[port], 115200);
  }
  frameRate(1);
  myPort.write("rst" + '\0' + "x");
}



/**
/ void initGraph(void)
/	Initalizes the planned temperature graph
/	according to the .csv file OvenProfile.
/
*/
void initGraph(){
//	int x1 = 0;
//	int y1 = 0;
	int x2 = 0;
	int y2 = 0;
	
	translate(0,height);
	scale(1,-1);
	lines = loadStrings("OvenProfile.csv");
	
	plannedTemps.beginDraw();
	plannedTemps.strokeWeight(5);
	
	while(index<lines.length){
		String[] pieces = split(lines[index], ',');
		if (pieces.length == 2) {
			x2 = int(pieces[0]);
			y2 = int(pieces[1]);
			//plannedTemps.line(x1, y1, x2, y2);
			plannedTemps.point(x2+50, y2);
		}
//		x1 = x2;
//		y1 = y2;
		index++;
	}
	plannedTemps.endDraw();
}

void addTempPoint(){
	if(int(data[1]) == 1){actualTemps = createGraphics(700, height);}
	actualTemps.beginDraw();
	actualTemps.strokeWeight(5);
	actualTemps.stroke(255, 0, 0);
	actualTemps.point(int(data[1]), int(data[0]));
	actualTemps.endDraw();
	image(actualTemps, 100, 0);
}

void updateTemp(){
	text(int(data[0]), width/3, height/12);
}

void updateTime(){
	translate(0, height);
	scale(1, -1);
	
	stroke(0);	
	fill(0);
	textAlign(CENTER);

	if(int(data[1])%60 < 10){
		text(int(data[1])/60 + ":0" + int(data[1])%60, 2*width/3, height/12);
	}
	else{
		text(int(data[1])/60 + ":"	+ int(data[1])%60, 2*width/3, height/12);
	}

}

void readSerial(){
	if (myPort.available() > 0) {
		recieve = 1;
		inData = myPort.readString();
//		println(inData);
		data = split(inData, ',');
		print(data[0] + " : ");
		print(data[1] + "\n");
	}
}

void writeSerial(){
	if(recieve == 1){
		String templateTemp = "0";
		
		if(int(data[1]) > lines.length){
		return;
		}
		
		String[] pieces = split(lines[int(data[1])], ',');
		if (pieces.length == 2) {
			templateTemp = pieces[1];
		}

		myPort.write(templateTemp + '\0' + "x");
		recieve = 0;
	}
	
	
}