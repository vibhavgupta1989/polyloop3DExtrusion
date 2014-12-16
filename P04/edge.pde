


public class edge {
  public PVector v1, v2;
  public float x1, y1, x2, y2;
  public float drawX1, drawY1, drawX2, drawY2;
  public float midX, midY;
  public float rotation;
  public float size;
  
  public edge(float x1, float y1, float x2, float y2) {
     this.x1 = x1;
     this.y1 = y1;
     this.x2 = x2;
     this.y2 = y2;
     //seperate end point variables for drawing
     this.midX = (x1 + x2)/2;
     this.midY = (y1 + y2)/2;
     setDrawPts();
     this.rotation = getRotation();
  }
  
  public edge(float midX, float midY, float rotation) {
    //calculate endpoints from given midpoint
    this.x1 = midX - size/2*cos(rotation);
    this.y1 = midY - size/2*sin(rotation);
    this.x2 = midX + size/2*cos(rotation);
    this.y2 = midY + size/2*sin(rotation);
    this.midX = midX;
    this.midY = midY;
    setDrawPts();
    this.rotation = rotation;
  }
  
  public void setPoint1(float x1, float y1) {
    this.x1 = x1;
    this.y1 = y1;
    this.midX = getMidX();
    this.midY = getMidY();
    setDrawPts();
    this.rotation = getRotation();
  }
  
  public void setPoint2(float x2, float y2) {
    this.x2 = x2;
    this.y2 = y2;
    this.midX = getMidX();
    this.midY = getMidY();
    setDrawPts();
    this.rotation = getRotation();
  }
  
  private float getRotation() {
   rotation = atan2(y2-y1, x2-x1);
   return rotation;
  }
  
  public float getMidX() {
    return ((x2+x1)/2);
  }
  
  public float getMidY() {
    return ((y2+y1)/2);
  }
  
  public void setDrawPts(){
    //get accurate end points for drawing the colored spheres on each
    drawX1 = midX - size/2*cos(rotation);
    drawY1 = midY - size/2*sin(rotation);
    drawX2 = midX + size/2*cos(rotation);
    drawY2 = midY + size/2*sin(rotation); 
  }
  
  public float ourDot() {
    return x1*x2+y1*y2;

  }
  
  public float ourDet() {
    return x1*y2-y1*x2;

  }
  
  public float getDisplayWidth() {
    return sqrt(sq(x2-x1) + sq(y2-y1));
    
  }
  
  public float GetNormalSlope() {
    float slope = (x2-x1)/(-y2+y1);
    return slope;
  }
  
  public float GetSlope() {
    float slope = (y2 - y1)/(x2-x1);
    return slope;
  }
  
  public float GetNormalIntercept() {
    float intercept = midY - GetNormalSlope() * midX;
    return intercept;
  }
  
  public float GetIntercept() {
    float intercept = midY - GetSlope() * midX; 
    return intercept;
  }
}


