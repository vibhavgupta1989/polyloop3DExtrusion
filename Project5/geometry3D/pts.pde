import java.nio.*;
int pp=1; // index of picked vertex
pts P = new pts(); // polyloop in 3D
pts Q = new pts(); // second polyloop in 3D

pts PtQ = new pts(); // inbetweening polyloop L(P,t,Q);
class pts { // class for manipulaitng and sisplaying polyloops
 Boolean loop=true;
 int pv =0, // picked vertex index,
     iv=0, //  insertion vertex index
     nv = 0,  // number of vertices currently used in P
     nc = 0, // total number of corners in P
     ne = 0,
     ncExtrusion = 0,
     ncQuad = 0,
     prevCorner = -1,
     startCorner = 0,
     curCornerID = -1, // Used for printing balls of the
     curCornerGID = -1;      // current corner
     
 int maxnv = 16000;                 //  max number of vertices
 pt[] G = new pt [maxnv];           // geometry table (vertices)
 //int numSideWalks;
 //int[] numSideWalkCorners = new int[maxnv];
 pt[] cG= new pt [maxnv];           // geometry table (corners)
 int[] cN = new int[maxnv];         // next table (corners)
 int [] cV = new int[maxnv];        // vertex table (corners)
 int [] cS = new int[maxnv];        // swing table (corners)
 int [] sideWalkStarts = new int[maxnv];
 int numSideWalks=0;
 boolean[] sideWalksDone = new boolean[maxnv];
 boolean[] verticesBridged = new boolean[maxnv];
 int [] marked = new int[maxnv];
 
 pt[] cGExtrusion = new pt [maxnv]; // geometry table (extrusion)
 int[] cVExtrusion = new int [maxnv]; // vertex table (extrusion)
 int[] cPExtrusion = new int [maxnv]; // previous table (extrusion)
 int[] cSExtrusion = new int [maxnv]; // swing table (extrusion)
 pt[] cGQuad = new pt[maxnv];       // geometry table (quads)
 int[] cQuadSwingIn = new int[maxnv]; //for quad corner swing is in which of cG (0), cGExtrusion(1) or cGQuad(2)
 int[] cSwingIn = new int[maxnv];
 int[] cExtrusionSwingIn = new int[maxnv];
 int[] cVQuad = new int[maxnv];     // vertex table (corners at quads)
 int[] cSQuad = new int[maxnv];     // swing table for corners at quads
 int[] cNQuad = new int[maxnv];     // next table for corners at quads
 int [] Estart = new int[maxnv];
 int [] Eend = new int[maxnv];
 
