import java.util.*;

Background backgroundImage;
Background backgroundImage2;
Player player;
List<PlayerProjectile> playerProjectiles;
Path path1;

void setup() {
  size(500, 800);
  // Regarding the scrolling background.
  backgroundImage = new Background();
  backgroundImage.location.x = width/2;
  backgroundImage.location.y = -backgroundImage.imageSize.y/2;
  backgroundImage2 = new Background();
  backgroundImage2.location.x = width/2;
  backgroundImage2.location.y = -(backgroundImage2.imageSize.y/2 
    - backgroundImage.imageSize.y);
  player = new Player(50, 15);
  playerProjectiles = new ArrayList<>();
  createPaths();
}

void draw() {
  background(#030303);
  // Background related variables
  backgroundImage.step();
  backgroundImage.display();
  backgroundImage2.step();
  backgroundImage2.display();
  for(PlayerProjectile p : playerProjectiles) {
    p.step();
    p.display();
  }
  player.step();
  player.display();
  path1.step();
  path1.display();
}

void createPaths() {
  // First Path
  path1 = new Path();
  path1.addWaypoint(new PVector(0, height/2));
  path1.addWaypoint(new PVector(width, height/2));
  Enemy enemy1 = new Enemy(5, 50);
  Enemy enemy2 = new Enemy(5, 50);
  Enemy enemy3 = new Enemy(5, 50);
  path1.addEnemy(enemy1);
  path1.addEnemy(enemy2);
  path1.addEnemy(enemy3);
}

void keyPressed(){
   if (keyCode == UP) {
     player.moveUp();
   }
   if (keyCode == DOWN) {
      player.moveDown();
   }
   if (keyCode == LEFT) {
      player.moveLeft();
   }
   if (keyCode == RIGHT) {
      player.moveRight();
   }
   if (key == 'S' || key == 's') {
     playerProjectiles.add(new PlayerProjectile(20, 20, player));
   }
}

void keyReleased() {
  if ((keyCode == UP) || (keyCode == DOWN) 
      || (keyCode == LEFT) || (keyCode == RIGHT)) {
    player.stop();
  }
}
