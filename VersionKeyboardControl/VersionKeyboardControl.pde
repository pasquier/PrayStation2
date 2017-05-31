//import com.NeuroSky.ThinkGear.IO.*;
//import com.NeuroSky.Util.*;
//import com.NeuroSky.ThinkGear.Util.*;
//import pt.citar.diablu.processing.mindset.*;

//import processing.serial.*;
//import cc.arduino.*;

// resources
ArrayList<ArrayList<PImage>> images;
PImage history;

//agent variables
float speed = 1.0;
float size = 1.0;
color[] myPixels; // the pixels without visualization of the agents
ArrayList<AestheticAgent> agents;
float LERP_AMOUNT = 0.1;
static int MAX_AGENTS = 15000;
int NUM_IMAGES = 5;
int rand_x; 
int rand_y;
int rand_img_idx;
int MAX_WAIT = 1000;
int previousTime;
color whiteBG = color(255, 255, 255);
color blackBG = color(0);
color currentColor;
int[][] directions = {
  {0, 1, 2}, // forward normal
  {-1, 0, 1}, // mid normal
  {-2, -1, 0}, // backward normal
  {0, 1, 3}, // forward fast
  {-3, -1, 0, 1, 3}, // mid fast
  {-3, -1, 0}, // backward fast
};
boolean isVisible = true;

final int CHRISTIANITY   = 0;
final int ISLAM          = 1;
final int ATHEIST        = 2;
final int HINDUISM       = 3;
final int CHINESE        = 4;
final int BUDDHISM       = 5;
final int ANIMISM        = 6;

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
int newSwitchValue = -1;

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
  agents = new ArrayList<AestheticAgent>();

  //setup images
  images = new ArrayList();
  for (int i = 0; i < 7; i++) {
    images.add(new ArrayList<PImage>());
  }
  for (int i = 0; i < NUM_IMAGES; i++) {
    images.get(CHRISTIANITY).add(loadImage("Christianity-" + i + ".jpg"));
  }
  for (int i = 0; i < NUM_IMAGES; i++) {
    images.get(ISLAM).add(loadImage("Islam-" + i + ".jpg"));
  }
  for (int i = 0; i < NUM_IMAGES; i++) {
    images.get(ATHEIST).add(loadImage("Atheist-" + i + ".jpg"));
  }
  for (int i = 0; i < NUM_IMAGES; i++) {
    images.get(HINDUISM).add(loadImage("Hinduism-" + i + ".jpg"));
  }
  for (int i = 0; i < NUM_IMAGES; i++) {
    images.get(CHINESE).add(loadImage("ChineseTraditionalReligions-" + i + ".jpg"));
  }
  for (int i = 0; i < NUM_IMAGES; i++) {
    images.get(BUDDHISM).add(loadImage("Buddhism-" + i + ".jpg"));
  }
  for (int i = 0; i < NUM_IMAGES; i++) {
    images.get(ANIMISM).add(loadImage("Animism-" + i + ".jpg"));
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

  loadPixels();  
  myPixels = new color[width * height];
  arrayCopy(pixels, myPixels);
}

void keyPressed() {
  print(key);
  switch (key) {
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

  case 's':
  case 'S':
    saveFrame("output/output-######.jpg");
    break;

  case 'v':
  case 'V':
    isVisible = !isVisible;
    break;
  
  // keys to change speed variable
  case 'q':
  case 'Q':
    speed = 1.0;
    println("\nspeed: " + speed);
    break;
  case 'w':
  case 'W':
    speed = 2.0;
    println("\nspeed: " + speed);
    break;
  case 'e':
  case 'E':
    speed = 3.0;
    println("\nspeed: " + speed);
    break;
  case 'r':
  case 'R':
    speed = 5.0;
    println("\nspeed: " + speed);
    break;
  case 't':
  case 'T':
    speed = 8.0;
    println("\nspeed: " + speed);
    break;
  case 'y':
  case 'Y':
    speed = 15.0;
    println("\nspeed: " + speed);
    break;
  
  // keys to change speed variable
  case 'u':
  case 'U':
    size = 1.0;
    println("\nsize: " + size);
    break;
  case 'i':
  case 'I':
    size = 2.0;
    println("\nsize: " + size);
    break;
  case 'o':
  case 'O':
    size = 3.0;
    println("\nsize: " + size);
    break;
  case 'p':
  case 'P':
    size = 4.0;
    println("\nsize: " + size);
    break;
  }
}

