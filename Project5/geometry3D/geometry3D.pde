float dz=0; // distance to camera. Manipulated with wheel or when 
float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI;    // view angles manipulated when space pressed but not mouse
Boolean twistFree=false, animating=false, center=true, showControlPolygon=true, showFloor=false, showExtrusion = false, drawBottom =false, drawTop=false;
float t=0, s=0;
pt F = P(0,0,0);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
pt O=P(100,100,0); // red point controlled by the user via mouseDrag : used for inserting vertices ...
int extrusionZ = 200;
pt g_center = null;
boolean fShouldPick = false;
public pt pickNew(int mX, int mY)
{
  PGL pgl = beginPGL();
  FloatBuffer depthBuffer = ByteBuffer.allocateDirect(1 << 2).order(ByteOrder.nativeOrder()).asFloatBuffer();
  pgl.readPixels(mX, height - mY - 1, 1, 1, PGL.DEPTH_COMPONENT, PGL.FLOAT, depthBuffer);
  float depthValue = depthBuffer.get(0);
  depthBuffer.clear();
  endPGL();

  //get 3d matrices
  PGraphics3D p3d = (PGraphics3D)g;
  PMatrix3D proj = p3d.projection.get();
  PMatrix3D modelView = p3d.modelview.get();
  PMatrix3D modelViewProjInv = proj; modelViewProjInv.apply( modelView ); modelViewProjInv.invert();
  
  float[] viewport = {0, 0, p3d.width, p3d.height};
  
  float[] normalized = new float[4];
  normalized[0] = ((mX - viewport[0]) / viewport[2]) * 2.0f - 1.0f;
  normalized[1] = ((height - mY - viewport[1]) / viewport[3]) * 2.0f - 1.0f;
  normalized[2] = depthValue * 2.0f - 1.0f;
  normalized[3] = 1.0f;
  
  float[] unprojected = new float[4];
  
  modelViewProjInv.mult( normalized, unprojected );
  return P( unprojected[0]/unprojected[3], unprojected[1]/unprojected[3], unprojected[2]/unprojected[3] );
}
void setup() {
  myFace = loadImage("data/Vibhav.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  size(600, 600, P3D); // p3D means that we will do 3D graphics
  P.declare(); Q.declare(); PtQ.declare(); // P is a polyloop in 3D: declared in pts
  
  
  //P.resetOnCircle(12,100); // used to get started if no model exists on file 
  P.loadData("../../../P04/output");  // loads saved model from file
  noSmooth();
  
  //P.storeCorners("data/sidewalk1");
  //P.storeCorners("data/sidewalk2");
  //P.setCornerNextPreviousSwing();
  //P.printGVNS();
  //P.setExtrusion(extrusionZ);
  //Q.loadPts("data/pts2");  // loads saved model from file
  }

void draw() {
  background(255);
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
    camera();       // sets a standard perspective
    translate(width/2,height/2,dz); // puts origin of model at screen center and moves forward/away by dz
    lights();  // turns on view-dependent lighting
    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
    rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
    if(center) translate(-F.x,-F.y,-F.z);
    noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor
    if(showFloor) {
      showFrame(50); // X-red, Y-green, Z-blue arrows
      fill(yellow); pushMatrix(); translate(0,0,-1.5); box(400,400,1); popMatrix(); // draws floor as thin plate
      fill(magenta); show(F,4); // magenta focus point (stays at center of screen)
      fill(magenta,100); showShadow(F,5); // magenta translucent shadow of focus point (after moving it up with 'F'
      if(showControlPolygon) {
        pushMatrix(); 
        fill(grey,100); scale(1,1,0.01); P.drawClosedCurveAsRods(4); 
        P.drawBalls(4); 
        popMatrix();} // show floor shadow of polyloop
      }
    //fill(black); show(O,4); 
    //fill(red,100); showShadow(O,5); // show red tool point and its shadow

    computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame    
    pp=P.idOfVertexWithClosestScreenProjectionTo(Mouse()); // id of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...


    
    if(showControlPolygon) {
      fill(green); P.drawCurveAsRods(4); P.drawBalls(4);
      //fill(green); P.drawClosedCurveAsRods(4); P.drawBalls(4); // draw curve P as cones with ball ends
     // fill(red); Q.drawClosedCurveAsRods(4); Q.drawBalls(4); // draw curve Q
      //fill(green,100); P.drawBalls(5); // draw semitransluent green balls around the vertices
      //fill(grey,100); show(P.closestProjectionOf(O),6); // compputes and shows the closest projection of O on P
      //fill(red,100); P.showPicked(6); // shows currently picked vertex in red (last key action 'x', 'z'
      }
      
      fill(black);P.drawBallsCorners(4);
      if(showExtrusion){
        //fill(red); P.drawBallsExtrusion(4);
        stroke(blue);fill(cyan);showWallsExtrusion(P);
      }
      if(drawBottom){
        noStroke();fill(green);
        P.drawBottom();
      }
      if(drawTop){
        noStroke();fill(green);
        P.drawTop();
      }
      
      if ( fShouldPick )
    {
      g_center = pickNew( mouseX, mouseY );
      
    
    if ( g_center != null )
      {
        pushMatrix();
        P.drawCornerNextSwing(g_center);
        //translate( g_center.x, g_center.y, g_center.z );
        //sphere(20);
        //translate( -g_center.x, -g_center.y, -g_center.z );
        popMatrix();
      }
      fShouldPick = false;
    }
  
  // replace the following 2 lines by display of the extrucded polygonal model
  //fill(cyan); stroke(blue); showWalls(P,Q);  
  //noStroke(); fill(yellow); P.drawClosedLoop(); 
  //fill(orange); Q.drawClosedLoop();
  
  //fill(green); S1.drawClosedCurveAsRods(4); S1.drawBalls(4);
  //fill(green); S2.drawClosedCurveAsRods(4); S2.drawBalls(4);
  
  
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas

  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX,mouseY,26,26); fill(red); text(key,mouseX-5,mouseY+4);}
    // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (animating) { t+=PI/180*2; if(t>=TWO_PI) t=0; s=(cos(t)+1.)/2; } // periodic change of time 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  }
  
