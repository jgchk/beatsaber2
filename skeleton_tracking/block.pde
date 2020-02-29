class block {
 float x;
 float y;
 float z;
 float w;
 float h;
 float d;
 color fill;
 color stroke;
 block(float x, float y, float z, float w, float h, float d) {
   this.x = x;
   this.y = y;
   this.z = z;
   this.w = w;
   this.h = h;
   this.d = d;
   this.fill = blockFill;
   this.stroke = blockStroke;
 }
  block(float x, float y, float z, float w, float h, float d, color fill, color stroke) {
   this.x = x;
   this.y = y;
   this.z = z;
   this.w = w;
   this.h = h;
   this.d = d;
   this.fill = fill;
   this.stroke = stroke;
 }
 
 void update() {
   this.z += 10;
 }
 void display() {
   pushMatrix();
   translate(this.x, this.y, this.z);
   box(this.w, this.h, this.d);
   popMatrix();
 }
  
  
}