  pts() {}
  void resetPrevCorner(){prevCorner = -1; startCorner=nc;}
  pts declare() {for (int i=0; i<maxnv; i++)verticesBridged[i]=false;for (int i=0; i<maxnv; i++)sideWalksDone[i]=false;for (int i=0; i<maxnv; i++)cExtrusionSwingIn[i]=-1;for (int i=0; i<maxnv; i++)cSwingIn[i]=-1;for (int i=0; i<maxnv; i++)Estart[i]=-1; for (int i=0; i<maxnv; i++)sideWalkStarts[i]=-1;for (int i=0; i<maxnv; i++)marked[i]=0;for (int i=0; i<maxnv; i++)Eend[i]=-1; for (int i=0; i<maxnv; i++) cNQuad[i]=-1;for (int i=0; i<maxnv; i++) cSQuad[i]=-1;for (int i=0; i<maxnv; i++) cQuadSwingIn[i]=0;for (int i=0; i<maxnv; i++) G[i]=P(); for (int i = 0; i<maxnv;i++) cG[i]=P();for (int i = 0; i<maxnv;i++) cGExtrusion[i]=P();for (int i = 0; i<maxnv;i++) cVExtrusion[i]=-1;for (int i = 0; i<maxnv;i++) cPExtrusion[i]=-1;for (int i = 0; i<maxnv;i++) cSExtrusion[i]=-1;for (int i = 0; i<maxnv;i++) cGQuad[i]=P();for (int i = 0; i<maxnv;i++) cVQuad[i]=-1;for (int i = 0; i<maxnv;i++)cN[i]=-1; for (int i = 0; i<maxnv;i++)cV[i]=-1;for(int i = 0; i<maxnv;i++)cS[i]=-1;return this;}     // init all point objects
  pts empty() {nv=0; pv=0; return this;} // resets P so that we can start adding points
  pts addPt(pt P) { G[nv].setTo(P); pv=nv; nv++;  return this;} // adds a point at the end
  pts addPt(float x,float y) { G[nv].x=x; G[nv].y=y; pv=nv; nv++; return this;}
  pts addCorner(pt P){cG[nc].setTo(P); nc++; return this;}
  pts addCornerAtTop(pt P){cGExtrusion[ncExtrusion].setTo(P); ncExtrusion++; return this;}
  pts addCornerQuad(pt P){cGQuad[ncQuad].setTo(P); ncQuad++; return this;}
  pts copyFrom(pts Q) {empty(); nv=Q.nv; for (int v=0; v<nv; v++) G[v]=P(Q.G[v]); return this;}
  pts setToL(pts P, float t, pts Q) { // lerp (inear interpolation betwen P and Q
    empty(); 
    nv=min(P.nv,Q.nv); 
    for (int v=0; v<nv; v++) G[v]=L(P.G[v],t,Q.G[v]); 
    return this;}
  pts resetOnCircle(int k, float r) { // makes new polyloo[p with k  points on a circle around origin
    empty(); // resert P
    pt C = P(); // center of circle
    for (int i=0; i<k; i++) addPt(R(P(C,V(0,-r,0)),2.*PI*i/k,C)); // points on z=0 plane
    pv=0; // picked vertex ID is set to 0
    return this;
    } 
  int idOfVertexWithClosestScreenProjectionTo(pt M) { // for picking a vertex with the mouse
    pp=0; 
    for (int i=1; i<nv; i++) if (d(M,ToScreen(G[i]))<=d(M,ToScreen(G[pp]))) pp=i; 
    return pp;
    }
  pt closestProjectionOf(pt M) {   // for picking inserting O. Returns projection but also CHANGES iv !!!!
    pt C = P(G[0]); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G[i])<=d) {iv=i; C=P(G[i]); d=d(M,C); }  
    for (int i=nv-1, j=0; j<nv; i=j++) { 
       pt A = G[i], B = G[j];
       if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) {d=disToLine(M,A,B); iv=i; C=projectionOnLine(M,A,B);}
       } 
    return C;    
    }
  pts insertPt(pt P) { // inserts new vertex after vertex with ID iv
    for(int v=nv-1; v>iv; v--) G[v+1].setTo(G[v]); 
     iv++; 
     G[iv].setTo(P);
     nv++; // increments vertex count
     return this;
     }
  pts flatten() {
    float z=G[0].z;
    for (int v=1; v<nv; v++) z+=G[v].z;
    z/=nv;
    for (int v=0; v<nv; v++) G[v].z=z; 
    return this;
    }
  pts addExtrusionCorners(){
    ncExtrusion=nc;
    for(int i=0; i < nc; i++){
      
      cVExtrusion[i]=cV[i];
      cGExtrusion[i] = new pt(cG[i].x,cG[i].y,cG[i].z+extrusionZ);
      cPExtrusion[i] = cN[i];
    }
    return this;
  }
  pts insertCornerAtClosestVertex(int pp, int flag){
    int prevVertexID;
    int nextVertexID;
    
    if(pp==0)
      prevVertexID=nv-1;
    else
      prevVertexID=pp-1;
    nextVertexID=(pp+1)%nv;
    
    pt vertexToInsert = new pt(G[pp].x, G[pp].y, G[pp].z);
    pt vertexToInsertAtTop = new pt(G[pp].x, G[pp].y, G[pp].z + extrusionZ);
    
    cV[nc]=pp;
    cVExtrusion[nc]=pp;
    if (flag == 0){
      addCorner(vertexToInsert.add(V(30.0, U(A(U(V(G[pp],G[prevVertexID])),U(V(G[pp],G[nextVertexID])))))));
      addCornerAtTop(vertexToInsertAtTop.add(V(30.0, U(A(U(V(G[pp],G[prevVertexID])),U(V(G[pp],G[nextVertexID])))))));
    }
    else{
      addCorner(vertexToInsert.sub(V(30.0, U(A(U(V(G[pp],G[prevVertexID])),U(V(G[pp],G[nextVertexID])))))));
      addCornerAtTop(vertexToInsertAtTop.sub(V(30.0, U(A(U(V(G[pp],G[prevVertexID])),U(V(G[pp],G[nextVertexID])))))));
    }
    if(prevCorner!= -1){ // prevCorner means nextCorner on top
      cN[prevCorner] = nc-1;
      cN[nc - 1] = startCorner;
      cPExtrusion[prevCorner] = ncExtrusion -1;
      cPExtrusion[ncExtrusion-1]=startCorner;
    }
    prevCorner = nc - 1;
    
    
    return this;
  }
  int getPrevCorner(int gid){
    for(int i=0; i<nc;i++){
      if(cN[i]==gid){
        return i;
      }
    }
    return -1;
  }
  int firstUnMarkedInC(){
    for(int i=0;i<nc;i++){
      if(marked[i]==0)return i;
    }
    return -1;
  }
  void doBridgeEdgeStuff(){
    int m;
    int n;
    int k,l,nextk,prevk,swingk,nextl,prevl,swingl;
    int swingChange1,swingChange2;
    pt p1,p2,p3,p4;
    m = firstUnMarkedInC();
    while(m!=-1){
      println("m is " + m);
      marked[m]=1;
      sideWalkStarts[numSideWalks++]=m;
      n = cN[m];
      while(n!=m){
        println("n is " + n);
        marked[n]=1;
        n=cN[n];
      }
      m=firstUnMarkedInC();
    }
    for(int i=0; i<numSideWalks;i++){
      println("sideWalkStart " + i +" " + sideWalkStarts[i]);
    }
    boolean done = false;
    println("num of sideWalks = " + numSideWalks);
    for(int i=0;i<numSideWalks;i++){
      for(int j=i+1; j<numSideWalks;j++){
        
        if(sideWalksDone[i]==true && sideWalksDone[j]==true)continue;
        done=false;
        k=sideWalkStarts[i];
        l=sideWalkStarts[j];
        
        //println( "k="+k+",l="+l);
        println("i="+i+",j="+j);
        while(true){
          println("k="+k);
          l=sideWalkStarts[j];
          while(true){
            
            println("l="+l);
            
            if(cV[k]==cV[l] && verticesBridged[cV[k]]==false){
              
              
             nextk=cN[k];
             prevk=getPrevCorner(k);
             swingk=cS[k];
             nextl=cN[l];
             prevl=getPrevCorner(l);
             swingl=cS[l];
             swingChange1 = cSQuad[cSExtrusion[k]];
             swingChange2 = cSQuad[cSExtrusion[l]];
             p1 = P(cG[k], 2.0, A(U(V(cG[k],cG[l])), U(V(cG[k],cG[cN[k]]))));
             p2 = P(cG[k], 2.0, A(U(V(cG[k],cG[l])), U(V(cG[k],cG[prevk]))));
             p3 = P(cG[l], 2.0, A(U(V(cG[l],cG[k])), U(V(cG[l],cG[cN[l]]))));
             p4 = P(cG[l], 2.0, A(U(V(cG[l],cG[k])), U(V(cG[l],cG[prevl]))));
             
             
             cG[k].x=p1.x;cG[k].y=p1.y;cG[k].z=p1.z;
             cSwingIn[k]=0;
             cS[k]=nc;
             cGExtrusion[k].x=p1.x;cGExtrusion[k].y=p1.y;cGExtrusion[k].z=p1.z+extrusionZ;
             
             cG[nc].x=p2.x;cG[nc].y=p2.y;cG[nc].z=p2.z;
             cV[nc]=cV[k];
             cN[nc]=l;
             cSwingIn[nc]=1;
             cS[nc]=swingk;
             cGExtrusion[ncExtrusion].x=p2.x;cGExtrusion[ncExtrusion].y=p2.y;cGExtrusion[ncExtrusion].z=p2.z+extrusionZ;
             cExtrusionSwingIn[ncExtrusion]=0;
             cSExtrusion[ncExtrusion]=k;
             cVExtrusion[ncExtrusion]=cV[k];
             cPExtrusion[ncExtrusion]=l;
             cSQuad[swingChange1]=ncExtrusion;
             cN[prevk]=nc;
             cPExtrusion[prevk]=ncExtrusion;
             nc++;
             ncExtrusion++;
             
             
             cG[l].x=p3.x;cG[l].y=p3.y;cG[l].z=p3.z;
             cSwingIn[l]=0;
             cS[l]=nc;
             cGExtrusion[l].x=p3.x;cGExtrusion[l].y=p3.y;cGExtrusion[l].z=p3.z+extrusionZ;
             
             cG[nc].x=p4.x;cG[nc].y=p4.y;cG[nc].z=p4.z;
             cSwingIn[nc]=1;
             cS[nc]=swingl;
             cGExtrusion[ncExtrusion].x=p4.x;cGExtrusion[ncExtrusion].y=p4.y;cGExtrusion[ncExtrusion].z=p4.z+extrusionZ;
             cN[nc]=k;
             cV[nc]=cV[l];
             cPExtrusion[ncExtrusion]=k;
             cExtrusionSwingIn[ncExtrusion]=0;
             cSExtrusion[ncExtrusion]=l;
             cVExtrusion[ncExtrusion]=cV[l];
             cSQuad[swingChange2]=ncExtrusion;
             cN[prevl]=nc;
             cPExtrusion[prevl]=ncExtrusion;
             nc++;
             ncExtrusion++;
             
             
             done=true;
             sideWalksDone[i]=true;sideWalksDone[j]=true;
             verticesBridged[cV[k]]=true;
             break;
            }
            
            l=cN[l];
            if(l==sideWalkStarts[j])break;
          }
          if(done)break;
          k=cN[k];
          if(k==sideWalkStarts[i])break;
        }
      }
    }
  }
  pts insertCornersAtQuads(){
    for (int i=0; i<nc; i++){
      
        addCornerQuad(P(cG[i], V(10.0, U(A(U(V(cG[i],cG[getPrevCorner(i)])), U(V(cG[i], cGExtrusion[i])))))));
        cQuadSwingIn[ncQuad-1]=2;
        cVQuad[ncQuad-1]=cV[i];
        cSQuad[ncQuad-1]=ncQuad+1;
        cSwingIn[i]=1;
        cS[i]=ncQuad-1;
      
        addCornerQuad(P(cGExtrusion[i], V(10.0, U(A(U(V(cGExtrusion[i],cGExtrusion[getPrevCorner(i)])), U(V(cGExtrusion[i], cG[i])))))));
        cQuadSwingIn[ncQuad-1]=1;
        cVQuad[ncQuad-1]=cV[i];
        cNQuad[ncQuad-1]=ncQuad-2;
        cSQuad[ncQuad-1]=i;
     
        addCornerQuad(P(cG[i], V(10.0, U(A(U(V(cG[i],cG[cN[i]])), U(V(cG[i], cGExtrusion[i])))))));
        cQuadSwingIn[ncQuad-1]=0;
        cVQuad[ncQuad-1]=cV[i];
        cNQuad[ncQuad-1]=ncQuad;
        cSQuad[ncQuad-1]=i;
        addCornerQuad(P(cGExtrusion[i], V(10.0, U(A(U(V(cGExtrusion[i],cGExtrusion[cN[i]])), U(V(cGExtrusion[i], cG[i])))))));
        cQuadSwingIn[ncQuad-1]=2;
        cVQuad[ncQuad-1]=cV[i];
        cExtrusionSwingIn[i]=1;
        cSExtrusion[i]=ncQuad-1;
        cSQuad[ncQuad-1]=ncQuad-3;
     
    }
    for (int i=0; i<ncQuad;i++){
    if(cNQuad[i]==-1){
      if(cQuadSwingIn[cSQuad[i]]==0){
        cNQuad[i] = cSQuad[cS[getPrevCorner(cSQuad[cSQuad[i]])]];
      }
      else{
        cNQuad[i] = cSQuad[cSExtrusion[cPExtrusion[cSQuad[cSQuad[i]]]]];
      }
    }
  }
    return this;
  }
  int swing(int cornerIndex){
    for(int i=0;i<nc;i++){
      if(i!= cornerIndex && cV[i]==cV[cornerIndex])return i;
    }
    return -1;
  }
  pts drawBottom(){
    beginShape();
    int start=0;
    //println("printing bottom");
    while(true){
      //print(start+",");
      v(cG[start]);
      start=cN[start];
      if(start==0)break;
    }
    //println();  
    endShape();
    /*for(int i=0; i<nc;i++){
      beginShape();
      v(cG[i]);
      v(cG[cN[i]]);
      v(cG[swing(cN[i])]);
      v(cG[swing(i)]);
      endShape();
    }*/
    return this;
  }
  pts drawTop(){
    /*for(int i=0; i< ncExtrusion;i++){
      beginShape();
      v(cGExtrusion[i]);
      v(cGExtrusion[cN[i]]);
      v(cGExtrusion[swing(cN[i])]);
      v(cGExtrusion[swing(i)]);
      endShape();
    }*/
    beginShape();
    int start=0;
    while(true){
      v(cGExtrusion[start]);
      start=cPExtrusion[start];
      if(start==0)break;
    }
    endShape();
    return this;
  }
  pts insertClosestProjection(pt M) {  
    pt P = closestProjectionOf(M); // also sets iv
    insertPt(P);
    return this;
    }

  pts deletePicked() {for(int i=pv; i<nv; i++) G[i].setTo(G[i+1]); pv=max(0,pv-1); nv--;  return this;}
  pts setPt(pt P, int i) { G[i].setTo(P); return this;}
  pts showPicked() {show(G[pv],13); return this;}
  pts drawBalls(float r) {for (int v=0; v<nv; v++) show(G[v],r); return this;}
  pts drawBallsExtrusion(float r){for (int v=nc; v<2*nc; v++) show(cG[v],r); return this;}
  int getNextExtrusion(int id){
    for(int i=0;i<ncExtrusion;i++){
      if(cPExtrusion[i]==id){
        return i;
      }
    }
    return -1;
  }
  pts drawBallsCorners(float r) {
  for (int v=0; v < nc; v++) show(cG[v],r); 
  if(showExtrusion){
    for (int v=0; v < ncExtrusion; v++) show(cGExtrusion[v],r);
    for (int v=0; v < ncQuad; v++) show(cGQuad[v],r);
    if(curCornerID!=-1 && curCornerGID!=-1){
      if(curCornerGID==0){fill(red);show(cG[curCornerID],r);fill(blue);show(cG[cN[curCornerID]],r);
        fill(green);
        if(cSwingIn[curCornerID]==0){
          show(cG[cS[curCornerID]],r);
        }
        else{
          show(cGQuad[cS[curCornerID]],r);
        }
      }
      else if(curCornerGID==1){fill(red);show(cGExtrusion[curCornerID],r);fill(blue);show(cGExtrusion[getNextExtrusion(curCornerID)],r);
        fill(green);
        if(cExtrusionSwingIn[curCornerID]==0){
          show(cGExtrusion[cSExtrusion[curCornerID]],r);
        }
        else{
          show(cGQuad[cSExtrusion[curCornerID]],r);
        }
      }
          
      else{
        fill(red);show(cGQuad[curCornerID],r);fill(blue);show(cGQuad[cNQuad[curCornerID]],r);
        fill(green);
        if(cQuadSwingIn[curCornerID]==0){show(cG[cSQuad[curCornerID]],r);}
        else if(cQuadSwingIn[curCornerID]==1){show(cGExtrusion[cSQuad[curCornerID]],r);}
        else{show(cGQuad[cSQuad[curCornerID]],r);}
      }
    }
  }
  return this;
  }
  pts setCornerToNext(){
    int newCornerID;
    if(curCornerID!=-1 && curCornerGID!=-1){
      if(curCornerGID==0){newCornerID=cN[curCornerID];}
      else if(curCornerGID==1){newCornerID=getNextExtrusion(curCornerID);}
      else{newCornerID=cNQuad[curCornerID];}
      curCornerID=newCornerID;
    }
    return this;
  }
  pts setCornerToSwing(){
    int newCornerID;
    int newCornerGID;
    if(curCornerID!=-1 && curCornerGID!=-1){
      if(curCornerGID==0){
        if(cSwingIn[curCornerID]==0){
          newCornerGID=0;
        }
        else{
          newCornerGID=2;
        }
      newCornerID=cS[curCornerID];
      }
      else if(curCornerGID==1){
        if(cExtrusionSwingIn[curCornerID]==0){
          newCornerGID=1;
        }
        else{
          newCornerGID=2;
        }
        newCornerID=cSExtrusion[curCornerID];
      }
      else{
        newCornerID=cSQuad[curCornerID];
        if(cQuadSwingIn[curCornerID]==0){newCornerGID=0;}
        else if(cQuadSwingIn[curCornerID]==1){newCornerGID=1;}
        else{newCornerGID=2;}
      }
      curCornerID=newCornerID;
      curCornerGID=newCornerGID;
    }
    return this;
  }
  pts showPicked(float r) {show(G[pv],r); return this;}
  pts drawClosedCurveAsRods(float r) {for (int v=0; v<nv-1; v++) stub(G[v],V(G[v],G[v+1]),r,r/2);  stub(G[nv-1],V(G[nv-1],G[0]),r,r/2); return this;}
  pts drawCurveAsRods(float r){for(int i=0; i<ne;i++)stub(G[Estart[i]], V(G[Estart[i]], G[Eend[i]]),r,r/2); return this;}
  pts drawClosedLoop() {beginShape(); for (int v=0; v<nv; v++) v(G[v]); endShape(CLOSE); return this;}
  pts setPickedTo(int pp) {pv=pp; return this;}
  pts movePicked(vec V) { G[pv].add(V); return this;}      // moves selected point (index p) by amount mouse moved recently
  pts moveAll(vec V) {for (int i=0; i<nv; i++) G[i].add(V); for(int i=0;i<2*nc;i++) cG[i].add(V); return this;};
  pts moveExtrusion(vec V) {for (int i=nc; i<2*nc; i++) cG[i].add(V); return this;};  
  pt Picked() {return G[pv];} 

