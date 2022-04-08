public class Background {
  
  PImage image;
  PVector location;
  PVector velocity;
  boolean isBackgroundOnBottom;
  PVector imageSize;
  
  public Background() {
    image = loadImage("Space-Background.png");
    /* The +10 on the second argument is a magic number. Basically for this specific width 
       and height for some reason there was a very small but noticable gap between the two 
       background images (that makes us the seemingly one scrolling background). This + 10
       fixes the gap.
    */
    // imageSize = new PVector(width, height+10);
    imageSize = new PVector(width, height);
    location = new PVector();
    velocity = new PVector(0, 4);
    isBackgroundOnBottom = false;
  }
  
  void step() {
    location.add(velocity);
    isBackgroundOnBottom = isBackgroundOnBottom();
    if(isBackgroundOnBottom) {
      location.y = -(imageSize.y/2);
    }
  }
  
  void display() {
    imageMode(CENTER);
    image(image, location.x, location.y, imageSize.x, imageSize.y);
  }
  
  private boolean isBackgroundOnBottom() {
    if(location.y >= height + (imageSize.y/2)) {
      return true;
    } else {
      return false;
    }
  }
  
}
