class Boss extends Enemy {
  
  Path[] paths;
  
  public Boss() {}
  
  public Boss(int speed, int size, int health, String imageName, int shootingRate, int bossNumber) {
    super(speed, size, health);
    sprite = loadImage(imageName);
    super.shootingRate = shootingRate;
    super.bossNumber = bossNumber;
  }
  
  void setPaths(Path[] paths) {
    this.paths = paths;
  }
  
  void setPathToFollow(int pathNumber) {
    super.path = paths[pathNumber];
  }
  
  boolean isDefeated() {
    return health <= 0;
  }
  
}
