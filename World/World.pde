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
List<Boss> bosses;
List<Button> buttons;
int enemiesSize = 50;
int enemiesHealth = 1;
boolean shouldGetWord = true;
PFont myCustomFont;
/* The animation of the lightning power(as well as every animation) needs to be initialised in the setup
   in order to load all the required frames once. Else the program lags.
*/
Animation lightningAnim;
int lightningHeight;
int lightningWidth;
int shieldSize;
Animation explosionAnim;
int explosionWidth;
int explosionHeight;
int automaticPointsTimer;

// regarding the typing phase
boolean isGameInTypingState;
int typingStateCounter;
int typingStateCounterStatic = 4;
String randomKey;
char[] chars;
boolean[] isCharTyped = null;
boolean isWordTyped = false;
PowerUp powerUpToTrigger = null;
String[] words;

// boss 3 anims
Animation boss3open;
Animation boss3close;
int boss3AnimSize = 125;

/* 
  regarding the fixing of the bug where you press down the shooting key and
  there is constant firing whitout having fire rate. 
  This source helped me to implement the shooting rate after x amount of milliseconds
  -> https://forum.processing.org/one/topic/how-to-perform-an-action-every-x-seconds-time-delays.html
*/
int shootingRateTimer;
boolean areTypicalEnemiesActive = true;
boolean startGame = false;
int countToStart = -1;

// Sounds
SoundFile playerShootingSound;
SoundFile typicalEnemyShootingSound;
SoundFile lifePickUp;
SoundFile lightningPower;
SoundFile explosiveProjectile;
SoundFile explosiveProjectileExplosion;
SoundFile shieldPowerUp;
SoundFile boss1Projectile;
SoundFile bossDefeat;
SoundFile boss1Background;
SoundFile boss2Background;
SoundFile boss3Background;
SoundFile boss2Projectile;
SoundFile boss3ProjectilePhase1;
SoundFile boss3ProjectilePhase2;
SoundFile playerHit;
SoundFile correctLetter;
SoundFile boss3Transform;
SoundFile errorTyping;
SoundFile backgroundMusic;
SoundFile menuMusic;

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
  bosses = new ArrayList<>();
  createPaths(2);
  lightningWidth = 100;
  lightningHeight = 600;
  lightningAnim = new Animation("tile", 7);
  shieldSize = 150;
  explosionWidth = 200;
  explosionHeight = 200;
  explosionAnim = new Animation("frame_", 80);
  automaticPointsTimer = 10;
  isGameInTypingState = false;
  typingStateCounter = 0;
  randomKey = null;
  retrieveRandomKey();
  createBosses();
  shootingRateTimer = millis();
  boss3open = new Animation("open_", 60);
  boss3close = new Animation("close_", 7);
  buttons = new ArrayList<>();
  Button start = new Button(150, 40, new PVector(width/2-67, height/2+7), "Start game", 25, new PVector(width/2, height/2), #030303);
  buttons.add(start);
  // Sounds
  playerShootingSound = new SoundFile(this, "laserRetro_000.wav");
  typicalEnemyShootingSound = new SoundFile(this, "pewpew_1.wav");
  lifePickUp = new SoundFile(this, "life_pickup.wav");
  lightningPower = new SoundFile(this, "shock.wav");
  explosiveProjectile = new SoundFile(this, "pewpew_6.wav");
  // explosiveProjectileExplosion = new SoundFile(this, "sfx_explosionFlash.wav");
  explosiveProjectileExplosion = new SoundFile(this, "explosionCrunch_003.wav");
  shieldPowerUp = new SoundFile(this, "forceField_001.wav");
  boss1Projectile = new SoundFile(this, "pewpew_14.wav");
  bossDefeat = new SoundFile(this, "lowRandom.wav");
  boss1Background = new SoundFile(this, "BossMain.wav");
  boss2Background = new SoundFile(this, "Mercury.wav");
  boss3Background = new SoundFile(this, "Mars.wav");
  boss2Projectile = new SoundFile(this, "laserfire02.wav");
  boss3ProjectilePhase1 = new SoundFile(this, "pewpew_9.wav");
  boss3ProjectilePhase2 = new SoundFile(this, "pewpew_10.wav");
  playerHit = new SoundFile(this, "phaserDown2.wav");
  correctLetter = new SoundFile(this, "coin1.wav");
  boss3Transform = new SoundFile(this, "transforming.wav");
  errorTyping = new SoundFile(this, "Error.wav");
  backgroundMusic = new SoundFile(this, "Cyberpunk Moonlight Sonata.wav");
  menuMusic = new SoundFile(this, "Venus.wav");
}

