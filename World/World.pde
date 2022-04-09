import java.util.*;

Background backgroundImage;
Background backgroundImage2;
Player player;
List<PlayerProjectile> playerProjectiles;
List<Path> paths;
int enemiesSize = 50;

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
  paths = new ArrayList<>();
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
  for(Path path : paths) {
    path.step();
    path.display();
  }
}

void createPaths() {
  PVector[] waipointPositions = randomlyPositionWaypoints(enemiesSize);
  // First Path
  Path path1 = new Path();
  path1.addWaypoint(waipointPositions[0]);
  path1.addWaypoint(waipointPositions[1]);
  Enemy enemy1 = new Enemy(6, enemiesSize);
  enemy1.setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
  Enemy enemy2 = new Enemy(6, enemiesSize);
  enemy2.setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
  Enemy enemy3 = new Enemy(6, enemiesSize);
  enemy3.setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
  Enemy enemy4 = new Enemy(6, enemiesSize);
  enemy4.setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
  Enemy enemy5 = new Enemy(6, enemiesSize);
  enemy5.setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
  path1.addEnemy(enemy1);
  path1.addEnemy(enemy2);
  path1.addEnemy(enemy3);
  path1.addEnemy(enemy4);
  path1.addEnemy(enemy5);
  paths.add(path1);
  
}

PVector[] randomlyPositionWaypoints(int pathsEnemySize) {
  int randomChoiceForPathType = (int)random(0, 4);
  /* There are 4 cases where the waypoints can be placed (in the case of having two waypoints which is 
     sufficient):
     #0 anywhere from the left side -> anywhere to the right side.
     #1 anywhere from the right side -> anywhere to the left side.
     #2 anywhere from the top side -> anywhere to the bottom side.
     #3 anywhere from the bottom side -> anywhere to the top side.
     Remider! A path is a set of waypoints. The enemies follow each waypoint sequentially.
  */
  PVector waypointLocationA = new PVector();
  PVector waypointLocationB = new PVector();
  switch(randomChoiceForPathType) {
    case 0:
      waypointLocationA = new PVector(-pathsEnemySize, random(0, height));
      waypointLocationB = new PVector(width+pathsEnemySize, random(0, height));
    break;
    case 1:
      waypointLocationA = new PVector(width+pathsEnemySize, random(0, height));
      waypointLocationB = new PVector(-pathsEnemySize, random(0, height));
    break;
    case 2:
      waypointLocationA = new PVector(random(0, width), -pathsEnemySize);
      waypointLocationB = new PVector(random(0, width), height+pathsEnemySize);
    break;
    case 3:
      waypointLocationA = new PVector(random(0, width), height+pathsEnemySize);
      waypointLocationB = new PVector(random(0, width), -pathsEnemySize);
    break;
  }
  /* I am returning the path that was chosen (forced to return it as a PVector), for the purpose
     of initialising the enemies' position near the first waypoint (does not work if 
     we initialise the location on top of the first one). But we have to know the side else we could
     end up initialising the enemies within the player's view.
  */
  return new PVector[]{ waypointLocationA, waypointLocationB };
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
