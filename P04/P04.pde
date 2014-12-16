/**************************** HEADER ****************************
 LecturesInGraphics: Template for Processing sketches in 2D
 Template author: Jarek ROSSIGNAC
 Class: CS3451 Fall 2014
 Student: ??
 Project number: ??
 Project title: ??
 Date of submission: ??
 *****************************************************************/


//**************************** global variables ****************************
float x, y; // coordinates of blue point controlled by the user
float vx=1, vy=0; // velocities
float xb, yb; // coordinates of base point, recorded as mouse location when 'b' is released
float rectWidth, rectHeight;
ArrayList edges;
ArrayList vertices;
boolean foundCloseVertex = false;

// Structures for project 4
ArrayList vertexList;
ArrayList edgePolygonList;
int prevVertexID = -1;
Vertex vertexRef = null;
Vertex vertexNeighborRef = null;
edgePolygon edgePolygonRef = null;
PVector vectorRef;
PVector vectorRef1;
PVector vectorRef2;
PVector vectorRef3;
Vertex cornerVertexRef;
PVector cornerVectorRef;
ArrayList cornerList;
Corner cornerRef;
Corner cornerRef1;
Corner cornerRef2;
Corner cornerRef3;
Corner cornerNextRef;
Corner cornerPrevRef;
Corner cornerSwingRef;
int startNeighborID;
int currentNeighborID;
float theta = 0;
PVector rotatingPoint;
PVector comparePoint;
int flag;
boolean stopDrawAllCorners = false;
float dist, distCurrent;
int drawCornerID;
float mouseCX, mouseCY;
int cornerVertexID;
int swingOrUnswing;
int neighbor2ID;
float angleOfRotation;
int adjVertexID;
int neighborID;
int cornerID;
boolean nextkey = false;
boolean previouskey = false;
boolean swingkey = false;

edge currentEdge = null;
Mode mode = Mode.polygon;
float s = 0.5;
float d = 0;

//*************** text drawn on the canvas for name, title and help  *******************
String title ="Project 04: Corner Data Structure Implementation", name ="Vibhav Gupta", // enter project number and your name
menu="Draw polyloop by mouse press and move, Press space to draw all corners,O: to write output data", 
guide=""; // help info

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(700, 700);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  rectWidth = 100f;
  rectHeight = 5f;
  myFace = loadImage("data/Vibhav.jpg");  // loads image from file pic.jpg in folder data, replace it with a clear pic of your face
  power = loadImage("data/power.png"); // loads power image
  xb=x=width/2; 
  yb=y=height/2; // must be executed after size() to know values of width...
  x = mouseX;
  y = mouseY;
  edges = new ArrayList();
  vertices = new ArrayList();
  cornerVectorRef = new PVector();
  vectorRef = new PVector();
  vectorRef1 = new PVector();
  vectorRef2 = new PVector();
  vectorRef3 = new PVector();
  vertexList = new ArrayList();
  edgePolygonList = new ArrayList();
  cornerList = new ArrayList();
  rotatingPoint = new PVector();
  comparePoint = new PVector();
}

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  pen(black, 3); // sets stroke color (to balck) and width (to 3 pixels)

  if (keyPressed) {
    fill(black); 
    text(key, mouseX-2, mouseY);
  } // writes the character of key if still pressed
  if (!mousePressed && !keyPressed) scribeMouseCoordinates(); // writes current mouse coordinates if nothing pressed

  if (animating) {
    x+=vx; 
    y+=vy; // move the blue point by its current velocity
    if (y<0) {
      y=-y; 
      vy=-vy;
    } // collision with the ceiling
    if (y>height) {
      y=height*2-y; 
      vy=-vy;
    } // collision with the floor
    if (x<0) {
      x=-x; 
      vx=-vx;
    } // collision with the left wall
    if (x>width) {
      x=width*2-x; 
      vx=-vx;
    } // collision with the right wall
    vy+=.1; // add vertical gravity
  }

  drawEdges();
  drawVertices();
  drawCorners();
  

  displayHeader();
  if (scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if (filming && (animating || change)) saveFrame("FRAMES/"+nf(frameCounter++, 4)+".tif");  
  change=false; // to avoid capturing frames when nothing happens
  // make sure that animating is set to true at the beginning of an animation and to false at the end

  x+=mouseX-pmouseX;
  y+=mouseY-pmouseY;
  
   
}  // end of draw()