void draw() {
  //fill((int)random(255));
  //ellipse(100, 100, 100, 100);

  //  //read rotary switch pins
  //  bit1 = arduino.digitalRead(pin1) * 1;
  //  bit2 = arduino.digitalRead(pin2) * 2;
  //  bit3 = arduino.digitalRead(pin3) * 4;
  //  delay(20);
  //  newSwitchValue = bit1 + bit2 + bit3; 

  //change 
  if (newSwitchValue != currentSwitchValue) {
    //crude debounce! get gray-coded switch next time!

    //decides where to create the agents
    currentSwitchValue = newSwitchValue;
    //println(currentSwitchValue);
    //seek out white space over already painted
    for (int i = 0; i <= 100000; i++) {
      rand_x = int(random(width-1));
      rand_y = int(random(height-1));
      currentColor = pixels[rand_y*width+rand_x];
      if (currentColor == blackBG) {
        //white pixel found - quit search
        i = 100001;
      }
    }
    rand_img_idx = (int)random(NUM_IMAGES);
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

  //update currently existing agents   
  loadPixels();
  int currentSize = agents.size();
  //println(currentSize);
  for (int i = currentSize-1; i >= 0; i--) {
    AestheticAgent agent = (AestheticAgent) agents.get(i);
    agent.feed();
    agent.move();

    if (agent.getLifespan() <= 0) {
      agent.die();
      agents.remove(i);
    }
  }
  updatePixels();

  //Phil added
  signalStrength=0;

  //spawn new agent
  //if (signalStrength == 0) {
  if (signalStrength == 0 && keyPressed) {
    if (agents.size() < MAX_AGENTS) {
      // if(millis()-previousTime > ( 0 - (attention + meditation * 5) )) {
      //previousTime = millis();

      //Christianity
      if (currentSwitchValue == 0) {
        //if (key == '1') {
        agents.add(new AestheticAgent(rand_x, rand_y, CHRISTIANITY, rand_img_idx, 1000, speed, size));
      }
      //Islam
      else if (currentSwitchValue == 1) {
        //else if (key == '2') {
        agents.add(new AestheticAgent(rand_x, rand_y, ISLAM, rand_img_idx, 1000, speed, size));
      }
      //Agnostic
      else if (currentSwitchValue == 2) {
        //else if (key == '3') {
        agents.add(new AestheticAgent(rand_x, rand_y, int(random(6)), rand_img_idx, 1000, speed, size));
      }
      //Aetheist
      else if (currentSwitchValue == 3) {
        //else if (key == '4') {
        agents.add(new AestheticAgent(rand_x, rand_y, ATHEIST, rand_img_idx, 1000, speed, size));
      }
      //Hinduism
      else if (currentSwitchValue == 4) {
        //else if (key == '5') {
        agents.add(new AestheticAgent(rand_x, rand_y, HINDUISM, rand_img_idx, 100, speed, size));
      }
      //Chinese Folk 
      else if (currentSwitchValue == 5) {
        //else if (key == '6') {
        agents.add(new AestheticAgent(rand_x, rand_y, CHINESE, rand_img_idx, 800, speed, size));
      }
      //Buddhism
      else if (currentSwitchValue == 6) {
        //else if (key == '7') {
        agents.add(new AestheticAgent(rand_x, rand_y, BUDDHISM, rand_img_idx, 1000, speed, size));
      }
      //Animism
      else if (currentSwitchValue == 7) {
        //else if (key == '8') {
        agents.add(new AestheticAgent(rand_x, rand_y, ANIMISM, rand_img_idx, 1000, speed, size));
      }
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