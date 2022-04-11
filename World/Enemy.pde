import java.util.*;
public class Enemy {
  
  PVector location;
  PVector velocity;
  int maxSpeed;
  PImage sprite;
  PVector spriteSize;
  // where the enemy is positioned in relation to the waypoints of the
  // path that is being followed.
  int currentPoint;
  // The path that is being followed by this enemy.
  Path path;
  int counter;
  int health;
  int countdownToShoot;
  
  public Enemy(int speed, int size, int health) {
    maxSpeed = speed;
    sprite = loadImage(getRandomSprite());
    spriteSize = new PVector(size, size);
    velocity = new PVector();
    currentPoint = 0;
    this.health = health;
    // countdownToShoot = (int)random(1, 3);
  }
  
  String getRandomSprite() {
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
    return "enemy" + enemyColor + enemyTypeChoice + ".png";
  }
  
  void setRandomSprite() {
    sprite = loadImage(getRandomSprite());
  }
  
  void setStartingLocation(PVector startingLocation) {
    location = startingLocation;
  }
  
  void step() {
    location.add(velocity);
    followPath();
    shoot();
  }
  
  void display() {
    imageMode(CENTER);
    image(sprite, location.x, location.y, spriteSize.x, spriteSize.y);
  }
  
  boolean shouldStart = false;
  void followPath() {
      if(shouldStart) {
        // While the enemy is following the path, can shoot either after 1 or 2 seconds.
        countdownToShoot = (int)random(1, 3);
        if(this.currentPoint != path.waypoints.size()) {
          if(this.location.x != path.waypoints.get(this.currentPoint).x 
             && this.location.y != path.waypoints.get(this.currentPoint).y) {
            seek(new PVector(path.waypoints.get(this.currentPoint).x, path.waypoints.get(this.currentPoint).y)
                 ,this);
            if(dist(this.location.x, this.location.y,
                    path.waypoints.get(this.currentPoint).x, path.waypoints.get(this.currentPoint).y)
                    < this.spriteSize.x/2 + path.waypointSize/2) {
              this.currentPoint++;
            }
          } else {
            /* This else statement is extremely necessary in order to be able to set an
               enemy's location on the FIRST waypoint of a path.
            */
            this.currentPoint++;
          }
        } else {
          this.velocity.x = 0;
          this.velocity.y = 0;
          path.addFollowerWhoHasFinished();
          /* When the enemy dies (being transported to the last waypoint of the path),
             we pass a stupidly big amount of time for the purpose if it not shooting while
             off screen.
          */
          countdownToShoot = 6000;
          shouldStart = false;
        }
      }
  }
  
  void seek(PVector target, Enemy thisEnemy) {
    PVector desiredV = PVector.sub(target, thisEnemy.location);
    desiredV.normalize();
    desiredV.mult(thisEnemy.maxSpeed);
    PVector steer = PVector.sub(desiredV, thisEnemy.velocity);
    steer.limit(10);
    thisEnemy.velocity.add(steer);
  }
  
  void shoot() {
    if(frameCount % 60 == 0 && countdownToShoot > 0) {
      countdownToShoot--;
    }
    if(countdownToShoot == 0) {
      enemyProjectiles.add(new EnemyProjectile(15, 15, this));
      countdownToShoot = (int)random(1, 3);
    }
  }
  
}
