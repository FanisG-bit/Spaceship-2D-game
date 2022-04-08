import java.util.*;
public class PlayerProjectile {
  
  PVector location;
  PVector velocity;
  final int MAX_SPEED;
  PImage sprite;
  PVector spriteSize;
  Player player;
  
  public PlayerProjectile(int speed, int size, Player player) {
    sprite = loadImage("laserBlue13.png");
    MAX_SPEED = speed;
    this.player = player;
    location = new PVector(player.location.x, player.location.y);
    velocity = new PVector(0, -speed);
    spriteSize = new PVector(size, size);
  }
  
  void step() {
    location.add(velocity);
  }
  
  void display() {
    imageMode(CENTER);
    image(sprite, location.x, location.y);
  }
  
}
