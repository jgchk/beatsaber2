class block {
 PVector center;
 float ts;
 float w;
 float h;
 float d;
 color fill;
 color stroke;
 boolean destroy;
 boolean delete = false;
 int divLevel = 0;
 float alpha = 100;
 int count = 0;
 block(float ts, float x, float y, float z, float w, float h, float d) {
   center = new PVector(x, y, z);
   this.ts = ts;
   this.w = w;
   this.h = h;
   this.d = d;
   this.fill = blockFill;
   this.stroke = blockStroke;
   this.destroy = false;
 }
  block(float ts, float x, float y, float z, float w, float h, float d, color fill, color stroke) {
   center = new PVector(x, y, z);
   this.ts = ts;
   this.w = w;
   this.h = h;
   this.d = d;
   this.fill = fill;
   this.stroke = stroke;
   this.destroy = false;
 }
 
 void update() {
   float t = map(ts, 0, music.length(), 0, 1);
   float pos = map(music.position(), 0, music.length(), 0, 1);
   float z = -mapSize * (t - pos);
   //float pos = ts - music.position();
   //float z = map(pos, 0, music.length(), 0, mapSize);
   this.center.z = z;
   if (this.center.z > 135 && !this.destroy) {
     this.fill = #FA2356;
     this.stroke = #FA2356;
     miss.play();
   }
   if (this.destroy) {
     if (this.count % 3 == 0) {
       alpha -= 30;
       divLevel++;
       if (divLevel > 3) {
         this.delete = true;
       }
     }
     count++;
     
   }
 }
 void display() {
   fill(this.fill, alpha);
   stroke(this.stroke, alpha);
   if (!this.destroy) {
     pushMatrix();
     translate(center.x, center.y, center.z);
     box(this.w, this.h, this.d);
     popMatrix();
   } else {
     drawRecursiveBoxes(center.x, center.y, center.z, w, h, d, (divLevel));
   }
 }
 
 void drawRecursiveBoxes(float cx, float cy, float cz, float rw, float rh, float rd, int level) {
   if (level == 0) {
     pushMatrix();
     translate(cx, cy, cz);
     box(rw, rh, rd);
     popMatrix();
     return;
   } 
   drawRecursiveBoxes(cx - rh/2, cy - rw/2, cz - rd/2, rw/3, rh/3, rd/3, level-1);
   drawRecursiveBoxes(cx + rh/2, cy - rw/2, cz - rd/2, rw/3, rh/3, rd/3, level-1);
   drawRecursiveBoxes(cx - rh/2, cy + rw/2, cz - rd/2, rw/3, rh/3, rd/3, level-1);
   drawRecursiveBoxes(cx + rh/2, cy + rw/2, cz - rd/2, rw/3, rh/3, rd/3, level-1);
   drawRecursiveBoxes(cx - rh/2, cy - rw/2, cz + rd/2, rw/3, rh/3, rd/3, level-1);
   drawRecursiveBoxes(cx + rh/2, cy - rw/2, cz + rd/2, rw/3, rh/3, rd/3, level-1);
   drawRecursiveBoxes(cx - rh/2, cy + rw/2, cz + rd/2, rw/3, rh/3, rd/3, level-1);
   drawRecursiveBoxes(cx + rh/2, cy + rw/2, cz + rd/2, rw/3, rh/3, rd/3, level-1);
 }
  
  
}
