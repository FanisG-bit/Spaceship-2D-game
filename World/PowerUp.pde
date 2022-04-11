public class PowerUp {
  
  PVector location;
  PImage sprite;
  PVector spriteSize;
  boolean isConsumed;
  PowerUpType powerUpType;
  // Variables regarding lightning power
  int lightningPowerTimer = 0;
  boolean isLightningPowerUpActive = false;
  // Variables regarding shield power
  int shieldPowerTimer = 0;
  PImage shieldSprite;
  // Variables regarding explosive power
  int explosivePowerTimer = 0;
  boolean isExplosivePowerUpActive;
  
  public PowerUp() {
    location = new PVector();
  }
  
  void spawnPowerUp(Enemy enemyWhoSpawnsThis) {
    switch((int)random(0, 4)) {
      case 0:
         sprite = loadImage("powerupGreen_star.png");
         powerUpType = PowerUpType.HEALTH;
      break;
      case 1:
         sprite = loadImage("bolt_gold.png");
         powerUpType = PowerUpType.BOLT_GOLD;
      break;
      case 2:
         sprite = loadImage("shield_gold.png");
         powerUpType = PowerUpType.SHIELD_GOLD;
         shieldSprite = loadImage("shield1.png");
      break;
      case 3:
       sprite = loadImage("shield_silver.png");
       powerUpType = PowerUpType.SHIELD_SILVER;
      break;
    }
    spriteSize = new PVector(20, 20);
    isConsumed = false;
    location.x = enemyWhoSpawnsThis.location.x;
    location.y = enemyWhoSpawnsThis.location.y;
  }
  
  void display() {
    imageMode(CENTER);
    image(sprite, location.x, location.y, spriteSize.x, spriteSize.y);
  }
  
  void step() {
    // Uncomment to see "collider" of thunder power.
    /* 
    rectMode(CENTER);
    noFill();
    stroke(#FFFFFF);
    rect(player.location.x, player.location.y-290, lightningWidth, lightningHeight);
    */
    if(isLightningPowerActive() && powerUpType == PowerUpType.BOLT_GOLD) {
      lightningAnim.display(player.location.x, player.location.y-290, false);
      lightningCollidingWithEnemies();
      lightningPowerUp = this;
    }
    // Uncomment to see "collider" of shield power.
    /*
    rectMode(CENTER);
    noFill();
    stroke(#FFFFFF);
    rect(player.location.x, player.location.y, 150, 150);
    */
    if((isShieldPowerActive()) && powerUpType == PowerUpType.SHIELD_GOLD) {
      imageMode(CENTER);
      image(shieldSprite, player.location.x, player.location.y, shieldSize, shieldSize);
      shieldDeflectEnemyProjectiles();
    }
    if((isExplosivePowerActive()) && powerUpType == PowerUpType.SHIELD_SILVER) {
      imageMode(CENTER);
      //image(shieldSprite, player.location.x, player.location.y, shieldSize, shieldSize);
      explosivePowerUp = this;
    }
  }
  
  boolean isExplosivePowerActive() {
     if(frameCount % 60 == 0 && explosivePowerTimer > 0) {
      explosivePowerTimer--;
      isExplosivePowerUpActive = true; 
    }
    if(explosivePowerTimer == 0) {
      isExplosivePowerUpActive = false;
      return false;
    }
    return true;
  }
  
  boolean isLightningPowerActive() {
    if(frameCount % 60 == 0 && lightningPowerTimer > 0) {
      lightningPowerTimer--;
      isLightningPowerUpActive = true;
    }
    if(lightningPowerTimer == 0) {
      isLightningPowerUpActive = false;
      return false;
    }
    return true;
  }
  
  void lightningCollidingWithEnemies() {
    for(Path path : paths) {
      for(Enemy e : path.followers) {
        if(e.location.x < (player.location.x + lightningWidth/2)
           && e.location.x > (player.location.x - lightningWidth/2)
           && e.location.y > (player.location.y - lightningHeight)
           && e.location.y < (player.location.y)) {
          e.health--;
          player.score += 5;
        }
      }
    }
  }
  
  boolean isShieldPowerActive() {
    if(frameCount % 60 == 0 && shieldPowerTimer > 0) {
      shieldPowerTimer--;
    }
    if(shieldPowerTimer == 0) {
      return false;
    }
    return true;
  }
  
  void shieldDeflectEnemyProjectiles() {
    for(EnemyProjectile ep : enemyProjectiles) {
      if(ep.location.x > player.location.x - shieldSize/2 
         && ep.location.x < player.location.x + shieldSize/2
         && ep.location.y > player.location.y - shieldSize/2 - ep.spriteSize.y
         && ep.location.y < player.location.y + shieldSize/2) {
        ep.isActive = false;
      }
    }
  }
  
  void triggerPowerUp() {
    switch(powerUpType) {
      case HEALTH:
        // If for example 3 is the number of player lives, then we want have that as the MAX (no more).
        if(player.health < player.NUMBER_OF_LIVES) {
          player.health++;
        }
      break;
      case BOLT_GOLD:
        lightningPowerTimer = 3;
      break;
      case SHIELD_GOLD:
        shieldPowerTimer = 6;
      break;
      case SHIELD_SILVER:
        explosivePowerTimer = 5;
      break;
    }
  }
  
}
