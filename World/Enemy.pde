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
  /*
    Variable below helps us for the shooting timer of bosses. This is implemented in the same way as the 
    the one for the player when shooting. See World class.
  */
  int shootingEnemyTimer = millis();
  // This number is the one responsible for creating the rate of fire (/shooting).
  int shootingRate;
  int bossNumber;
  // in regards to boss 3
  int boss3AnimTimer;
  boolean shouldDisplayOpenAnim = false;
  boolean shouldStartRotating = false;
  float angle;
  boolean isActive = false;
  
  public Enemy(){}
  
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
    if(this instanceof Boss) {
      if(bossNumber == 2 && health <= 20) {
        maxSpeed = 13;
      }
      if(bossNumber == 3 && health <= 25) {
        maxSpeed = 20;
        Boss b = ((Boss)this);
        if(!shouldStartRotating) {
          b.setPathToFollow(1);
        } else {
          b.setPathToFollow(2);
          shouldStart = true;
        }
        if(shouldDisplayOpenAnim) {
          displayBoss3OpenAnimation();
        } else {
          spriteSize.x = 125;
        }
      }
    }
  }
  
  void display() {
    if(this instanceof Boss && shouldStartRotating) {
      angle += 0.3;
      pushMatrix();
      translate(location.x, location.y);
      rotate(angle);
      imageMode(CENTER);
      image(sprite, 0, 0, spriteSize.x, spriteSize.y);
      popMatrix();
    } else {
      imageMode(CENTER);
      image(sprite, location.x, location.y, spriteSize.x, spriteSize.y);
    }
  }
  
  boolean shouldStart = false;
  void followPath() {
      if(shouldStart) {
        // While the enemy is following the path, can shoot either after 1 or 2 seconds.
        // Applies for typical, non boss enemies.
        if(!(this instanceof Boss)) {
          countdownToShoot = (int)random(1, 3);
        }
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
          
          
          // This is specifically for the boss 3, transitioning from phase 1 to 2
          // Phase 2 only has 1 path, so that explains the third condition
          if(this instanceof Boss && bossNumber == 3 && path.waypoints.size() == 1) {
            shootingRate = 100000000;
            shouldStart = true;
            currentPoint = 0;
            if(dist(this.location.x, this.location.y,
                    path.waypoints.get(this.currentPoint).x, path.waypoints.get(this.currentPoint).y)
                    < this.spriteSize.x/2 + path.waypointSize/2) {
              shouldStart = false;
              shouldDisplayOpenAnim = true;
              boss3AnimTimer = 2;
            }
          }
          /* In the case that the enemy is a boss, we are not altering the path in the same way as in typical enemies
           So, we are restarting it.
           The second statement is specifically for boss 3 and is related to the transition from phase 1 to 2.
           */
          if(this instanceof Boss && path.waypoints.size() != 1) {
            currentPoint = 0;
            shouldStart = true;
          }
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
    if(!(this instanceof Boss)) {
      if(frameCount % 60 == 0 && countdownToShoot > 0) {
        countdownToShoot--;
      }
      if(countdownToShoot == 0) {
        typicalEnemyShootingSound.play();
        enemyProjectiles.add(new EnemyProjectile(15, 8, 48, this));
        countdownToShoot = (int)random(1, 3);
      }
    } else {
      if(millis() > shootingEnemyTimer + shootingRate) {
        if(bossNumber == 1) {
          boss1Projectile.loop();
          EnemyProjectile ep = new EnemyProjectile(15, 8, 48, this);
          enemyProjectiles.add(ep);
        }
        if(bossNumber == 2) {
          EnemyProjectile ep = new EnemyProjectile(15, 25, 48, this);
          ep.sprite = loadImage("boss2projectile.png");
          enemyProjectiles.add(ep);
        }
        if(bossNumber == 3 && !shouldStartRotating) {
          EnemyProjectile ep = new EnemyProjectile(6, 25, 25, this);
          ep.sprite = loadImage("boss3projectile.png");
          enemyProjectiles.add(ep);
        }
        if(bossNumber == 3 && shouldStartRotating) {
          EnemyProjectile ep = null;
          if(player.location.y > location.y) {
            ep = new EnemyProjectile(15, 8, 48, this);
          } else if(player.location.y < location.y) {
            ep = new EnemyProjectile(-15, 8, 48, this);
          }
          ep.sprite = loadImage("boss3proj2.png");
          enemyProjectiles.add(ep);
        }
        shootingEnemyTimer = millis();
      }
    }
  }
  
  void displayBoss3OpenAnimation() {
    if(frameCount % 30 == 0 && boss3AnimTimer > 0){
      boss3AnimTimer--;
    }
    if(boss3AnimTimer != 0) {
      boss3open.display(location.x, location.y, false);
      spriteSize.x = 0;
    } else {
      shouldDisplayOpenAnim = false;
      sprite = loadImage("boss3_open/open_42_delay-0.22s.gif");
      shouldStartRotating = true;
      shootingRate = 200;
    }
  }
  
}
