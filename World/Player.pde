public class Player {
  
  PVector location;
  PVector velocity;
  final int MAX_SPEED;
  PImage sprite;
  PVector spriteSize;
  int health;
  /* We need to store the health that the player has in a static variable,
     cause the other health variable is changing. */
  final int NUMBER_OF_LIVES;
  int score;
  
  public Player(int size, int speed, int health) {
    sprite = loadImage("playerShip1_blue.png");
    spriteSize = new PVector(size, size);
    location = new PVector(width/2, height/2);
    velocity = new PVector();
    MAX_SPEED = speed;
    this.health = health;
    NUMBER_OF_LIVES = health;
    score = 0;
  }
  
  void step() {
    location.add(velocity);
    constrainPlayer();
    if(areTypicalEnemiesActive) {
      collidingWithEnemy();
    }
    collidingWithPowerUp();
    collidingWithBosses();
  }
  
  void display() {
    imageMode(CENTER);
    image(sprite, location.x, location.y, spriteSize.x, spriteSize.y);
  }
  
  void collidingWithEnemy() {
    for(Path path : paths) {
      for(Enemy e : path.followers) {
        if(dist(this.location.x, this.location.y, e.location.x, e.location.y) 
                < this.spriteSize.x/2 + e.spriteSize.x/2) {
          health--;
          /* The easier way that I can think for dealing with this colliding issue
          (player's health is all decreased) which is something that is caused due to
          the player colliding with the enemy, is to destroy the enemy. I believe that this
          does not cause any balancing issue since the player is getting hit, so there is
          a penalty for doing that. So it cannot be exploited by the player's 
          kamikaze attitude.
          */
          e.health--;
        }
      }
    }
  }
  
  void collidingWithPowerUp() {
    for(PowerUp pwr : powerUps) {
      if(!pwr.isConsumed && dist(this.location.x, this.location.y, pwr.location.x, pwr.location.y) 
           < this.spriteSize.x/2 + pwr.spriteSize.x/2) {
        if(!isGameInTypingState) {
          isGameInTypingState = true;
          typingStateCounter = typingStateCounterStatic;
          powerUpToTrigger = pwr;
        }
      }
    }
  }
  
  void collidingWithBosses() {
    for(Boss b : bosses) {
      if(b.location != null) {
      if(dist(this.location.x, this.location.y, b.location.x, b.location.y) 
                < this.spriteSize.x/2 + b.spriteSize.x/2)  {
        health--;
      }
      }
    }
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
