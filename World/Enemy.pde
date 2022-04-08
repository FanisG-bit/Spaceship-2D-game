import java.util.*;
public class Enemy {
  
  PVector location;
  PVector velocity;
  final int MAX_SPEED;
  PImage sprite;
  PVector spriteSize;
  // where the enemy is positioned in relation to the waypoints of the
  // path that is being followed.
  int currentPoint;
  Path path;
  int counter;
  
  public Enemy(int speed, int size) {
    MAX_SPEED = speed;
    Random random = new Random();
    int enemyColorChoice = 1 + random.nextInt(4);
    String enemyColor = "";
    switch(enemyColorChoice){
      case 1:
        enemyColor += "Black";
      break;
      case 2:
        enemyColor += "Blue";
      break;
      case 3:
        enemyColor += "Green";
      break;
      case 4:
        enemyColor += "Red";
      break;
    }
    int enemyTypeChoice = 1 + random.nextInt(5);
    String enemyImageName = "enemy" + enemyColor + enemyTypeChoice + ".png";
    sprite = loadImage(enemyImageName);
    spriteSize = new PVector(size, size);
    location = new PVector(-5, -5);
    velocity = new PVector();
    currentPoint = 0;
  }
  
  void step() {
    location.add(velocity);
    followPath();
  }
  
  void display() {
    imageMode(CENTER);
    image(sprite, location.x, location.y, spriteSize.x, spriteSize.y);
  }
  
  boolean shouldStart = false;
  void followPath() {
      if(shouldStart) {
        if(this.currentPoint != path.waypoints.size()) {
          if(this.location.x != path.waypoints.get(this.currentPoint).x 
             && this.location.y != path.waypoints.get(this.currentPoint).y
             && path.waypointsStatus.get(this.currentPoint) == false) {
            seek(new PVector(path.waypoints.get(this.currentPoint).x, path.waypoints.get(this.currentPoint).y)
            , this);
            if(dist(this.location.x, this.location.y,
                    path.waypoints.get(this.currentPoint).x, path.waypoints.get(this.currentPoint).y)
                    < this.spriteSize.x/2 + path.waypointSize/2) {
              path.waypointsStatus.set(this.currentPoint, false);
              this.currentPoint++;
            }
          }
        } else {
          this.velocity.x = 0;
          this.velocity.y = 0;
        }
      }
  }
  
  void seek(PVector target, Enemy thisEnemy) {
    PVector desiredV = PVector.sub(target, thisEnemy.location);
    desiredV.normalize();
    desiredV.mult(thisEnemy.MAX_SPEED);
    PVector steer = PVector.sub(desiredV, thisEnemy.velocity);
    steer.limit(10);
    thisEnemy.velocity.add(steer);
  }
  
}
