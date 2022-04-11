public class ExplosiveProjectile extends PlayerProjectile {
  
  public ExplosiveProjectile(Player player, int speed, int size) {
    super(speed, size, player);
    sprite = loadImage("explosion projectile.png");
  }
  
  @Override
  void collideWithEnemy() {
    for(Path path : paths) {
      for(Enemy e : path.followers) {
        if(dist(this.location.x, this.location.y, e.location.x, e.location.y) 
                < this.spriteSize.x/2 + e.spriteSize.x/2) {
          explosives.add(new Explosive(this, e.location.x, e.location.y));
          e.health--;
          isActive = false;
          player.score += 5;
        }
      }
    }
  }
  
}
