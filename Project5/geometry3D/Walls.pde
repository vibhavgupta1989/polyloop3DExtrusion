void showWalls(pts P, pts Q){
  int n=min(P.nv,Q.nv);
  for (int i=n-1, j=0; j<n; i=j++) {
    beginShape(); v(P.G[i]); v(P.G[j]); v(Q.G[j]); v(Q.G[i]); endShape(CLOSE);
    }
  }
  
void showWallsExtrusion(pts P){
    for(int i=0;i<P.nc;i++){
      if(P.cN[i] != -1){
        beginShape(); 
        v(P.cG[i]);
        v(P.cG[P.cN[i]]);
        v(P.cGExtrusion[P.cN[i]]);
        v(P.cGExtrusion[i]);      
        endShape(CLOSE);
      }
    }
}
