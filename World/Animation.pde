class Animation {
  
  PImage[] images;
  int imageCount;
  int frame = 0;

  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];
    switch(imagePrefix) {
      case "tile":
        String folder = dataPath("lightning");
        for (int i = 0; i < imageCount; i++) {
          String filename = imagePrefix + i + ".png";
          images[i] = loadImage(folder + "\\" + filename);
          imageMode(CENTER);
          images[i].resize(lightningWidth, lightningHeight);
       }
      break;
      case "frame_":
        String folder1 = dataPath("explosion");
        for (int i = 0; i < imageCount; i++) {
          String filename = imagePrefix + i + "_delay-0.02s.gif";
          images[i] = loadImage(folder1 + "\\" + filename);
          imageMode(CENTER);
          images[i].resize(explosionWidth, explosionHeight);
       }
      break;
      case "open_":
        String folder2 = dataPath("boss3_open");
        for (int i = 0; i < imageCount; i++) {
          String filename = imagePrefix + i + "_delay-0.22s.gif";
          images[i] = loadImage(folder2 + "\\" + filename);
          imageMode(CENTER);
          images[i].resize(boss3AnimSize, boss3AnimSize);
       }
      break;
      case "close_":
        String folder3 = dataPath("boss3_close");
        for (int i = 0; i < imageCount; i++) {
          String filename = imagePrefix + i + "_delay-0.2s.gif";
          images[i] = loadImage(folder3 + "\\" + filename);
          imageMode(CENTER);
          images[i].resize(boss3AnimSize, boss3AnimSize);
       }
      break;
    }
  }

  void display(float xpos, float ypos, boolean flip) {
    if(!flip){
      frame = (frame+1) % imageCount;
      image(images[frame], xpos, ypos);
    }
    else{
      pushMatrix();
      scale(-1, 1);
      image( images[frame], 0, 0 );
      frame = (frame+1) % imageCount;
      image(images[frame], xpos, ypos);
      popMatrix();
    }
  }
}