void savePts(String fn) {
  String [] inppts = new String [nv+1];
  int s=0;
  inppts[s++]=str(nv);
  for (int i=0; i<nv; i++) {inppts[s++]=str(G[i].x)+","+str(G[i].y)+","+str(G[i].z);}
  saveStrings(fn,inppts);
  };
  
void loadData(String fn) {
  println("loading: "+fn); 
  String [] ss = loadStrings(fn);
  String subpts;
  int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
  nv = int(ss[s++]); print("nv="+nv);
  for(int k=0; k<nv; k++) {int i=k+s; float [] xy = float(split(ss[s++],",")); G[k].setTo(xy[0],xy[1],xy[2]);}
  pv=0;
  
  ne = int(ss[s++]); print("ne="+ne);
  for(int k=0; k<ne;k++){int[]xy = int(split(ss[s++],",")); Estart[k]=xy[0]; Eend[k]=xy[1];}
  nc = int(ss[s++]); print("nc="+nc);
  for(int k=0; k<nc;k++){float [] xy = float(split(ss[s++],",")); cG[k].setTo(xy[0],xy[1],xy[2]); cV[k]=(int)xy[3];cN[k]=(int)xy[4];}
  
  }; 
  
/*void storeCorners(String fn){
  println("loading: "+fn);
  String [] ss = loadStrings(fn);
  String subpts;
  int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
  int ncSW = int(ss[s++]); print("ncSW="+ncSW);
  numSideWalkCorners[numSideWalks++] = ncSW;
  for(int k=0; k<ncSW; k++) {int i=k+s; float [] xy = float(split(ss[i],",")); cG[nc+k].setTo(xy[0],xy[1],xy[2]);}
  nc = nc + ncSW;
  println("nc = " + nc);
}*/
void setCornerNextPreviousSwing(){
  cN[0]=1;cN[1]=2;cN[2]=3;cN[3]=4;cN[4]=5;cN[5]=0;
  cN[6]=7;cN[7]=8;cN[8]=9;cN[9]=10;cN[10]=11;cN[11]=6;
  
  cV[0]=0;cV[1]=5;cV[2]=4;cV[3]=3;cV[4]=2;cV[5]=1;
  cV[6]=0;cV[7]=1;cV[8]=2;cV[9]=3;cV[10]=4;cV[11]=5;
  
  cS[0]=6;cS[1]=11;cS[2]=10;cS[3]=9;cS[4]=8;cS[5]=7;
  cS[6]=0;cS[7]=5;cS[8]=4;cS[9]=3;cS[10]=2;cS[11]=1;
  
}