void printData(){
  String [] inppts = new String [vertexList.size()+cornerList.size()+edgePolygonList.size()+3];
  int s=0;
  inppts[s++]=str(vertexList.size());
  for (int i=0; i<vertexList.size(); i++) {inppts[s++]=str(((Vertex)vertexList.get(i)).x1)+","+str(((Vertex)vertexList.get(i)).y1)+","+str(10);}
  inppts[s++]=str(edgePolygonList.size());
  for (int i=0; i<edgePolygonList.size(); i++) {
    inppts[s++]=str(((edgePolygon)edgePolygonList.get(i)).startVertexID) +","+str(((edgePolygon)edgePolygonList.get(i)).endVertexID);
  }
  inppts[s++]=str(cornerList.size());
  for (int i=0; i<cornerList.size(); i++) {
    inppts[s++]=str(((Corner)cornerList.get(i)).x1)+","+str(((Corner)cornerList.get(i)).y1)+","+str(10)+"," +str(getCornerVertexID(i))+","+str(((Corner)cornerList.get(i)).next);
  }
  
  saveStrings("output",inppts);
}

//************************* mouse and key actions ****************************
void keyPressed() { // executed each time a key is pressed: the "key" variable contains the correspoinding char,
  if (key=='O') printData();
  if (key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if (key=='!') snapPicture(); // make a picture of the canvas
  if (key=='~') { 
    filming=!filming;
  } // filming on/off capture frames into folder FRAMES
  if(key == 'N'){
    nextkey = true;
  }
  if(key == 'P'){
    previouskey = true;
  }
  if(key == 'S'){
    swingkey = true;
  }
  if (key==' ') { //Do all the processing of vertices, edgePolygonList, etc. And find corners
    
    if (mode == Mode.polygon) {
      // connect last vertex to first vertex and create corresponding edge
      if (vertices.size() > 2) {
        PVector lastVertex = (PVector) vertices.get(vertices.size()-1);
        PVector firstVertex = (PVector) vertices.get(0);
        currentEdge = new edge(lastVertex.x, lastVertex.y, firstVertex.x, firstVertex.y);
        //edges.add(currentEdge);
        currentEdge = null;
        
        
      }
    }
    
    // Print edgePolygonList
    for (int i = 0; i < edgePolygonList.size(); i++){
      edgePolygonRef = (edgePolygon)edgePolygonList.get(i);
      println(i+" " + "startVertex=" + edgePolygonRef.startVertexID+",endVertex="+edgePolygonRef.endVertexID);
    }
    
    for (int i = 0; i < vertexList.size(); i++){
      vertexRef = (Vertex)vertexList.get(i);
      for (int j = 0; j < edgePolygonList.size(); j++){
        edgePolygonRef = (edgePolygon)edgePolygonList.get(j);
        if(i == edgePolygonRef.startVertexID){
          vertexRef.neighbors.add(edgePolygonRef.endVertexID);
        }
        else if(i == edgePolygonRef.endVertexID){
          vertexRef.neighbors.add(edgePolygonRef.startVertexID);
        }
      }
    }
    
    // Print vertexList 
    for (int i = 0; i < vertexList.size();i++){
      vertexRef = (Vertex)vertexList.get(i);
      println("Vertex ID="+i +" " + vertexRef.x1 +", " + vertexRef.y1 +" previous=" + vertexRef.previous + " next="+vertexRef.next);
      println("Printing neighbors");
      for (int j = 0; j < vertexRef.neighbors.size();j++){
        print(vertexRef.neighbors.get(j) +",");
      }
      println();
    }
    computeCorners();
    computeCornersNextorPrevious(1); // 1 means corner.next
    //computeCornersNextorPrevious(0); // 0 means corner.prev
    
    // Handling cases which have -1 as their next and prev
  for (int i = 0; i < cornerList.size(); i++){
    cornerRef = (Corner)cornerList.get(i);
    if(cornerRef.prev == -1 || cornerRef.next == -1){
      cornerVertexID = getCornerVertexID(i);
      vertexRef = (Vertex)vertexList.get(cornerVertexID);
      for (int j = 0; j < vertexRef.corners.size(); j++){
        if((Integer)vertexRef.corners.get(j) != i){
          if(cornerRef.prev == -1){
            cornerRef.prev = (Integer)vertexRef.corners.get(j);
          }
          else{
            cornerRef.next = (Integer)vertexRef.corners.get(j);
          }
          break;
        }
      }
    }
  }
  
  computeSwingCorners();

  
  /*println("Printing next/prev corners");
  for (int i = 0; i < cornerList.size(); i++){
    println("Corner ID = " + i);
    cornerRef = (Corner)cornerList.get(i);
    println ("Corner " + cornerRef.x1+","+cornerRef.y1);
    if(cornerRef.next != -1){
      cornerNextRef = (Corner)cornerList.get(cornerRef.next);
      println ("Corner Next " + cornerNextRef.x1+","+cornerNextRef.y1);
    }
    else{
      println("Corner Next -1");
    }
    if(cornerRef.prev != -1){
      cornerPrevRef = (Corner)cornerList.get(cornerRef.prev);
      println ("Corner Prev " + cornerPrevRef.x1+","+cornerPrevRef.y1);
    }
    else{
      println("Corner Prev -1");
    }
    
    if(cornerRef.swing != -1){
      cornerSwingRef = (Corner)cornerList.get(cornerRef.swing);
      println("Corner swing " + cornerSwingRef.x1+","+cornerSwingRef.y1);
    }
    else{
      println("Corner swing -1");
    }
   }*/
  }
  if (key == 'C'){ 
    // Stop drawing all the corners
    // Draw just the nearest corner to mouse
    // Draw c.s, c.n and c.p
    mouseCX = mouseX;
    mouseCY = mouseY;
    stopDrawAllCorners = true;
  }
  if (key=='a') animating=true;  // quit application
  if (key=='Q') exit();  // quit application
  change=true;
}

int getCornerVertexID(int cornerID){
  for(int i =0; i < vertexList.size(); i++){
    vertexRef = (Vertex)vertexList.get(i);
    for(int j = 0; j < vertexRef.corners.size(); j++){
      if((Integer)vertexRef.corners.get(j) == cornerID){
        return i;
      }
    }
  }
  return -1; // just in case
}

int getCornerNextorPreviousVertexID1(int cornerID, int cornerVertexID, int flag){
  int vertex1;
  int vertex2;  
  
  cornerRef = (Corner)cornerList.get(cornerID);
  vertex1 = cornerRef.adjVertexID1;
  vertex2 = cornerRef.adjVertexID2;
  
  if (flag == 1){
    for (int i = 0; i < edgePolygonList.size(); i++){
      edgePolygonRef = (edgePolygon)edgePolygonList.get(i);
      if(edgePolygonRef.startVertexID == cornerVertexID && edgePolygonRef.endVertexID == vertex1){
        return vertex1;
      }
      else if(edgePolygonRef.startVertexID == cornerVertexID && edgePolygonRef.endVertexID == vertex2){
        return vertex2;
      }
    }
  }
  else{
    for (int i = 0; i < edgePolygonList.size(); i++){
      edgePolygonRef = (edgePolygon)edgePolygonList.get(i);
      if(edgePolygonRef.startVertexID == cornerVertexID && edgePolygonRef.endVertexID == vertex1){
        return vertex2;
      }
      else if(edgePolygonRef.startVertexID == cornerVertexID && edgePolygonRef.endVertexID == vertex2){
        return vertex1;
      }
    }
  }
  return -1; 
}
int getCornerNextorPreviousVertexID2(int cornerID, int cornerVertexID, int flag){
  int vertex1;
  int vertex2;
  PVector v = new PVector();
  float ptX, ptY;
  float theta=0.0;
  float lEdge=0.0;
  int nextVertexID = -1;  
  
  cornerRef = (Corner)cornerList.get(cornerID);
  vertex1 = cornerRef.adjVertexID1;
  vertex2 = cornerRef.adjVertexID2;
  
  v.x = ((Vertex)vertexList.get(vertex1)).x1 - ((Vertex)vertexList.get(cornerVertexID)).x1;
  v.y = ((Vertex)vertexList.get(vertex1)).y1 - ((Vertex)vertexList.get(cornerVertexID)).y1;
  //println("other vertex = " + vertex1);
  if(((Vertex)vertexList.get(cornerVertexID)).neighbors.size()<2){
  }
  else
  {
    lEdge = distance(((Vertex)vertexList.get(cornerVertexID)).x1, ((Vertex)vertexList.get(cornerVertexID)).y1, 
            ((Vertex)vertexList.get(vertex2)).x1,((Vertex)vertexList.get(vertex2)).y1); 
  }
  
  while(theta<2*3.14){
    
    theta+=0.01;
    v.normalize();
    v.rotate(0.01);
    
    
    if(((Vertex)vertexList.get(cornerVertexID)).neighbors.size()<2){
      v.mult(35);
      ptX = ((Vertex)vertexList.get(cornerVertexID)).x1 + v.x;
      ptY = ((Vertex)vertexList.get(cornerVertexID)).y1 + v.y;
      if(distance(ptX,ptY,cornerRef.x1,cornerRef.y1)<1){nextVertexID=vertex1;break;}
      if(theta>3.14){nextVertexID= -1;return -1;}
    }
    else{
      v.mult(35);
      ptX = ((Vertex)vertexList.get(cornerVertexID)).x1 + v.x;
      ptY = ((Vertex)vertexList.get(cornerVertexID)).y1 + v.y;
      if(distance(ptX,ptY,cornerRef.x1, cornerRef.y1)<1){
        nextVertexID=vertex1; break;
      }
      v.normalize();
      v.mult(lEdge);
      ptX = ((Vertex)vertexList.get(cornerVertexID)).x1 + v.x;
      ptY = ((Vertex)vertexList.get(cornerVertexID)).y1 + v.y;
      if(distance(ptX,ptY,((Vertex)vertexList.get(vertex2)).x1, ((Vertex)vertexList.get(vertex2)).y1)<1){
        nextVertexID=vertex2;break;
      }
      
      }
  }
  //println("nextVertexID = " + nextVertexID);
  
  PVector v1 = new PVector();
  float nextCornerX;
  float nextCornerY;
  
  v1.x = ((Vertex)vertexList.get(cornerVertexID)).x1 - ((Vertex)vertexList.get(nextVertexID)).x1;
  v1.y = ((Vertex)vertexList.get(cornerVertexID)).y1 - ((Vertex)vertexList.get(nextVertexID)).y1;
  v1.normalize();
  v1.mult(35);
  
  theta =0.0;
  while(theta> -1.0*2.0*3.14){
    theta-=0.01;
    v1.rotate(-0.01);
    nextCornerX = ((Vertex)vertexList.get(nextVertexID)).x1 + v1.x;
    nextCornerY = ((Vertex)vertexList.get(nextVertexID)).y1 + v1.y;
    for(int i=0; i < ((Vertex)vertexList.get(nextVertexID)).corners.size(); i++){
      if(distance(nextCornerX, nextCornerY, ((Corner)cornerList.get((Integer)((Vertex)vertexList.get(nextVertexID)).corners.get(i))).x1,
      ((Corner)cornerList.get((Integer)((Vertex)vertexList.get(nextVertexID)).corners.get(i))).y1) < 1){
        return (Integer)((Vertex)vertexList.get(nextVertexID)).corners.get(i);
      }
    }
  }
  return -1;
  
  /*if (flag == 1){
     if(vertex1 > vertex2){
       return vertex1;
     }
     else{
       return vertex2;
     }
      
  }
  else{
    if(vertex1 > vertex2){
       return vertex2;
     }
     else{
       return vertex1;
     }
  }*/
   
}
void computeSwingCorners(){
 int vertexID1 = -1;
 int vertexID2 = -1;
  for (int i = 0; i < cornerList.size(); i++){
    cornerRef = (Corner)cornerList.get(i);
    cornerVertexID = getCornerVertexID(i);
    vertexRef = (Vertex)vertexList.get(cornerVertexID);
    
    if(vertexRef.corners.size() == 2){
      //println("entering for cornerID = " + i);
      //println("vertex corner size = " + vertexRef.corners.size());
      for (int j = 0; j < vertexRef.corners.size(); j++){
        if((Integer)vertexRef.corners.get(j) != i){
          cornerRef.swing = (Integer)vertexRef.corners.get(j);
          break;
        }
      }
    }
    else{
      for (int j = 0; j < vertexRef.neighborSwingOrder.size(); j++){
        if(((Integer)vertexRef.neighborSwingOrder.get(j) == cornerRef.adjVertexID1 || (Integer)vertexRef.neighborSwingOrder.get(j) == cornerRef.adjVertexID2)
          && ((Integer)vertexRef.neighborSwingOrder.get((j+1)%vertexRef.neighborSwingOrder.size())==cornerRef.adjVertexID1 ||
               (Integer)vertexRef.neighborSwingOrder.get((j+1)%vertexRef.neighborSwingOrder.size())==cornerRef.adjVertexID2)){
          vertexID1 = (Integer)vertexRef.neighborSwingOrder.get((j+1)%vertexRef.neighborSwingOrder.size());
          vertexID2 = (Integer)vertexRef.neighborSwingOrder.get((j+2)%vertexRef.neighborSwingOrder.size());
         break; 
        }
      }
      for (int j = 0; j < vertexRef.corners.size(); j++){
        cornerRef1 = (Corner)cornerList.get((Integer)vertexRef.corners.get(j));
        if((cornerRef1.adjVertexID1 == vertexID1 && cornerRef1.adjVertexID2 == vertexID2) ||
           (cornerRef1.adjVertexID1 == vertexID2 && cornerRef1.adjVertexID2 == vertexID1)){
             cornerRef.swing = (Integer)vertexRef.corners.get(j);
             break;
           } 
      }
    }
  }
}
void computeCornersNextorPrevious(int flag){
  
  //println("Starting computing Corners Next");
  //for(int i = 0; i < cornerList.size(); i++){
  //  cornerRef = (Corner)cornerList.get(i);
  //  println("Corners " + cornerRef.x1+","+cornerRef.y1);
  //}
  println("printing corner and nexts");
  for(int i = 0; i <cornerList.size(); i++){
    cornerRef = (Corner)cornerList.get(i);
    cornerVertexID = getCornerVertexID(i);
    
    //if(((Vertex)vertexList.get(cornerVertexID)).neighbors.size() < 2){
    //  continue;
    //}
    
      adjVertexID = getCornerNextorPreviousVertexID2(i, cornerVertexID, flag);
      //println("swingCornerID = " + adjVertexID);
      cornerRef.next = adjVertexID;
      println("cornerID = " + i + " coordinates =" +cornerRef.x1+","+cornerRef.y1+" nextCornerID = " + cornerRef.next);
      /*if(adjVertexID == -2) println("Error computing next vertex"); //continue;
    
      vertexRef = (Vertex)vertexList.get(adjVertexID);
      cornerVertexRef = (Vertex)vertexList.get(cornerVertexID);
      
      println("corner id = " + i);
      println("corner vertex id = " + cornerVertexID);
      println("adj vertex id = " + adjVertexID);
      
      
      vectorRef.x = cornerVertexRef.x1 - vertexRef.x1;
      vectorRef.y = cornerVertexRef.y1 - vertexRef.y1;
      println("vectorRef = " + vectorRef.x+","+vectorRef.y);
      
      vectorRef.normalize();
      vectorRef.mult(100);
      
      vectorRef1.x = cornerRef.x1 - vertexRef.x1;
      vectorRef1.y = cornerRef.y1 - vertexRef.y1;
      println("vectorRef1 = " + vectorRef1.x+","+vectorRef1.y);
      vectorRef1.normalize();
      vectorRef1.mult(100);
      
      swingOrUnswing = findSwingOrUnswing(vectorRef, vectorRef1, vertexRef);
      println("swingOrUnswing = " + swingOrUnswing);
      println("vertexID ="+adjVertexID+",cornerVertexID="+cornerVertexID);
      neighbor2ID = getNeighbor2ID(swingOrUnswing, adjVertexID, cornerVertexID);
      
     if(neighbor2ID != -1){
        println("neighbor2ID = " + neighbor2ID);
      
        GetCornerFromBisector(vertexRef.v, cornerVertexRef.v, ((Vertex)vertexList.get(neighbor2ID)).v, vectorRef2);
      
        vectorRef1.x = ((Vertex)vertexList.get(neighbor2ID)).x1 - vertexRef.x1;
        vectorRef1.y = ((Vertex)vertexList.get(neighbor2ID)).y1 - vertexRef.y1;
        println("vectorRef1 = " + vectorRef1.x+","+vectorRef1.y);
        vectorRef1.normalize();
        vectorRef1.mult(100);
        println("I am here");
      
      
        angleOfRotation = getTheta (swingOrUnswing, vectorRef, vectorRef1, vertexRef);
        println("angleOfRotation = " + angleOfRotation);
        cornerVectorRef.x = vertexRef.x1;
        cornerVectorRef.y = vertexRef.y1;
        if(abs(angleOfRotation) > 3.14){
          cornerVectorRef.sub(vectorRef2);
        }
        else{
          cornerVectorRef.add(vectorRef2);
        }
      
        if (flag == 1){
        println("next corner for ("+ cornerRef.x1+","+cornerRef.y1+")="+cornerVectorRef.x+","+cornerVectorRef.y);
        }
        else{
          println("prev corner for ("+ cornerRef.x1+","+cornerRef.y1+")="+cornerVectorRef.x+","+cornerVectorRef.y);
        }
        
     }
     else{
       vectorRef.normalize();
       if(swingOrUnswing == 1){
         vectorRef.rotate(-1.57);
       
       }
       else{
         vectorRef.rotate(1.57);
       }
       cornerVectorRef.x = vertexRef.x1;
       cornerVectorRef.y = vertexRef.y1;
       vectorRef.mult(35);
       cornerVectorRef.add(vectorRef);
       if(flag == 1){
        println("next corner for ("+ cornerRef.x1+","+cornerRef.y1+")="+cornerVectorRef.x+","+cornerVectorRef.y);
       }
       else{
         println("previous corner for ("+ cornerRef.x1+","+cornerRef.y1+")="+cornerVectorRef.x+","+cornerVectorRef.y);
       }
     }
     cornerID = getCornerIDFromCoordinates(cornerVectorRef.x, cornerVectorRef.y, vertexRef);
     if(flag == 1){
       cornerRef.next = cornerID;
       ((Corner)cornerList.get(cornerID)).prev = i;
     }
    else{
        cornerRef.prev = cornerID;
       ((Corner)cornerList.get(cornerID)).next = i;
    } */
  } 
}
int getCornerIDFromCoordinates(float x, float y, Vertex V){
  float d;
  int id = -1;
  Corner cornerRef1;
  d = 99999.0;
  
  for (int i = 0; i < V.corners.size();i++){
    cornerRef1 = (Corner)cornerList.get((Integer)V.corners.get(i));
    if(distance(x,y,cornerRef1.x1, cornerRef1.y1) < d){
      d = distance(x,y,cornerRef1.x1, cornerRef1.y1);
      id = (Integer)V.corners.get(i);
    }
  }
  return id;
      
}
float getTheta(int swingOrUnswing, PVector vec1, PVector vec2, Vertex V){
  float d;
  comparePoint.x = V.x1 + vec2.x;
  comparePoint.y = V.y1 + vec2.y;
  
  vectorRef3.x = vec1.x;
  vectorRef3.y = vec1.y;
  
  theta = 0;
  while (abs(theta) < 2 * 3.14){
    rotatingPoint.x = V.x1 + vectorRef3.x;
    rotatingPoint.y = V.y1 + vectorRef3.y;
  
    d = distance(rotatingPoint.x, rotatingPoint.y, comparePoint.x, comparePoint.y);
    //println("distance = " + d);
    if(d < 5){
      break;
      
    }
    if(swingOrUnswing == 1){
      theta -= 0.01;
      vectorRef3.rotate(-0.01);
    }
    else{
      theta += 0.01;
      vectorRef3.rotate(0.01);
    }
  }
  return theta;
  
}
int getNeighbor2ID(int swingOrUnswing, int vertexID, int cornerVertexID){
  vertexRef =(Vertex)vertexList.get(vertexID);
  for (int i = 0; i < vertexRef.neighborSwingOrder.size(); i++){
    println("neighbor swing order = "+ (Integer)vertexRef.neighborSwingOrder.get(i));
  }
  for (int i = 0; i < vertexRef.neighborSwingOrder.size(); i++){
    
    if((Integer)vertexRef.neighborSwingOrder.get(i) == cornerVertexID){
      if(swingOrUnswing == 0){
        return (Integer)vertexRef.neighborSwingOrder.get((i+1)%vertexRef.neighborSwingOrder.size());
       
      }
      else{
        if(i!=0){
        return (Integer)vertexRef.neighborSwingOrder.get((i-1)%vertexRef.neighborSwingOrder.size());
        }
        else{
          return (Integer)vertexRef.neighborSwingOrder.get(vertexRef.neighborSwingOrder.size() - 1);
        }
        //return neighborID;
        //return 0;
      }
    }
  }
  return -1;
  
}
int findSwingOrUnswing(PVector vec1, PVector vec2, Vertex V){
  float d;
  vectorRef3.x = vec1.x;
  vectorRef3.y = vec1.y;
  comparePoint.x = V.x1 + vec2.x;
  comparePoint.y = V.y1 + vec2.y;
  
  theta = 0;
  while(true){
    rotatingPoint.x = V.x1 + vectorRef3.x;
    rotatingPoint.y = V.y1 + vectorRef3.y;
    d = distance(rotatingPoint.x, rotatingPoint.y, comparePoint.x, comparePoint.y);
    //println("distance = "+ d);
    if(d < 5.0){
      if(theta > 3.14){
        return 1;
      }
      else{
        return 0;
      }
    }
    theta += 0.01;
    vectorRef3.rotate(0.01);
  }
}
void computeCornersPrevious(){
  
}
void computeCorners(){
    // Find corners for each vertex
    // If neighborlist has 1 element, that means there are 2 corners at 90 degree
    // Else no. of corners is equal to no. of neighbors and we find them using angle bisectors.
    
    for (int i = 0; i < vertexList.size(); i++){
      vertexRef = (Vertex)vertexList.get(i);
      if(vertexRef.neighbors.size() == 1){
        vertexNeighborRef = (Vertex)vertexList.get((Integer)vertexRef.neighbors.get(0));
        
        vectorRef.x = vertexNeighborRef.v.x;
        vectorRef.y = vertexNeighborRef.v.y;
        
        vectorRef.sub(vertexRef.v);
        vectorRef.normalize();
        //vectorRef.rotate(1.57);
        vectorRef.mult(35);
        
        //println("vertexRef = " + vertexRef.v.x+"," + vertexRef.v.y);
        cornerVectorRef.x = vertexRef.v.x;
        cornerVectorRef.y = vertexRef.v.y;
        cornerVectorRef.sub(vectorRef);
        //println("vertexRef = " + vertexRef.v.x+"," + vertexRef.v.y);
        cornerList.add(new Corner(cornerVectorRef.x, cornerVectorRef.y, (Integer)vertexRef.neighbors.get(0), -1));
        //println("vertex ID =" + i+ " corner coords = "+ cornerVectorRef.x+","+cornerVectorRef.y);
        vertexRef.corners.add(cornerList.size() - 1);
        //println("vertexRef = " + vertexRef.v.x+"," + vertexRef.v.y);
        //cornerVectorRef.x = vertexRef.v.x;
        //cornerVectorRef.y = vertexRef.v.y;
        //cornerVectorRef.sub(vectorRef);
        //cornerList.add(new Corner(cornerVectorRef.x, cornerVectorRef.y, (Integer)vertexRef.neighbors.get(0), -1));
        //println("vertex ID =" + i+ " corner coords = "+ cornerVectorRef.x+","+cornerVectorRef.y);
        //vertexRef.corners.add(cornerList.size() - 1);
        }
        else{
          
          //for (int j = 0; j < vertexRef.neighbors.size();j++){
          //  vertexRef.neighborVisited.add(0);
          //}
          vertexRef.neighborSwingOrder.add((Integer)vertexRef.neighbors.get(0));
          //vertexRef.neighborVisited.set(0,1);
          startNeighborID = (Integer)vertexRef.neighbors.get(0);
          currentNeighborID = startNeighborID;
          theta = 0;
          flag = 0;
          while(true){
            
            vectorRef.x = ((Vertex)(vertexList.get(currentNeighborID))).x1 - vertexRef.x1;
            vectorRef.y = ((Vertex)(vertexList.get(currentNeighborID))).y1 - vertexRef.y1;
            
            vectorRef.normalize();
            vectorRef.mult(100);
            vectorRef.rotate(theta);
            
            rotatingPoint.x = vertexRef.x1 + vectorRef.x;
            rotatingPoint.y = vertexRef.y1 + vectorRef.y;
            
            for (int k = 0; k < vertexRef.neighbors.size(); k++){
              if((Integer)vertexRef.neighbors.get(k) != currentNeighborID){
                vectorRef1.x = ((Vertex)(vertexList.get((Integer)vertexRef.neighbors.get(k)))).x1 - vertexRef.x1;
                vectorRef1.y = ((Vertex)(vertexList.get((Integer)vertexRef.neighbors.get(k)))).y1 - vertexRef.y1;
                
                vectorRef1.normalize();
                vectorRef1.mult(100);
                
                comparePoint.x = vertexRef.x1 + vectorRef1.x;
                comparePoint.y = vertexRef.y1 + vectorRef1.y;
                
                //println("theta="+theta+" distance between vertex " + i + " and neighbor " + vertexRef.neighbors.get(k) + " = " + distance(rotatingPoint.x, rotatingPoint.y, comparePoint.x, comparePoint.y));
                if(distance(rotatingPoint.x, rotatingPoint.y, comparePoint.x, comparePoint.y) < 5.0){
                  flag = 1;
                  if((Integer)vertexRef.neighbors.get(k) != startNeighborID){
                  vertexRef.neighborSwingOrder.add((Integer)vertexRef.neighbors.get(k));
                  }
                  //vertexRef.neighborVisited.set(k, 1);
                  GetCornerFromBisector(vertexRef.v, ((Vertex)vertexList.get(currentNeighborID)).v, ((Vertex)vertexList.get((Integer)vertexRef.neighbors.get(k))).v, vectorRef2);
                  cornerVectorRef.x = vertexRef.x1;
                  cornerVectorRef.y = vertexRef.y1;
                  
                  //println("vectorRef2 = "+vectorRef2.x+","+vectorRef2.y);
                  if(theta <= 3.14){
                    cornerVectorRef.add(vectorRef2);
                  }
                  else{
                    cornerVectorRef.sub(vectorRef2);
                  }
                  cornerList.add(new Corner(cornerVectorRef.x, cornerVectorRef.y, currentNeighborID, (Integer)vertexRef.neighbors.get(k)));
                  vertexRef.corners.add(cornerList.size() - 1);
                  theta = 0; 
                  currentNeighborID = (Integer)vertexRef.neighbors.get(k);
                  break;
                }
              }
            }
           theta += 0.01;
          if((flag == 1) && (currentNeighborID == startNeighborID))
             break; 
          } 
        } 
      }
}
void GetCornerFromBisector(PVector vertex, PVector neighbor1, PVector neighbor2, PVector ref){
  PVector vectorRef1 = new PVector();
  PVector vectorRef2 = new PVector();
  
  //println("neighbor1 = " + neighbor1.x+","+neighbor1.y);
  //println("neighbor2 = " + neighbor2.x+","+neighbor2.y);
  //println("vertex = " + vertex.x+","+vertex.y);
  vectorRef1.x = neighbor1.x;
  vectorRef1.y = neighbor1.y;
  vectorRef1.sub(vertex);
  
  vectorRef2.x = neighbor2.x;
  vectorRef2.y = neighbor2.y;
  vectorRef2.sub(vertex);
  
  vectorRef1.normalize();
  vectorRef2.normalize();
  vectorRef1.add(vectorRef2);
  vectorRef1.normalize();
  vectorRef1.mult(35);
  
  ref.x = vectorRef1.x;
  ref.y = vectorRef1.y;
  
}

void keyReleased() { // executed each time a key is released
  if (key=='b') {
    xb=mouseX; 
    yb=mouseY;
  }
  if (key=='a') animating=false;  // quit application
  change=true;
}

void mouseDragged() { // executed when mouse is pressed and moved
  change=true;
}

void mouseMoved() { // when mouse is moved
  change=true;
  if (currentEdge != null) {
    currentEdge.setPoint2(mouseX, mouseY); 
  }
}

void mousePressed(MouseEvent e) { // when mouse key is pressed
  change = true;
}
float distance(float x1, float y1, float x2, float y2){
  float dist = sqrt(sq(x1-x2) + sq(y1-y2));
  //println("distance = " + dist);
  return dist;
}
boolean insideEllipseAtVertex (PVector center, float mousex, float mousey){
 
  if(distance(center.x, center.y, mousex, mousey) <= 40){
    
    return true;
  }
  else{
    return false;
  }
}
boolean edgeExists(int startVertexID, int endVertexID){
  for (int i = 0; i < edgePolygonList.size(); i++){
    edgePolygonRef = (edgePolygon)edgePolygonList.get(i);
    if((edgePolygonRef.startVertexID == startVertexID && edgePolygonRef.endVertexID == endVertexID) ||
       (edgePolygonRef.startVertexID == endVertexID && edgePolygonRef.endVertexID == startVertexID))
       return true;
  }
  return false;
}
void mouseReleased(MouseEvent e) { // when mouse key is released
  change = true;
  if (mode == Mode.polygon) {
    if (edges.size() == 0) { // first edge not created yet
      if (currentEdge != null) {    // edge currently being created
        
        // If the vertex is inside the ellipse of some vertex, snap it that vertex
        
        foundCloseVertex = false;
        for (int i = 0; i < vertices.size(); i++){
          if(insideEllipseAtVertex((PVector)vertices.get(i), mouseX, mouseY)){
            currentEdge = new edge(((PVector)vertices.get(i)).x, ((PVector)vertices.get(i)).y, ((PVector)vertices.get(i)).x, ((PVector)vertices.get(i)).y);
            foundCloseVertex = true;
            break;
          }
        }
        if(!foundCloseVertex){
          vertices.add(new PVector(mouseX, mouseY));
          println("new vertex = (" + mouseX + ", " + mouseY + ") : #" + vertices.size());
          edges.add(currentEdge);
          currentEdge = new edge(mouseX, mouseY, mouseX, mouseY);
          
          
          vertexList.add(new Vertex((float)mouseX, (float)mouseY, prevVertexID, -1));
          edgePolygonList.add(new edgePolygon(prevVertexID, vertexList.size() - 1));
          vertexRef = (Vertex)vertexList.get(prevVertexID);
          vertexRef.next = vertexList.size() - 1;
          prevVertexID = vertexList.size() - 1;
          
        }
        
      } else {        // start edge creation
        vertices.add(new PVector(mouseX, mouseY));
        println("new vertex = (" + mouseX + ", " + mouseY + ") : #" + vertices.size());
        currentEdge = new edge(mouseX, mouseY, mouseX, mouseY);
        
        
        vertexList.add(new Vertex(mouseX, mouseY, -1, -1));
        prevVertexID = 0;
      }
    } else {                    // first edge already created
      if (currentEdge != null) {  // edge currently being created
      
        foundCloseVertex = false;
        for (int i = 0; i < vertices.size(); i++){
          if(insideEllipseAtVertex((PVector)vertices.get(i), mouseX, mouseY)){
            foundCloseVertex = true;
            if (!edgeExists(prevVertexID, i)){
              currentEdge.setPoint2(((PVector)vertices.get(i)).x, ((PVector)vertices.get(i)).y);
              edges.add(currentEdge);
              edgePolygonList.add(new edgePolygon(prevVertexID, i));
              vertexRef = (Vertex)vertexList.get(prevVertexID);
              vertexRef.next = i;
            }
            
            currentEdge = new edge(((PVector)vertices.get(i)).x, ((PVector)vertices.get(i)).y, ((PVector)vertices.get(i)).x, ((PVector)vertices.get(i)).y);
            prevVertexID = i;
            break;
          }
        }
        
        if(!foundCloseVertex){
          vertices.add(new PVector(mouseX, mouseY));
          println("new vertex = (" + mouseX + ", " + mouseY + ") : #" + vertices.size());
          edges.add(currentEdge);
          currentEdge = new edge(mouseX, mouseY, mouseX, mouseY);
          
          vertexList.add(new Vertex(mouseX, mouseY, prevVertexID, -1));
          edgePolygonList.add(new edgePolygon(prevVertexID, vertexList.size() - 1));
          vertexRef = (Vertex)vertexList.get(prevVertexID);
          vertexRef.next = vertexList.size() - 1;
          prevVertexID = vertexList.size() - 1;
          
        } 
      }
    }
  }
  foundCloseVertex = false;
}

public PVector GetIntersection(edge prevEdge, edge nextEdge) {
  float m1 = prevEdge.GetSlope();
  float m2 = nextEdge.GetSlope();
  
  float b1 = prevEdge.GetIntercept();
  float b2 = nextEdge.GetIntercept();
  
  float x = (b2 - b1)/(m1 - m2);
  float y = m1*x + b1;
  
  return new PVector(x,y);
}


