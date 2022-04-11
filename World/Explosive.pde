public class Explosive {
  
  /*
  There is a minimal delay between the time where the explosive projectile collides
  with an enemy and the time where the explosive animation is being displayed.
  That is most probably because the explosive is being added to the corresponding
  list of explosives (look at World) and the program needs to reach that point, traverse
  the list, and call the step and display methods. That cause the explosive not appearing
  exactly when the projectiles hits the enemy.
  Since the explosion effect is not triggered by the damaged enemy but by the explosive itself,
  it doesn't affect the game conceptually.
  */
  
  int activeTimer;
  boolean isActive;
  // The projectile that caused the explosive on impact.
  ExplosiveProjectile ep;
  // Location to spawn explosive.
  float locX;
  float locY;
  
  public Explosive(ExplosiveProjectile ep, float locX, float locY) {
    activeTimer = 2;
    this.ep = ep;
    this.locX = locX;
    this.locY = locY;
  }
  
  void step() {
    if(frameCount % 60 == 0 && activeTimer > 0) {
      activeTimer--;
      isActive = true;
    }
    if(activeTimer == 0) {
      isActive = false;
    }
  }
  
  void display() {
    if(isActive) {
      explosionAnim.display(locX, locY, false);
    }
  }
  
}
