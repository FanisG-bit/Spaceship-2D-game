public class ExplosiveProjectile extends PlayerProjectile {
  
  int activeTimer;
  // Location to spawn explosive.
  float locX;
  float locY;
  boolean isExplosionActive;
  
  public ExplosiveProjectile(Player player, int speed, int size) {
    super(speed, size, player);
    sprite = loadImage("explosion projectile.png");
    activeTimer = 0;
    isExplosionActive = false;
  }
  
  @Override
  void collideWithEnemy() {
    for(Path path : paths) {
      for(Enemy e : path.followers) {
        if(dist(this.location.x, this.location.y, e.location.x, e.location.y)
                < this.spriteSize.x/2 + e.spriteSize.x/2) {
          e.health--;
          isActive = false;
          player.score += 5;
          activeTimer = 2;
          locX = e.location.x;
          locY = e.location.y;
          isExplosionActive = true;
          break;
        }
      }
    }
  }
  
  @Override
  void step() {
    if(isActive) {
      location.add(velocity);
      collideWithEnemy();
    }
    if(isExplosionActive){
      countdownToInactive();
      if(activeTimer != 0) {
        displayExplosion();
        explosionCollideWithEnemies();
      }
    }
  }
  
  void countdownToInactive() {
    if(frameCount % 60 == 0 && activeTimer > 0) {
      activeTimer--;
    }
    if(activeTimer == 0) {
      isExplosionActive = false;
    }
  }
  
  /* The variable below, helps in order to display each individual explosion animation without one explosion
     anim interfering with another. That is because there is only one animation object regarding the explosion
     (the reason behind this is because when loading the frames of an animation it takes time, so this way we are
     both saving resources and avoiding lagging), and every time the display method (the one from the Animation class)
     is being called within this class, the frame field has the same value. That is the reason why if more than 1 
     animations are being displayed simultaneously, the animation will display both anims in the same frame. The 
     variable below is a replacement for the frame field of the Animation class. That way the frames are being 
     displayed independently of the other explosive animations that may display at the same time and alter the frame
     variable. Makes sense but is kind of complicating to explain.
  */
  int frame = -1;
  void displayExplosion() {
     explosionAnim.frame = frame++;
     explosionAnim.display(locX, locY, false);
     // Uncomment to see explosion radius.
     /*
     rectMode(CENTER);
     noFill();
     stroke(#FFFFFF);
     rect(locX, locY, explosionWidth, explosionHeight);
     */
  }
  
  void explosionCollideWithEnemies() {
    for(Path path : paths) {
      for(Enemy e : path.followers) {
        if(e.location.x > locX - explosionWidth/4
           && e.location.x < locX + explosionWidth/4
           && e.location.y > locY - explosionHeight/4
           && e.location.y < locY + explosionHeight/4
          ) {
          e.health--;
          player.score += 5;
        }
      }
    }
  }
  
}