void printGVNS(){
  
  String [] output = new String[nc+ncExtrusion+ncQuad];
  int s=0;
  println();
  for(int i =0; i < nc; i++){
    output[s++]="cG=" + cG[i].x+","+cG[i].y+","+cG[i].z+" Vertex=" + cV[i] + " Next=" + cN[i] + " Swing="+cS[i];
    println("cG=" + cG[i].x+","+cG[i].y+","+cG[i].z+" Vertex=" + cV[i] + " Next=" + cN[i] + " Swing="+cS[i] );
  }
  for(int i =0; i < ncExtrusion; i++){
    output[s++]="cGExtrusion=" + cGExtrusion[i].x+","+cGExtrusion[i].y+","+cGExtrusion[i].z+" Vertex=" + cVExtrusion[i] + " Previous=" + cPExtrusion[i] + " Swing="+cSExtrusion[i];
    println("cGExtrusion=" + cGExtrusion[i].x+","+cGExtrusion[i].y+","+cGExtrusion[i].z+" Vertex=" + cVExtrusion[i] + " Previous=" + cPExtrusion[i] + " Swing="+cSExtrusion[i]);
  }
  for(int i =0; i < ncQuad; i++){
    output[s++]="cGQuad=" + cGQuad[i].x+","+cGQuad[i].y+","+cGQuad[i].z+" Vertex=" + cVQuad[i] + " Next=" + cNQuad[i] + " Swing="+cSQuad[i];
    println("cGQuad=" + cGQuad[i].x+","+cGQuad[i].y+","+cGQuad[i].z+" Vertex=" + cVQuad[i] + " Next=" + cNQuad[i] + " Swing="+cSQuad[i] );
  }
  saveStrings("data/checkOutput", output);
}
float distance(float x1, float y1, float z1, float x2, float y2, float z2){
  return sqrt(sq(x1-x2)+sq(y1-y2)+sq(z1-z2));
}
pt pick(int mX, int mY)
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
  PMatrix3D modelViewProj;
  PMatrix3D modelViewProjInv;
  
  modelViewProj = proj; modelViewProj.apply(modelView);
  modelViewProjInv = modelViewProj.get();
  modelViewProjInv.invert();
  
  float[] viewport = {0, 0, p3d.width, p3d.height};
  
  float[] normalized = new float[4];
  normalized[0] = ((mX - viewport[0]) / viewport[2]) * 2.0f - 1.0f;
  normalized[1] = ((height - mY - viewport[1]) / viewport[3]) * 2.0f - 1.0f;
  normalized[2] = depthValue * 2.0f - 1.0f;
  normalized[3] = 1.0f;
  
  float[] unprojected = new float[4];
  
  modelViewProjInv.mult( normalized, unprojected );
  
  float[] corner = new float[4];
  float[] cornerProjected = new float[4];
  float dist;
  float minDist=99999.0f;
  int gID=0;
  int cornerID=0;
  
  
  pt P = P( unprojected[0]/unprojected[3], unprojected[1]/unprojected[3], unprojected[2]/unprojected[3] );
  println ("pick = " + P.x + ", " + P.y +", " + P.z);
  for (int i =0; i < nc; i++){
    corner[0] = cG[i].x; corner[1]=cG[i].y; corner[2]=cG[i].z; corner[3]=1.0f;
    modelViewProj.mult(corner, cornerProjected);
    dist = distance(cornerProjected[0], cornerProjected[1], cornerProjected[2], P.x, P.y, P.z);
    println("cG: "+i+ " "+cornerProjected[0]+", "+cornerProjected[1]+", "+cornerProjected[2] + ", distance="+dist);
    if(dist < minDist){gID=0;cornerID=i;minDist=dist;}
  }
  for (int i =0; i < ncExtrusion; i++){
    corner[0] = cGExtrusion[i].x; corner[1]=cGExtrusion[i].y; corner[2]=cGExtrusion[i].z; corner[3]=1.0f;
    modelViewProj.mult(corner, cornerProjected);
    dist = distance(cornerProjected[0], cornerProjected[1], cornerProjected[2], P.x, P.y, P.z);
    println("cGExtrusion: "+i+ " "+cornerProjected[0]+", "+cornerProjected[1]+", "+cornerProjected[2] + ", distance="+dist);
    if(dist<minDist){gID=1;cornerID=i;minDist=dist;}
  }
  for (int i =0; i < ncQuad; i++){
    corner[0] = cGQuad[i].x; corner[1]=cGQuad[i].y; corner[2]=cGQuad[i].z; corner[3]=1.0f;
    modelViewProj.mult(corner, cornerProjected);
    dist = distance(cornerProjected[0], cornerProjected[1], cornerProjected[2], P.x, P.y, P.z);
    println("cGQuad: "+i+ " "+cornerProjected[0]+", "+cornerProjected[1]+", "+cornerProjected[2] + ", distance="+dist);
    if(dist<minDist){gID=2;cornerID=i;minDist=dist;}
  }
  println("GID = " + gID +", cornerID = " + cornerID +", distance=" + minDist);
  curCornerGID = gID;
  curCornerID = cornerID;
  return P;
}
pts drawCornerNextSwing(pt center){
  float minDist=9999.0;
  float dist;
  int gID=-1,cornerID=-1;
  for(int i=0;i < nc;i++){
    dist=distance(center.x,center.y,center.z,cG[i].x,cG[i].y,cG[i].z);
    if(dist<minDist){minDist=dist;gID=0;cornerID=i;}
  }
  for(int i=0;i < ncExtrusion;i++){
    dist=distance(center.x,center.y,center.z,cGExtrusion[i].x,cGExtrusion[i].y,cGExtrusion[i].z);
    if(dist<minDist){minDist=dist;gID=1;cornerID=i;}
  }
  for(int i=0;i < ncQuad;i++){
    dist=distance(center.x,center.y,center.z,cGQuad[i].x,cGQuad[i].y,cGQuad[i].z);
    if(dist<minDist){minDist=dist;gID=2;cornerID=i;}
  }
  if(minDist<5){
    curCornerGID=gID;
    curCornerID=cornerID;
  }
  return this;
}


void setExtrusion(int extrusionZ){
  for(int i = 0; i < nc; i++){
    cG[nc+i].setTo(cG[i].x, cG[i].y, cG[i].z + extrusionZ);
  }
  //for (int i = 0; i < nv; i++){
  //  println("gE["+i+"]=" + gExtrusion[i].x +","+gExtrusion[i].y+","+gExtrusion[i].z);
  //}
}


} // end of pts class
