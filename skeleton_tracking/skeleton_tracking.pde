import SimpleOpenNI.*;

//Generate a SimpleOpenNI object
SimpleOpenNI kinect;

//Vectors used to calculate the center of the mass
PVector com = new PVector();
PVector com2d = new PVector();

//Up
float LeftshoulderAngle = 0;
float LeftelbowAngle = 0;
float RightshoulderAngle = 0;
float RightelbowAngle = 0;

//Legs
float RightLegAngle = 0;
float LeftLegAngle = 0;

//Timer variables
float a = 0;

PImage calibration;
boolean started = false;
String topText = "Calibrating... please wave your arms";
String bottomText = "The Kinect needs to detect your skeleton";

color background = 0;
color bodyStroke = #45E825;
color bodyFill = #45E825;
float bodyStrokeAlpha = 170;
float bodyFillAlpha = 70;
color blockStroke = #D53BEA;
color blockFill = #D53BEA;
block testBlock;
void setup() {
        size(1280, 960, P3D);
        kinect = new SimpleOpenNI(this);
        kinect.enableDepth();
        //kinect.enableIR();
        kinect.enableUser();// because of the version this change
        //size(kinect.depthWidth()+kinect.irWidth(), kinect.depthHeight());
        kinect.setMirror(false);
        calibration = loadImage("calibration.png");
        testBlock = new block(100, 100, -1000, 200, 200, 200); 
}

void draw() {
      background(background);
        kinect.update();
        //image(kinect.depthImage(), 0, 0, width, height);
        //println(kinect.depthImage().width,kinect.depthImage().height);
        //image(kinect.irImage(),kinect.depthWidth(),0);
        //image(kinect.userImage(),0,0);
        IntVector userList = new IntVector();
        kinect.getUsers(userList);
        if (userList.size() > 0) {
          testBlock.update();
          testBlock.display();
          started = true;
                int userId = userList.get(0);
                //If we detect one user we have to draw it
                if( kinect.isTrackingSkeleton(userId)) {
                        //Draw the user Mass
                        MassUser(userId);
                        //DrawSkeleton
                        drawSkeleton(userId);
                }
        } else {
          if (started) {
            topText = "Oops we lost track of you!";
            bottomText = "Please recalibrate by waving your arms";
          }
          background(255);
          image(calibration, 0, 0, width, height);
          textSize(40);
          stroke(0);
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
    int boxSize = 30;
    if (joint1ID == SimpleOpenNI.SKEL_HEAD || joint2ID == SimpleOpenNI.SKEL_HEAD) {
      boxSize = 35;
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
    println("com", com2d.z);
    println("conv", convertedJoint1.z);
    convertedJoint1.z = (com2d.z/zScale - convertedJoint1.z)*2 + convertedJoint1.z;
    convertedJoint2.z = (com2d.z/zScale - convertedJoint2.z)*2 + convertedJoint2.z;
    //strokeWeight(50);
    float num = (dist(convertedJoint1.x, convertedJoint1.y, convertedJoint2.x, convertedJoint2.y)/boxSize);
    for (int i = 0; i <= num; i++) {
      float x = lerp(convertedJoint1.x, convertedJoint2.x, i/num);
      float y = lerp(convertedJoint1.y, convertedJoint2.y, i/num);
      float z = lerp(convertedJoint1.z, convertedJoint2.z, i/num);
      pushMatrix();
      translate(x, y, -z);
      box(boxSize);
      rectMode(CENTER);
      rect(0,0,boxSize, boxSize);
      translate(boxSize/2, boxSize/2, 0);
      box(boxSize);
      translate(-boxSize, -boxSize, 0);
      box(boxSize);
      translate(boxSize, 0, 0);
      box(boxSize);
      translate(-boxSize, boxSize, 0);
      box(boxSize);
      popMatrix();
    }
    checkCollision(convertedJoint1, convertedJoint2);
    //line(convertedJoint1.x, convertedJoint1.y, convertedJoint2.x, convertedJoint2.y);
}


void checkCollision(PVector j1, PVector j2) {
  
}




//Generate the angle
float angleOf(PVector one, PVector two, PVector axis) {
        PVector limb = PVector.sub(two, one);
        return degrees(PVector.angleBetween(limb, axis));
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


