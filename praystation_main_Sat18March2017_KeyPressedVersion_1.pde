//import com.NeuroSky.ThinkGear.IO.*;
//import com.NeuroSky.Util.*;
//import com.NeuroSky.ThinkGear.Util.*;
//import pt.citar.diablu.processing.mindset.*;

//import processing.serial.*;
//import cc.arduino.*;


//agent variables
PImage [] images;
PImage history;
ArrayList agents;
float LERP_AMOUNT = 0.1;
static int MAX_AGENTS = 10000;
int NUM_IMAGES = 7;
int rand_x; 
int rand_y;
int MAX_WAIT = 1000;
int previousTime;
color whiteBG = color(255, 255, 255);
color currentColor;


//Mindset variables
//MindSet r;
int attention = 0;
int meditation = 0;
int signalStrength = 200;

//Arduino variables
//Arduino arduino;
//pins for rotary switch
int pin1 = 2;                    
int pin2 = 3;  
int pin3 = 4; 

//pins for guages
int meditationGuagePin = 9;   
int attentionGaugePin = 10; 

//pin for connection LED
int connectionLEDPin = 7;
int BLINK_RATE = 250;
boolean blink = true;
int blinkTimer;

//rotary switch variables
int bit1 = 0;
int bit2 = 0;
int bit3 = 0;
int currentSwitchValue = -1;
int newSwitchValue = 0;

//image timer
int imageTimer;

void setup() {
  //environmental variables
  size(1024, 768);
  //background(255, 255, 255);
  background(0);

  //history = loadImage("../output.jpg");
  //image(history,0,0);

  //setup agents
  agents = new ArrayList();
  images = new PImage [NUM_IMAGES];

  for (int i = 0; i < NUM_IMAGES; i++) {
    PImage img;
    String file = "" + i + ".jpg";
    img =  loadImage(file);
    images[i] = img;
  }

//  //set up Arduino 
//  arduino = new Arduino(this, Arduino.list()[0], 57600);
//  arduino.pinMode(pin1, Arduino.INPUT);
//  arduino.pinMode(pin2, Arduino.INPUT);
//  arduino.pinMode(pin3, Arduino.INPUT);
//  arduino.pinMode(meditationGuagePin, Arduino.OUTPUT);
//  arduino.pinMode(attentionGaugePin, Arduino.OUTPUT);
//  arduino.pinMode(connectionLEDPin, Arduino.OUTPUT);

//  //set up Mindset - check port on host machine
//  r = new MindSet(this, "/dev/cu.MindSet-DevB");

  //start timers
  blinkTimer = millis();
  previousTime = millis();
  imageTimer = millis();

  loadPixels();1
}


void keyPressed() {
  print(key);
  switch (key){
  case '1':
  newSwitchValue=0;
  break;
  case '2':
  newSwitchValue=1;
  break;
  case '3':
  newSwitchValue=2;
  break;
  case '4':
  newSwitchValue=3;
  break;
  case '5':
  newSwitchValue=4;
  break;
  case '6':
  newSwitchValue=5;
  break;
  case '7':
  newSwitchValue=6;
  break;
  case '8':
  newSwitchValue=7;
  break;
  }
}

