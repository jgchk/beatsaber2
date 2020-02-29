import SimpleOpenNI.*;
import java.util.Iterator;

//Generate a SimpleOpenNI object
SimpleOpenNI kinect;

//Vectors used to calculate the center of the mass
PVector com = new PVector();
PVector com2d = new PVector();


PImage calibration;
boolean started = false;
boolean endState = false;
String topText = "Calibrating... please wave your arms";
String bottomText = "The Kinect needs to detect your skeleton";
PFont courier;
PFont HelveticaNeue;
color background = 0;
color bodyStroke = #45E825;
color bodyFill = #45E825;
float bodyStrokeAlpha = 60;
float bodyFillAlpha = 20;
color blockStroke = #D53BEA;
color blockFill = #D53BEA;
ArrayList<block> blocks = new ArrayList();
int bodyBoxSize = 35;
float mapSize = 20000;

float numHit = 0;
float numTotal = 0;
int totalScore = 0;
int currStreak = 0;
int longestStreak = 0;
int multiplier = 0;

void setup() {
  size(1280, 960, P3D);
  setupAudio();
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  //kinect.enableIR();
  kinect.enableUser();// because of the version this change
  //size(kinect.depthWidth()+kinect.irWidth(), kinect.depthHeight());
  kinect.setMirror(false);
  calibration = loadImage("calibration.png");
  ArrayList<note> notes = parseNotes(); 
  courier = createFont("Courier", 40);
  HelveticaNeue = createFont("HelveticaNeue", 40);
  
  mapSize = 1000 * music.length();
  float block_left_x = 200;
  float block_right_x = 900;
  for (note n : notes) {
    float block_w = 150;
    float block_h = 150;
    float block_d = 150;
    float ts = n.timestamp;
    float z = -mapSize;
    if (n.hasRight()) {
      float x = map(n.right.y, 0, 1, 800, width-100);
      float y = map(n.right.y, 0, 1, 100, height-100);
      blocks.add(new block(ts, x, y, z, block_h, block_w, block_d));
    } 
    if (n.hasLeft()) {
      float x = map(n.left.y, 0, 1, 100, 400);
      float y = map(n.left.y, 0, 1, 100, height-100);
      blocks.add(new block(ts, x, y, z, block_h, block_w, block_d));
    } 
  }
  numTotal = blocks.size();
}

void draw() {
  background(background);
  kinect.update();
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {
    started = true;
    int userId = userList.get(0);
    //If we detect one user we have to draw it
    if( kinect.isTrackingSkeleton(userId)) {
      if (music.position() == music.length()) {
        endState = true;
      }
      longestStreak = max(longestStreak, currStreak);
      if (!endState) {
        music.play();
        Iterator<block> blocksIterator = blocks.iterator();
        while (blocksIterator.hasNext()) {
           block b = blocksIterator.next();
           if(b.delete) {
             blocksIterator.remove();
           } else if (b.center.z > 200) { // remove blocks that go past you
             blocksIterator.remove();
             if (!b.destroy) {
               currStreak = 0;
             }
           } else {
             b.update();
             if (b.center.z > -2000) {
               b.display();
             }
           }
        }
        fill(bodyFill);
        textFont(courier);
        textAlign(LEFT);
        textSize(32);
        text("Score: " + totalScore +
             "\nHit Rate: " + round(numHit/(numTotal) * 1000)/10.0 + "%" +
             "\nCurrent Streak: " + currStreak +
             "\nStreak Multiplier: x" + multiplier, 10, 50); 
      } else {
        fill(#68A8F5);
        textAlign(CENTER);
        pushMatrix();
        translate(width/2, 300);
        textSize(65);
        textFont(HelveticaNeue);
        text("Congratulations!", 0,0);
        translate(0, 150);
        textSize(40);
        text("Number hit: " + numHit + 
            "\nNumber missed: " + (numTotal-numHit) + 
            "\nHit Rate: " + round(numHit/(numTotal) * 1000)/10.0 +
            "\nLongest Streak: " + longestStreak +
            "\nOverall Score: " + totalScore,
            0, 0);
            
        
        popMatrix();
      }
      //DrawSkeleton
      MassUser(userId);
      drawSkeleton(userId);

    }
  } else {
    music.pause();
    if (started) {
      topText = "Oops we lost track of you!";
      bottomText = "Please recalibrate by waving your arms";
    }
    background(255);
    image(calibration, 0, 0, width, height);
    textSize(40);
    textFont(HelveticaNeue);
    fill(0);
    pushMatrix();
    translate(width/2, 100);
    textAlign(CENTER);
    text(topText, 0, 0);
    popMatrix();
    pushMatrix();
    translate(width/2, height-100);
    textAlign(CENTER);
    text(bottomText, 0, 0);
    popMatrix();
  }
}
//Draw the skeleton
void drawSkeleton(int userId) {
    newDrawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
    newDrawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
    newDrawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
    newDrawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
    newDrawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    newDrawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
    newDrawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
    newDrawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
    newDrawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
    newDrawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
    newDrawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
    newDrawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
    newDrawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
    newDrawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
    newDrawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
    newDrawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
    newDrawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP);
    newDrawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_HIP);
}