void keyPressed() {
  if(key=='?') scribeText=!scribeText;
  if(key=='!') snapPicture();
  if(key=='~') filming=!filming;
  if(key==']') showControlPolygon=!showControlPolygon;
  if(key=='0') P.flatten();
  if(key=='_') showFloor=!showFloor;
  if(key=='q') Q.copyFrom(P);
  if(key=='p') P.copyFrom(Q);
  if(key=='e') {PtQ.copyFrom(Q);Q.copyFrom(P);P.copyFrom(PtQ);}
  if(key=='.') F=P.Picked(); // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if(key=='x' || key=='z' || key=='d') P.setPickedTo(pp); // picks the vertex of P that has closest projeciton to mouse
  if(key=='d') P.deletePicked();
  if(key=='i') P.insertClosestProjection(O); // Inserts new vertex in P that is the closeset projection of O
  if(key=='W') {P.savePts("data/pts"); Q.savePts("data/pts2");}  // save vertices to pts2
  //if(key=='L') {P.loadPts("data/pts"); Q.loadPts("data/pts2");}   // loads saved model
  if(key=='w') P.savePts("data/pts");   // save vertices to pts
  //if(key=='l') P.loadPts("data/pts"); 
  if(key=='a') animating=!animating; // toggle animation
  if(key=='#') exit();
  if(key == 'E') showExtrusion = !showExtrusion;
  if(key=='y') {
    //P.insertCornerAtClosestVertex(pp, 0);
    P.addExtrusionCorners();
  }
  if(key=='Y') P.insertCornerAtClosestVertex(pp, 1);
  if(key=='R') P.resetPrevCorner();
  if(key=='P') P.printGVNS();
  if(key=='Q') P.insertCornersAtQuads();
  //if(key=='B') drawBottom = !drawBottom;
  //if(key=='T') drawTop = !drawTop;
  if(key=='B') {P.doBridgeEdgeStuff(); drawTop=!drawTop;drawBottom=!drawBottom;}
  if(key=='N') P.setCornerToNext();
  if(key=='S') P.setCornerToSwing();
  if(key=='o'){P.addExtrusionCorners();P.insertCornersAtQuads();showExtrusion=!showExtrusion;drawTop=!drawTop;drawBottom=!drawBottom;showControlPolygon=!showControlPolygon;}
  if(key=='O'){P.addExtrusionCorners();P.insertCornersAtQuads();showExtrusion=!showExtrusion;showControlPolygon=!showControlPolygon;}
  if(key=='`') 
  {
    fShouldPick = true;
  }
  change=true;
  }

void mouseWheel(MouseEvent event) {dz -= event.getAmount(); change=true;}

void mouseMoved() {
  if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
  if (keyPressed && key=='s') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
  }
  
void mouseDragged() {
  if (!keyPressed) {O.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); }
  if (keyPressed && key==CODED && keyCode==SHIFT) {O.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));};
  if (keyPressed && key=='x') P.movePicked(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='z') P.movePicked(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='X') P.moveAll(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='Z') P.moveAll(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));
  if (keyPressed && key=='N') P.moveExtrusion(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));
  if (keyPressed && key=='M') P.moveExtrusion(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));
  if (keyPressed && key=='f') { // move focus point on plane
    if(center) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  if (keyPressed && key=='F') { // move focus point vertically
    if(center) F.sub(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  }  

// **** Header, footer, help text on canvas
void displayHeader() { // Displays title and authors face on screen
    scribeHeader(title,0); scribeHeaderRight(name); 
    fill(white); image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
    }
void displayFooter() { // Displays help text at the bottom
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }

String title ="3D Extrusion of a poly-loop", name ="Vibhav Gupta",
       menu="`: for picking a corner,N: to go to next corner, S: to go to swing corner",
       guide="O: shows extrusion of the sidewalks,B: shows bridge edges"; // user's guide