void draw() {


//  //read rotary switch pins
//  bit1 = arduino.digitalRead(pin1) * 1;
//  bit2 = arduino.digitalRead(pin2) * 2;
//  bit3 = arduino.digitalRead(pin3) * 4;
//  delay(20);
//  newSwitchValue = bit1 + bit2 + bit3; 


  //change 
  if (newSwitchValue != currentSwitchValue) {
    //crude debounce! get gray-coded switch next time!

    currentSwitchValue = newSwitchValue;
    //println(currentSwitchValue);
    //seek out white space over already painted
    for (int i = 0; i <= 100000; i++) {
      rand_x =  int(random(width-1));
      rand_y = int(random(height-1));
      currentColor = pixels[rand_y*width+rand_x];
      if (currentColor == whiteBG) {
        //white pixel found - quit search
        i = 100001;
      }
    }
  }

//  //update guages and connectivity LED
//  if (signalStrength == 200) {
//    arduino.digitalWrite(connectionLEDPin, Arduino.LOW);
//    delay(20);
//  }
//  else if (signalStrength == 0) {
//    arduino.digitalWrite(connectionLEDPin, Arduino.HIGH);
//    delay(20);
//    arduino.analogWrite(attentionGaugePin, attention);
//    delay(20);
//    arduino.analogWrite(meditationGuagePin, meditation);
//    delay(20);
//  }
//  else {
//    if (millis() > blinkTimer + BLINK_RATE) {
//      arduino.analogWrite(attentionGaugePin, 0);
//      delay(20);
//      arduino.analogWrite(meditationGuagePin, 0);
//      delay(20);
//      blinkTimer = millis(); // reset start time
//      if (blink) {
//        arduino.digitalWrite(connectionLEDPin, Arduino.HIGH);
//        delay(20);
//      }
//      else {
//        arduino.digitalWrite(connectionLEDPin, Arduino.LOW);
//        delay(20);
//      }
//      blink = !blink;
//    }
//  }

  //update agents   
  loadPixels();
  int currentSize = agents.size();
  //println(currentSize);
  for (int i = currentSize-1; i >= 0; i--) {
    AestheticAgent agent = (AestheticAgent) agents.get(i);
    agent.feed();
    agent.move();
    if (agent.getLifespan() <= 0) {
      agents.remove(i);
    }
  }
  updatePixels();

//Phil added
signalStrength=0;


  //spawn new agent
  if (signalStrength == 0 ) {
    if (agents.size() < MAX_AGENTS) {
      // if(millis()-previousTime > ( 0 - (attention + meditation * 5) )) {
      //previousTime = millis();
      //Christianity
      //if (currentSwitchValue == 0) {
        if (key == '1') {
        agents.add(new AestheticAgent(rand_x, rand_y, 0, 1000));
      }
      //Islam
      // else if (currentSwitchValue == 1) {
        else if (key == '2') {
        agents.add(new AestheticAgent(rand_x, rand_y, 1, 1000));
      }
      //Agnostic
      //else if (currentSwitchValue == 2) {
         else if (key == '3') {
        agents.add(new AestheticAgent(rand_x, rand_y, int(random(6)), 1000));
      }
      //Aetheist
      //else if (currentSwitchValue == 3) {
         else if (key == '4') {
        agents.add(new AestheticAgent(rand_x, rand_y, 2, 1000));
      }
      //Hinduism
      //else if (currentSwitchValue == 4) {
         else if (key == '5') {
        agents.add(new AestheticAgent(rand_x, rand_y, 3, 1000));
      }
      //Chinese Folk 
      //else if (currentSwitchValue == 5) {
         else if (key == '6') {
        agents.add(new AestheticAgent(rand_x, rand_y, 4, 1000));
      }
      //Buddhism
      // else if (currentSwitchValue == 6) {
         else if (key == '7') {
        agents.add(new AestheticAgent(rand_x, rand_y, 5, 1000));
      }
      //Animism
      //else if (currentSwitchValue == 7) {
         else if (key == '8') {
        agents.add(new AestheticAgent(rand_x, rand_y, 6, 1000));
      }
      //}
    }
  }
  if (millis() > imageTimer + 600000) {
    //println("Pic Taken");
    save("output.jpg"); 
    imageTimer = millis();
  }
}

public void poorSignalEvent(int sig) {
  signalStrength = sig;
  println(sig);
}

public void attentionEvent(int attentionLevel) {
  attention = int(map(attentionLevel, 0, 100, 0, 255));
  println("Attention Level: " + attentionLevel);
}

public void meditationEvent(int meditationLevel) {
  meditation = int(map(meditationLevel, 0, 100, 0, 255));
  println("Meditation Level: " + meditationLevel);
}

void stop()
{
  //disconnect mindset
//  r.quit();
  super.stop();
}