void newDrawLimb(int userId, int joint1ID, int joint2ID) {
    PVector joint1 = new PVector();
    float confidence = kinect.getJointPositionSkeleton(userId, joint1ID,
                                                       joint1);
    if(confidence < 0.5) {
      return;
    }
    PVector convertedJoint1 = new PVector();
    kinect.convertRealWorldToProjective(joint1, convertedJoint1);
    PVector joint2 = new PVector();
    confidence = kinect.getJointPositionSkeleton(userId, joint2ID,
                                                       joint2);
    if(confidence < 0.5) {
            return;
    }
    PVector convertedJoint2 = new PVector();
    kinect.convertRealWorldToProjective(joint2, convertedJoint2);
    
    if (joint1ID == SimpleOpenNI.SKEL_HEAD || joint2ID == SimpleOpenNI.SKEL_HEAD) {
      bodyBoxSize = 35;
    }
    stroke(bodyStroke, bodyStrokeAlpha);
    fill(bodyFill, bodyFillAlpha);
    convertedJoint1.mult(2);
    convertedJoint2.mult(2);
    float zScale = 10.0;
    convertedJoint1.z /= zScale;
    convertedJoint2.z /= zScale;
    convertedJoint1.x = convertedJoint1.x+2*(width/2-convertedJoint1.x);
    convertedJoint2.x = convertedJoint2.x+2*(width/2-convertedJoint2.x);
    convertedJoint1.z = (com2d.z/zScale - convertedJoint1.z)*2 + convertedJoint1.z;
    convertedJoint2.z = (com2d.z/zScale - convertedJoint2.z)*2 + convertedJoint2.z;
    convertedJoint1.z *= -1;
    convertedJoint2.z *= -1;
    //println(convertedJoint1.z
    //strokeWeight(50);
    float num = (dist(convertedJoint1.x, convertedJoint1.y, convertedJoint1.z, convertedJoint2.x, convertedJoint2.y, convertedJoint2.z)/(bodyBoxSize+15));
    for (int i = 0; i <= num; i++) {
      float x = lerp(convertedJoint1.x, convertedJoint2.x, i/num);
      float y = lerp(convertedJoint1.y, convertedJoint2.y, i/num);
      float z = lerp(convertedJoint1.z, convertedJoint2.z, i/num);
      pushMatrix();
      translate(x, y, z);
      box(bodyBoxSize);
      rectMode(CENTER);
      rect(0,0,bodyBoxSize, bodyBoxSize);
      translate(bodyBoxSize/2, bodyBoxSize/2, 0);
      box(bodyBoxSize);
      translate(-bodyBoxSize, -bodyBoxSize, 0);
      box(bodyBoxSize);
      translate(bodyBoxSize, 0, 0);
      box(bodyBoxSize);
      translate(-bodyBoxSize, bodyBoxSize, 0);
      box(bodyBoxSize);
      popMatrix();
    }
    if (isValidLimb(joint1ID, joint2ID)) {
      for (block b: blocks) {
        if (b.center.z > -300 && !b.destroy) {
           checkCollision(convertedJoint1, convertedJoint2, b, joint1ID, joint2ID);
        }
      }
    }
}


void checkCollision(PVector j1, PVector j2, block b, int joint1ID, int joint2ID) {      
  float num = (dist(j1.x, j1.y, j1.z, j2.x, j2.y, j2.z)/2);
  for (int i = 0; i <= num; i++) {
    float x = lerp(j1.x, j2.x, i/num);
    float y = lerp(j1.y, j2.y, i/num);
    float z = lerp(j1.z, j2.z, i/num);
    float xL = x - bodyBoxSize/2;
    float xR = x + bodyBoxSize/2;
    float yT = y - bodyBoxSize/2;
    float yB = y + bodyBoxSize/2;
    if (b.center.z + b.d/2 >= z && b.center.z - b.d/2 <= z) {
      if ((b.center.x - b.w/2 <= xL && b.center.x + b.w/2 >= xL) || (b.center.x - b.w/2 <= xR && b.center.x + b.w/2 >= xR)) {
        if ((b.center.y - b.h/2 <= yB && b.center.y + b.h/2 >= yB) || (b.center.y - b.h/2 <= yT && b.center.y + b.h/2 >= yT)) {
          b.fill = #FFF817;
          b.stroke = #FFF817;
          b.destroy = true;
          numHit++;
          currStreak++;
          totalScore += calcScore(joint1ID, joint2ID);
          break;
        }
      }
    }
  }
}

int calcScore(int j1, int j2) {
  int score = 0;
  multiplier = min(currStreak/8 + 1, 4);
  score += 100;
  if (j2 == SimpleOpenNI.SKEL_LEFT_FOOT || j2 == SimpleOpenNI.SKEL_RIGHT_FOOT) {
    score += 150;
  } else if (j1 == SimpleOpenNI.SKEL_HEAD || j2 == SimpleOpenNI.SKEL_HEAD) {
    score += 200;
  }
  score *= multiplier;
  return score;
}

boolean isValidLimb(int j1, int j2) {
  if (j1 == SimpleOpenNI.SKEL_TORSO || j2 == SimpleOpenNI.SKEL_TORSO) {
    return false;
  } else if (j1 == SimpleOpenNI.SKEL_RIGHT_SHOULDER && j2 != SimpleOpenNI.SKEL_RIGHT_ELBOW) {
    return false;
  } else if (j1 == SimpleOpenNI.SKEL_LEFT_SHOULDER && j2 != SimpleOpenNI.SKEL_LEFT_ELBOW) {
    return false;
  } else if (j1 == SimpleOpenNI.SKEL_RIGHT_HIP && j2 == SimpleOpenNI.SKEL_LEFT_HIP) {
    return false;
  }
  return true;
}

//Calibration not required

void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

void MassUser(int userId) {
  if(kinect.getCoM(userId,com)) {
    kinect.convertRealWorldToProjective(com,com2d);
  }
}