void draw() {
  background(#030303);
  // Background related variables
  backgroundImage.step();
  backgroundImage.display();
  backgroundImage2.step();
  backgroundImage2.display();
  
  if(!startGame) {
    if(!menuMusic.isPlaying()) {
      menuMusic.loop();
    }
    // menu UI
    textMode(CENTER);
    fill(#FFEC0F);
    textSize(30);
    text("SPACE TYPING SURVIVAL", width/2-190, height/2-100);
    fill(#FFFFFF);
    for(Button b : buttons) {
      if(countToStart == -1) {
        b.display();
      }
    }
    startUpCounter();
  }
  
  if(startGame) {
    displayPlayerHealth();
    displayPlayerScore();
      
    if(!isGameInTypingState) {
      if(player.health > 0) {
        addAutoScoreTimer();
      }
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
         p.step();
         p.display();
      }
      if(player.health > 0) {
        player.step();
        player.display();
      }
      if(areTypicalEnemiesActive){
        for(Path path : paths) {
          path.step();
          path.display();
          if(path.isReadyToChange) {
            alterPathAndEnemies(path);
          }
        }
      }
      for(Boss boss : bosses) {
        if(!boss.isDefeated() && boss.isActive) {
           boss.step();
           boss.display();
           textMode(CENTER);
           fill(#FF0000);
           text("Health: " + boss.health, width/2-50, 50);
           fill(#FFFFFF);
        } else {
          boss.location.x = -500;
          boss.isActive = false;
        }
      }
    }
    if(isGameInTypingState) {
      enableTypingState();
      if(isWordTyped) {
        powerUpToTrigger.triggerPowerUp();
        powerUpToTrigger.isConsumed = true;
        endTypingPhase();
      }
    }
    initiateBosses();
  }
  
  // Game state in the case of player's death.
  if(player.health <= 0) {
    startGame = false;
    buttons.get(0).text = "Try again";
    buttons.get(0).textLocation.x = width/2-60;
    displayPlayerScore();
    backgroundMusic.stop();
    if(menuMusic.isPlaying()) {
      menuMusic.stop();
    }
  }
  
  // This stops the electric power sound when needed.
  if(lightningPowerUp != null && !lightningPowerUp.isLightningPowerActive() && lightningPower.isPlaying()) {
    lightningPower.stop();
  }
  
}

void initiateBosses() {
  if(player.score >= 500 && !bosses.get(0).isDefeated()) {
    disappearTypicalEnemies();
    disableAnyRunningPowerUps();
    bosses.get(0).isActive = true;
    areTypicalEnemiesActive = false;
    backgroundMusic.stop();
    if(!boss1Background.isPlaying()) {
      boss1Background.amp(0.8);
      boss1Background.loop();
    }
  }
  if(player.score >= 1500 && !bosses.get(1).isDefeated()) {
    disappearTypicalEnemies();
    disableAnyRunningPowerUps();
    bosses.get(1).isActive = true;
    areTypicalEnemiesActive = false;
    backgroundMusic.stop();
    if(!boss2Background.isPlaying()) {
      boss2Background.amp(1);
      boss2Background.loop();
    }
  }
  if(player.score >= 2500 && !bosses.get(2).isDefeated()) {
    disappearTypicalEnemies();
    disableAnyRunningPowerUps();
    bosses.get(2).isActive = true;
    areTypicalEnemiesActive = false;
    backgroundMusic.stop();
    if(!boss3Background.isPlaying()) {
      boss3Background.amp(0.8);
      boss3Background.loop();
    }
  }
  if(bosses.get(0).isDefeated() && bosses.get(1).isDefeated() && bosses.get(2).isDefeated()) {
    disappearTypicalEnemies();
    displayPlayerScore();
    if(enemyProjectiles.size() > 0) {
      enemyProjectiles.removeAll(enemyProjectiles);
    }
    textMode(CENTER);
    textSize(80);
    fill(#12FF03);
    text("END", width/2-100, height/2);
    fill(#F3FAF2);
    textSize(20);
    text("Developer: Fanis Gkoufas", width/2-100, height/2+20);
    fill(#FFFFFF);
  }
}

void disableAnyRunningPowerUps() {
  for(PowerUp pwr : powerUps) {
    if(pwr.isLightningPowerUpActive) {
      pwr.isLightningPowerUpActive = false;
    }
    if(pwr.isExplosivePowerUpActive) {
      pwr.isExplosivePowerUpActive = false;
    }
  }
  for(PlayerProjectile pl : playerProjectiles) {
    if(pl instanceof ExplosiveProjectile) {
      ExplosiveProjectile expl = (ExplosiveProjectile) pl;
      expl.isExplosionActive = false;
    }
  }
}

void disappearTypicalEnemies() {
  for(Path p : paths) {
    for(Enemy e : p.followers) {
      e.currentPoint = p.waypoints.size();
      e.health = 1;
      e.location.x = p.waypoints.get(p.waypoints.size()-1).x;
      e.location.y = p.waypoints.get(p.waypoints.size()-1).y;
    }
  }
}

void createBosses() {
  // Boss #1
  Boss boss1 = new Boss(7, 100, 50, "shipYellow_manned.png", 150, 1);
  Path[] boss1Paths = new Path[1];
  Path path0 = new Path();
  path0.addWaypoint(new PVector(0+boss1.spriteSize.x/2-40, 0+boss1.spriteSize.y/2));
  path0.addWaypoint(new PVector(width/2, height/2));
  path0.addWaypoint(new PVector(width-boss1.spriteSize.x/2, height-boss1.spriteSize.y/2));
  path0.addWaypoint(new PVector(width/2-boss1.spriteSize.x/2, height/2-boss1.spriteSize.y/2));
  path0.addWaypoint(new PVector(0+boss1.spriteSize.x/2, height-boss1.spriteSize.y/2));
  path0.addWaypoint(new PVector(width/2, height/2));
  path0.addWaypoint(new PVector(width-boss1.spriteSize.x/2+40, 0+boss1.spriteSize.y/2));
  path0.addWaypoint(new PVector(width/2, height/2));
  boss1Paths[0] = path0;
  boss1.setPaths(boss1Paths);
  boss1.setStartingLocation(new PVector(0,0));
  boss1.shouldStart = true;
  boss1.setPathToFollow(0);
  bosses.add(boss1);
  
  // Boss #2
  Boss boss2 = new Boss(8, 70, 70, "boss2.png", 300, 2);
  Path[] boss2Paths = new Path[1];
  Path boss2Path0 = new Path();
  boss2Path0.addWaypoint(new PVector(0+boss2.spriteSize.x/2, 0+boss2.spriteSize.x/2));
  boss2Path0.addWaypoint(new PVector(width-boss2.spriteSize.x/2, 0+boss2.spriteSize.x/2));
  boss2Path0.addWaypoint(new PVector(width-boss2.spriteSize.x/2, 200));
  boss2Path0.addWaypoint(new PVector(0+boss2.spriteSize.x/2, 200));
  boss2Path0.addWaypoint(new PVector(0+boss2.spriteSize.x/2, 400));
  boss2Path0.addWaypoint(new PVector(width-boss2.spriteSize.x/2, 400));
  boss2Path0.addWaypoint(new PVector(0+boss2.spriteSize.x/2, 700));
  boss2Path0.addWaypoint(new PVector(width-boss2.spriteSize.x/2, 700));
  boss2Path0.addWaypoint(new PVector(0+boss2.spriteSize.x/2, 700));
  boss2Path0.addWaypoint(new PVector(width-boss2.spriteSize.x/2, 400));
  boss2Path0.addWaypoint(new PVector(0+boss2.spriteSize.x/2, 400));
  boss2Path0.addWaypoint(new PVector(0+boss2.spriteSize.x/2, 200));
  boss2Path0.addWaypoint(new PVector(width-boss2.spriteSize.x/2, 200));
  boss2Path0.addWaypoint(new PVector(width-boss2.spriteSize.x/2, 0+boss2.spriteSize.x/2));
  boss2Path0.addWaypoint(new PVector(0+boss2.spriteSize.x/2, 0+boss2.spriteSize.x/2));
  boss2Paths[0] = boss2Path0;
  boss2.setPaths(boss2Paths);
  boss2.setStartingLocation(new PVector(0, 0));
  boss2.shouldStart = true;
  boss2.setPathToFollow(0);
  bosses.add(boss2);
  
  // Boss #3
  Boss boss3 = new Boss(5, 125, 100, "boss3.png", 350, 3);
  Path[] boss3Paths = new Path[3];
  // Path #0
  Path boss3Path0 = new Path();
  boss3Path0.addWaypoint(new PVector(0+boss3.spriteSize.x/2-80, 150));
  boss3Path0.addWaypoint(new PVector(width-boss3.spriteSize.x/2+80, 150));
  boss3Paths[0] = boss3Path0;
  // Path #1
  Path boss3Path1 = new Path();
  boss3Path1.addWaypoint(new PVector(width/2, height/2));
  boss3Paths[1] = boss3Path1;
  // Path #3
  Path boss3Path2 = new Path();
  boss3Path2.addWaypoint(new PVector(100, 100));
  boss3Path2.addWaypoint(new PVector(width/2, 50));
  boss3Path2.addWaypoint(new PVector(430, 150));
  boss3Path2.addWaypoint(new PVector(430, height-100));
  boss3Path2.addWaypoint(new PVector(30, height-100));
  boss3Paths[2] = boss3Path2;
  boss3.setPaths(boss3Paths);
  boss3.setStartingLocation(new PVector(0, 0));
  boss3.shouldStart = true;
  boss3.setPathToFollow(0);
  bosses.add(boss3);
}

void enableTypingState() {
  typingStateCounter();
  if(randomKey != null) {
    text("Time Left: " + typingStateCounter, width/2-50, 250);
    text("Type: ", width/2-20, 300);
    int i = 0;
    int pointX = 50;
    int pointY = 400;
    while(i < randomKey.length()) {
      if(isCharTyped != null) {
        if(isCharTyped[i] == true) {
          fill(#EDFF00);
        } else {
          fill(#FFFFFF);
        }
      }
      if(i == 0) {
        textSize(25);
        textMode(CENTER);
        text(randomKey.charAt(i), pointX, pointY);
      } else {
        textSize(25);
        textMode(CENTER);
        text(randomKey.charAt(i), pointX, pointY);
      }
      pointX += 5 + 25;
      i++;
    }
  }
  fill(#FFFFFF);
}

void typingStateCounter() {
  if(frameCount % 60 == 0 && typingStateCounter > 0) {
    typingStateCounter--;
  }
  if(typingStateCounter == 0) {
    errorTyping.amp(1);
    errorTyping.play();
    endTypingPhase();
  }
}

void endTypingPhase() {
    /*
      Every time that the typing phase finishes, either because the time runs out or because the player entered the
      word correctly, we want to call the webservice in order to retrieve another word. This happens because we want the
      random word to be already generated and ready to be displayed for the user, and not do that operation at that time.
      In addition to this, it is of great importance to call this method within a thread (the thread method is being provided
      by processing). That way we are not delaying and slowing down the program in order to call the webservice and retrieve the 
      result, but we do it in parallel. That way the program does not lag and slow down.
    */
    thread("retrieveRandomKey");
    isGameInTypingState = false;
    isWordTyped = false;
    typingStateCounter = 0;
    randomKey = null;
    if(powerUpToTrigger != null) {
      powerUpToTrigger.isConsumed = true;
    }
}

// key; in the sense of a random word or quote. Also because it "unclocks" access to a power up.
void retrieveRandomKey() {
    String randomWord = receiveRandomWord();
    words = getWordsFromJSONString(randomWord, 6);
    if(words[0] == null) {
      randomWord = receiveRandomDutchWord();
      words = getWordsFromJSONString(randomWord, 6);
      randomKey = words[1];
    } else {
      randomKey = words[1];
    }
    /*
      Uncomment line below in order to see the random generated word as well as the point when it is 
      being retrieved.
    */
    // System.out.println(randomKey);
    prepareWordChecking();
}

String[] getWordsFromJSONString(String randomWord, int numberOfExpectedWords) {
  int startingPoint = 0;
  int endPoint = 0;
  boolean hasSeenAnotherBracket = false;
  String[] words = new String[numberOfExpectedWords];
  String jsonWords = "";
  int counter = 0;
  for(int i=0; i<randomWord.length(); i++) {
    if(randomWord.charAt(i) == '"' && !hasSeenAnotherBracket) {
      startingPoint = i;
      hasSeenAnotherBracket = true;
    }
    if(randomWord.charAt(i) == '"' && hasSeenAnotherBracket && i != startingPoint) {
      endPoint = i;
      hasSeenAnotherBracket = false;
    }
    if(!hasSeenAnotherBracket && startingPoint != 0 && endPoint != 0) {
      jsonWords += randomWord.substring(startingPoint + 1, endPoint) + "\n";
      try{
        words[counter] = randomWord.substring(startingPoint + 1, endPoint);
      }catch(ArrayIndexOutOfBoundsException e) {
        return new String[0];
      }
      startingPoint = 0;
      endPoint = 0;
      counter++;
    }
  }
  return words;
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
   Enemy newEnemy = null;
   boolean shouldAdd = false;
   float randomNumber = random(0, 1);
   if(randomNumber <= 0.60) {
     shouldAdd = true;
   }
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
   if(shouldAdd) {
     float addOrDelete = random(0, 1);
     if(addOrDelete >= 0.40) {
       if(path.followers.size() < 7) {
         newEnemy = new Enemy(enemiesVelocity, enemiesSize, enemiesHealth);
         newEnemy.setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
         path.addEnemy(newEnemy);
         if(path.followers.size() >= 2 && path.followers.size() < 3) {
           Enemy additionalEnemy = new Enemy(enemiesVelocity, enemiesSize, enemiesHealth);
           additionalEnemy.setStartingLocation(new PVector(waipointPositions[0].x, waipointPositions[0].y));
           path.addEnemy(additionalEnemy);
         }
       }
     } else {
       if(path.followers.size() > 6) {
         path.followers.remove(path.followers.size()-1);
         path.followers.remove(path.followers.size()-1);
       } else if(path.followers.size() > 3) {
         path.followers.remove(path.followers.size()-1);
       }
     }
   }
}

int generateRandomNumberForEnemies() {
  return (int)random(4, 8);
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
         if(millis() > shootingRateTimer + 150) {
           // it may sound a bit odd at times but it prevents the audio of being disrupted after extensive use.
           if(!playerShootingSound.isPlaying() && !isGameInTypingState) {
              playerShootingSound.amp(0.7);
              playerShootingSound.play(); 
           }
           playerProjectiles.add(new PlayerProjectile(20, 20, player));
           shootingRateTimer = millis();
         }
   }
   if ((key == 'S' || key == 's') && explosivePowerUp.isExplosivePowerUpActive) {
     if(millis() > shootingRateTimer + 150) {
       explosiveProjectile.amp(1);
       explosiveProjectile.play();
       playerProjectiles.add(new ExplosiveProjectile(player, 20, 20));
       shootingRateTimer = millis();
     }
   }
   try {
     if(isGameInTypingState) {
       for(int i=0; i<randomKey.length(); i++) {
         if(key == randomKey.charAt(i) && isCharTyped[i] == false) {
           isCharTyped[i] = true;
           correctLetter.amp(1);
           correctLetter.play();
           break;
         }
       }
       for(int i=0; i<isCharTyped.length; i++) {
         if(isCharTyped[i] != true) {
           isWordTyped = false;
           break;
         }
         if(i == isCharTyped.length-1) {
           isWordTyped = true;
         }
       }
     }
   } catch(Exception e) {
     // Just to be safe
     endTypingPhase();
   }
}

void prepareWordChecking() {
   chars = new char[randomKey.length()];
   isCharTyped = new boolean[randomKey.length()];
   Arrays.fill(isCharTyped, false);
   randomKey.getChars(0, randomKey.length(), chars, 0);
}

void keyReleased() {
  if ((keyCode == UP) || (keyCode == DOWN) 
      || (keyCode == LEFT) || (keyCode == RIGHT)) {
    player.stop();
  }
}


/* 
Using the "Rapid API" platform, I managed to find an REST api that upon request, produces a
random word along with a definition and the way that word is pronounced. I chose this webservice
for the reason that it was free and provides 80 requests per minute (which is more than sufficient
I believe). The only problem is that sometimes upexpectedly it may not work. The problem is not in 
my code, but (I suppose) lies on the other end, which is something that I cannot do anything about.
So the same (company, guy?) provides another url mapping (service) which is doing the same work
(giving us random words) but now in dutch. So as an alternative, I'll call this service if the
first one has trouble.
Reference to the api -> https://rapidapi.com/mcnaveen/api/random-words-with-pronunciation/
*/
String receiveRandomDutchWord() {
  HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://random-words-with-pronunciation.p.rapidapi.com/word/dutch"))
    .header("X-RapidAPI-Host", "random-words-with-pronunciation.p.rapidapi.com")
    .header("X-RapidAPI-Key", "")
    .method("GET", HttpRequest.BodyPublishers.noBody())
    .build();  
  try{
    HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
    // System.out.println(response.body());
    return response.body();
  }catch(Exception e) {
    System.out.println("An error occured while trying to receive a random word.");
  }
  return null;
}

String receiveRandomWord() {
  HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://random-words-with-pronunciation.p.rapidapi.com/word"))
    .header("X-RapidAPI-Host", "random-words-with-pronunciation.p.rapidapi.com")
    .header("X-RapidAPI-Key", "")
    .method("GET", HttpRequest.BodyPublishers.noBody())
    .build();  
  try{
    HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
    // System.out.println(response.body());
    return response.body();
  }catch(Exception e) {
    System.out.println("An error occured while trying to receive a random word.");
  }
  return null;
}
// Putting an extra alternative.
/*String receiveRandomQuote() {
  HttpRequest request = HttpRequest.newBuilder()
    .uri(URI.create("https://quotes15.p.rapidapi.com/quotes/random/"))
    .header("X-RapidAPI-Host", "quotes15.p.rapidapi.com")
    .header("X-RapidAPI-Key", "")
    .method("GET", HttpRequest.BodyPublishers.noBody())
    .build();  
  try{
    HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
    // System.out.println(response.body());
    return response.body();
  }catch(Exception e) {
    System.out.println("An error occured while trying to receive a random word.");
  }
  return null;
}*/

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

// Player gets 10 points for every 10 seconds that (s/)he is alive in the game.
void addAutoScoreTimer() {
  if(frameCount % 60 == 0 && automaticPointsTimer > 0) {
    automaticPointsTimer--;
  }
  if(automaticPointsTimer == 0) {
    addScoreForBeingAlive();
    automaticPointsTimer = 10;
  }
}

void addScoreForBeingAlive() {
  player.score += 10;
}

void mouseClicked() {
  int posX = mouseX;
  int posY = mouseY;
  Button start = buttons.get(0);
  if(posX >= start.bLocation.x - start.bWidth/2 
     && posX <= start.bLocation.x + start.bWidth/2
     && posY >= start.bLocation.y - start.bHeight/2
     && posY <= start.bLocation.y + start.bHeight/2) {
    // for the retry
    if(player.health <= 0) {
      setup();
      areTypicalEnemiesActive = true;
    }
    countToStart = 3;
  }
}

void startUpCounter() {
  if(frameCount % 60 == 0 && countToStart > 0) {
    countToStart--;
  }
  if(countToStart == 0) {
    startGame = true;
    countToStart = -1;
    backgroundMusic.amp(0.6);
    backgroundMusic.loop();
    menuMusic.stop();
  }
  if(countToStart == -1) {
    return;
  }
  textMode(CENTER);
  fill(#FFEC0F);
  textSize(60);
  text(countToStart, width/2-20, height/2+50);
  fill(#FFFFFF);
}
