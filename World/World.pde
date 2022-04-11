import java.util.*;
import java.net.http.*;
import java.net.URI;
import processing.sound.*;

Background backgroundImage;
Background backgroundImage2;
Player player;
List<PlayerProjectile> playerProjectiles;
List<EnemyProjectile> enemyProjectiles;
List<PowerUp> powerUps;
List<Path> paths;
int enemiesSize = 50;
int enemiesHealth = 1;
boolean shouldGetWord = false;
PFont myCustomFont;
/* The animation of the lightning power(as well as every aimation) needs to be initialised in the setup
   in order to load all the required frames once. Else the program lags.
*/
Animation lightningAnim;
int lightningHeight;
int lightningWidth;
SoundFile file;
int shieldSize;
Animation explosionAnim;
List<Explosive> explosives;

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
  myCustomFont = createFont("Eras Bold ITC", 24);
  textFont(myCustomFont);
  player = new Player(50, 15, 3);
  playerProjectiles = new ArrayList<>();
  enemyProjectiles = new ArrayList<>();
  paths = new ArrayList<>();
  powerUps = new ArrayList<>();
  createPaths(1);
  lightningWidth = 100;
  lightningHeight = 600;
  lightningAnim = new Animation("tile", 7);
  shieldSize = 150;
  file = new SoundFile(this, "laserRetro_000.wav");
  explosionAnim = new Animation("frame_", 80);
  explosives = new ArrayList<>();
}

void draw() {
  background(#030303);
  // Background related variables
  backgroundImage.step();
  backgroundImage.display();
  backgroundImage2.step();
  backgroundImage2.display();
  displayPlayerHealth();
  displayPlayerScore();
  for(PowerUp pwr : powerUps) {
    if(!pwr.isConsumed) {
      pwr.display();
    }
    pwr.step();
  }
  for(EnemyProjectile ep : enemyProjectiles) {
    if(ep.isActive) {
      ep.step();
      ep.display();
    }
  }
  for(PlayerProjectile p : playerProjectiles) {
    if(p.isActive) {
      p.step();
      p.display();
    }
  }
  for(Explosive ex : explosives) {
   ex.display();
   ex.step();
  }
  if(player.health > 0) {
    player.step();
    player.display();
  }
  for(Path path : paths) {
    path.step();
    path.display();
    if(path.isReadyToChange) {
      alterPathAndEnemies(path);
    }
  }
  if(shouldGetWord) {
    receiveRandomWord();
  }
}

void createPaths(int numberOfPathsToGenerate) {
  for(int f=0; f<numberOfPathsToGenerate; f++) {
    Path path = new Path();
    PVector[] waipointPositions = randomlyPositionWaypoints(enemiesSize);
    path.addWaypoint(waipointPositions[0]);
    path.addWaypoint(waipointPositions[1]);
    int numberOfEnemies = generateRandomNumberForEnemies();
    int enemiesVelocity = (int)random(5, 10);
    for(int i=0; i<numberOfEnemies; i++) {
      Enemy enemy = new Enemy(enemiesVelocity, enemiesSize, enemiesHealth);
      enemy.setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
      path.addEnemy(enemy);
    }
    paths.add(path);
  }
}

void alterPathAndEnemies(Path path) {
   PVector[] waipointPositions = randomlyPositionWaypoints(enemiesSize);
   path.waypoints.get(0).x = waipointPositions[0].x;
   path.waypoints.get(0).y = waipointPositions[0].y;
   path.waypoints.get(1).x = waipointPositions[1].x;
   path.waypoints.get(1).y = waipointPositions[1].y;
   int enemiesVelocity = (int)random(5, 10);
   for(int i=0; i<path.followers.size(); i++) {
     path.followers.get(i).maxSpeed = enemiesVelocity;
     path.followers.get(i).setRandomSprite();
     path.followers.get(i).currentPoint = 0;
     path.followers.get(i).health = enemiesHealth;
     path.followers.get(i).setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
   }
   path.isReadyToChange = false;
   path.enemyNumber = -1;
   path.timer = 1;
   path.followersThatHaveFinished = 0;
}

int generateRandomNumberForEnemies() {
  return (int)random(3, 8);
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

/* The object below is required for the purpose of stopping the player from shooting while a 
   lightning powerup is active. For this to happen we have to check whether a SPECIFIC lightning
   power up is active. That is why we need to store the object to the reference below. We initialise
   it only for the reason of not causing problems at the beggining of the game where the third condition 
   on the if statement below would bring a NullPointerException.
   Even though this works, it is noticed that (sometimes) for a split second you can shoot even though the powerup
   is active.
*/
PowerUp lightningPowerUp = new PowerUp();
// For the same reason as described above.
PowerUp explosivePowerUp = new PowerUp();
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
   if ((key == 'S' || key == 's') && player.health > 0 
       && !lightningPowerUp.isLightningPowerUpActive && !explosivePowerUp.isExplosivePowerUpActive) {
     playerProjectiles.add(new PlayerProjectile(20, 20, player));
   }
   if ((key == 'S' || key == 's') && explosivePowerUp.isExplosivePowerUpActive) {
     playerProjectiles.add(new ExplosiveProjectile(player, 20, 20));
   }
}

void keyReleased() {
  if ((keyCode == UP) || (keyCode == DOWN) 
      || (keyCode == LEFT) || (keyCode == RIGHT)) {
    player.stop();
  }
}

void receiveRandomWord() {
  HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://random-words-with-pronunciation.p.rapidapi.com/word"))
    .header("X-RapidAPI-Host", "random-words-with-pronunciation.p.rapidapi.com")
    .header("X-RapidAPI-Key", "e477cbefb7msh5d203ec6373a1f1p1e5e74jsnc3f8fa60ec02")
    .method("GET", HttpRequest.BodyPublishers.noBody())
    .build();  
  try{
    HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
    System.out.println(response.body());
  }catch(Exception e) {
    System.out.println("An error occured while trying to receive a random word.");
  }
}

void displayPlayerHealth() {
  int posx = width-105;
  int posy = 20;
  for(int i=0; i<player.health; i++) {
    imageMode(CENTER);
    image(player.sprite, posx+=30, posy, 20, 20);
  }
}

void displayPlayerScore() {
  textSize(20);
  text("Score", 5, 20);
  text(player.score, 5, 40);
}
