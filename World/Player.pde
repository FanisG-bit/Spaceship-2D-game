public class Player {
  
  PVector location;
  PVector velocity;
  final int MAX_SPEED;
  PImage sprite;
  PVector spriteSize;
  
  public Player(int size, int speed) {
    sprite = loadImage("playerShip1_blue.png");
    spriteSize = new PVector(size, size);
    location = new PVector(width/2, height/2);
    velocity = new PVector();
    MAX_SPEED = speed;
  }
  
  void step() {
    location.add(velocity);
    constrainPlayer();
  }
  
  void display() {
    imageMode(CENTER);
    image(sprite, location.x, location.y, spriteSize.x, spriteSize.y);
  }
  
  void moveUp() {
    velocity.y -= MAX_SPEED;
    velocity.y = -constrain(velocity.y, MAX_SPEED, MAX_SPEED);
  }
  
  void moveDown() {
    velocity.y += MAX_SPEED;
    velocity.y = constrain(velocity.y, MAX_SPEED, MAX_SPEED);
  }
  
  void moveLeft() {
    velocity.x -= MAX_SPEED;
    velocity.x = -constrain(velocity.y, MAX_SPEED, MAX_SPEED);
  }
  
  void moveRight() {
    velocity.x += MAX_SPEED;
    velocity.x = constrain(velocity.y, MAX_SPEED, MAX_SPEED);
  }
  
  void stop() {
    velocity.y = 0;
    velocity.x = 0;
  }
  
  void constrainPlayer() {
    location.x = constrain(location.x, spriteSize.x/2, width - spriteSize.x/2);
    location.y = constrain(location.y, spriteSize.y/2, height - spriteSize.y/2);
  }
  
}
