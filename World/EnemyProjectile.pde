import java.util.*;
public class EnemyProjectile {
  
  PVector location;
  PVector velocity;
  final int MAX_SPEED;
  PImage sprite;
  PVector spriteSize;
  Enemy enemy;
  boolean isActive;
  
  public EnemyProjectile(int speed, int size, Enemy enemy) {
    sprite = loadImage("laserRed13.png");
    MAX_SPEED = speed;
    this.enemy = enemy;
    location = new PVector(enemy.location.x, enemy.location.y);
    velocity = new PVector(0, speed);
    spriteSize = new PVector(size, size);
    isActive = true;
  }
  
  void step() {
    location.add(velocity);
    collideWithPlayer();
  }
  
  void display() {
    imageMode(CENTER);
    image(sprite, location.x, location.y);
  }
  
  void collideWithPlayer() {
    if(dist(this.location.x, this.location.y, player.location.x, player.location.y) 
                < this.spriteSize.x/2 + player.spriteSize.x/2) {
       player.health--;
       isActive = false;
    }
  }
  
}
