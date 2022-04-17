import java.util.*;
public class PlayerProjectile {
  
  PVector location;
  PVector velocity;
  final int MAX_SPEED;
  PImage sprite;
  PVector spriteSize;
  Player player;
  boolean isActive;
  
  public PlayerProjectile(int speed, int size, Player player) {
    sprite = loadImage("laserBlue13.png");
    MAX_SPEED = speed;
    this.player = player;
    location = new PVector(player.location.x, player.location.y);
    velocity = new PVector(0, -speed);
    spriteSize = new PVector(size, size);
    isActive = true;
  }
  
  // Slightly changed for the purpose of calling this constructor from the
  // ExplosiveProjectile subclass.
  public PlayerProjectile(Player player, int speed, int size) {
    MAX_SPEED = speed;
    this.player = player;
    location = new PVector(player.location.x, player.location.y);
    velocity = new PVector(0, -speed);
    spriteSize = new PVector(size, size);
    isActive = true;
  }
  
  void step() {
    if(isActive) {
      location.add(velocity);
      if(areTypicalEnemiesActive) {
        collideWithEnemy();
      }
      collideWithBosses();
    }
  }
  
  void display() {
    if(isActive) {
      imageMode(CENTER);
      image(sprite, location.x, location.y);
    }
  }
  
  void collideWithEnemy() {
    for(Path path : paths) {
      for(Enemy e : path.followers) {
        if(dist(this.location.x, this.location.y, e.location.x, e.location.y) 
                < this.spriteSize.x/2 + e.spriteSize.x/2) {
          e.health--;
          isActive = false;
          player.score += 10;
        }
      }
    }
  }
  
  void collideWithBosses() {
    for(Boss b : bosses) {
      if(dist(this.location.x, this.location.y, b.location.x, b.location.y) 
                < this.spriteSize.x/2 + b.spriteSize.x/2)  {
        b.health--;
        isActive = false;
        if(b.isDefeated()) {
          player.score += 500;
          areTypicalEnemiesActive = true;
        }
      }
    }
  }
  
}
