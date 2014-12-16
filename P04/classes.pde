
public class Corner {
  public PVector v;
  public float x1;
  public float y1;
  public int next;
  public int prev;
  public int swing;
  public int adjVertexID1;
  public int adjVertexID2;
  
  public Corner(float x, float y, int vertexID1, int vertexID2 ){
    v = new PVector(x,y);
    x1 = x;
    y1 = y;
    next = -1;
    prev = -1;
    swing = -1;
    adjVertexID1 = vertexID1;
    adjVertexID2 = vertexID2;
  }
}
public class Vertex {
 
 public PVector v;
  
 public float x1;
 public float y1;
 
 public int next;
 public int previous;
 
 public ArrayList neighbors;
 public ArrayList corners;
 
 public ArrayList neighborSwingOrder;
 
 public Vertex(float x, float y, int p, int n){
   
   v = new PVector(x,y);
   x1 = x;
   y1 = y;
   previous = p;
   next = n;
   
   neighbors = new ArrayList();
   corners = new ArrayList();
   neighborSwingOrder = new ArrayList();
 }
}
public class pt{
  int x, y, z;
}
public class edgePolygon{
  public int startVertexID;
  public int endVertexID;
  
  public edgePolygon(int start, int end){
    startVertexID = start;
    endVertexID = end;
  }
}
public class pts{
  int maxnv=16000;
  pt[] G = new pt[maxnv];
  int[] N = new int[maxnv];
  int nc=0;
  
  pts declare(){for (int i=0; i<maxnv;i++)G[i]=P(); return this;}
  
  pts addCorner(){
    return this;
  }
  
}

pt P(){
  return new pt();
}
