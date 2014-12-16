// LecturesInGraphics: utilities
// Colors, pictures, text formatting
// Author: Jarek ROSSIGNAC, last edited on September 10, 2012

// ************************************************************************ COLORS 
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB;

// ************************************************************************ GRAPHICS 
void pen(color c, float w) {
  stroke(c); 
  strokeWeight(w);
}
void showDisk(float x, float y, float r) {
  ellipse(x, y, r*2, r*2);
}

// ************************************************************************ IMAGES & VIDEO 
int pictureCounter=0;
PImage myFace;
PImage power;
void snapPicture() {
  saveFrame("PICTURES/P"+nf(pictureCounter++, 3)+".jpg");
}

// ************************************************************************ TEXT 
Boolean scribeText=true; // toggle for displaying of help text
void scribe(String S, float x, float y) {
  fill(0); 
  text(S, x, y); 
  noFill();
} // writes on screen at (x,y) with current fill color
void scribeHeader(String S, int i) {
  fill(0); 
  text(S, 10, 20+i*20); 
  noFill();
} // writes black at line i
void scribeHeaderRight(String S) {
  fill(0); 
  text(S, width-7.5*S.length(), 20); 
  noFill();
} // writes black on screen top, right-aligned
void scribeFooter(String S, int i) {
  fill(0); 
  text(S, 10, height-10-i*20); 
  noFill();
} // writes black on screen at line i from bottom
void scribeAtMouse(String S) {
  fill(0); 
  text(S, mouseX, mouseY); 
  noFill();
} // writes on screen near mouse
void scribeMouseCoordinates() {
  fill(black);
  //if (mode == Mode.deltoid) {
    
    //text(""+currentBisector.getDisplayWidth(), mouseX+7, mouseY-5);
  //}
  
  text("("+mouseX+","+mouseY+")", mouseX+7, mouseY+35); 
  noFill();
}
void displayHeader() { // Displays title and authors face on screen
  scribeHeader(title, 0); 
  scribeHeaderRight(name); 
  image(myFace, width-myFace.width/2, 25, myFace.width/2, myFace.height/2); 
  //image(myFace2, (width-myFace.width), 25, myFace.width/2, myFace.height/2);
}
void displayFooter() { // Displays help text at the bottom
  scribeFooter(guide, 1); 
  scribeFooter(menu, 0);
}

void drawEdges() {
  //draw the sticks
 
  
  for(int i = 0; i < edges.size(); i++){
    pushMatrix();
    noStroke(); 
    edge thisEdge = (edge) edges.get(i);
    translate(thisEdge.midX, thisEdge.midY); rotate(thisEdge.rotation); 
    rectMode(CENTER); 
    fill(color(200, 200, 255));
    rect(0f, 0f, thisEdge.getDisplayWidth(), rectHeight);
    popMatrix();
  }
 
  
  if (currentEdge != null) {
    pushMatrix();
    noStroke(); 
    translate(currentEdge.midX, currentEdge.midY); rotate(currentEdge.rotation); 
    rectMode(CENTER);
    fill(red);
    rect(0f, 0f, currentEdge.getDisplayWidth(), rectHeight);
    popMatrix();
  }
}

void drawVertices() {
  for (int i = 0; i < vertices.size(); i++) {
    stroke(0,255,0);
    PVector thisVertex = (PVector) vertices.get(i);
    fill(color(255, 255, 255));
    ellipse(thisVertex.x, thisVertex.y, 40.0, 40.0);
    scribe(Integer.toString(i), thisVertex.x, thisVertex.y);
  } 
}

void drawCorners(){
  noStroke();
  
  if(!stopDrawAllCorners){
    fill(color(0,0,0));
    for (int i = 0; i < cornerList.size();i++){
      cornerRef = (Corner)cornerList.get(i);
      ellipse(cornerRef.x1, cornerRef.y1, 10, 10);
    }
  }
  else{
    dist = 999999.0;
    
    for (int i = 0; i < cornerList.size();i++){
      cornerRef = (Corner)cornerList.get(i);
      distCurrent = distance(mouseCX, mouseCY, cornerRef.x1, cornerRef.y1);
      if(distCurrent < dist){
        dist = distCurrent;
        drawCornerID = i;
      }
    }
    
    
    
    cornerRef = (Corner)cornerList.get(drawCornerID);
    if(nextkey){
      mouseCX = ((Corner)cornerList.get(cornerRef.next)).x1;
      mouseCY = ((Corner)cornerList.get(cornerRef.next)).y1;
      nextkey = false;
    }
    if(previouskey){
      mouseCX = ((Corner)cornerList.get(cornerRef.prev)).x1;
      mouseCY = ((Corner)cornerList.get(cornerRef.prev)).y1;
      previouskey = false;
    }
    if(swingkey){
      mouseCX = ((Corner)cornerList.get(cornerRef.swing)).x1;
      mouseCY = ((Corner)cornerList.get(cornerRef.swing)).y1;
      swingkey = false;
    }
    
    fill(color(255,0,0));
    ellipse(cornerRef.x1, cornerRef.y1, 10, 10);
    
    cornerRef1 = (Corner)cornerList.get(cornerRef.next);
    fill(color(0,0,255));
    ellipse(cornerRef1.x1, cornerRef1.y1, 10, 10);
    
    cornerRef2 = (Corner)cornerList.get(cornerRef.swing);
    fill(color(0,255,0));
    ellipse(cornerRef2.x1, cornerRef2.y1, 10, 10);
  }
}



//************************ capturing frames for a movie ************************
boolean filming=false;  // when true frames are captured in FRAMES for a movie
int frameCounter=0;     // count of frames captured (used for naming the image files)
boolean change=false;   // true when the user has presed a key or moved the mouse
boolean animating=false; // must be set by application during animations to force frame capture

