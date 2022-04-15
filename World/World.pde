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
boolean shouldGetWord = true;
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
int explosionWidth;
int explosionHeight;
int automaticPointsTimer;

// regarding the typing phase
boolean isGameInTypingState;
int typingStateCounter;
int typingStateCounterStatic = 8;
String randomKey = null;
boolean isRandomKeyGenerated;
char[] chars;
boolean[] isCharTyped = null;
boolean isWordPreparedForChecking = false;
boolean isWordTyped = false;

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
  createPaths(2);
  lightningWidth = 100;
  lightningHeight = 600;
  lightningAnim = new Animation("tile", 7);
  shieldSize = 150;
  file = new SoundFile(this, "laserRetro_000.wav");
  explosionWidth = 200;
  explosionHeight = 200;
  explosionAnim = new Animation("frame_", 80);
  automaticPointsTimer = 10;
  isGameInTypingState = false;
  typingStateCounter = 0;
  isRandomKeyGenerated = false;
}
String[] words;
void draw() {
  background(#030303);
  // Background related variables
  backgroundImage.step();
  backgroundImage.display();
  backgroundImage2.step();
  backgroundImage2.display();
  displayPlayerHealth();
  displayPlayerScore();
  if(!isGameInTypingState) {
    addAutoScoreTimer();
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
    for(Path path : paths) {
      path.step();
      path.display();
      if(path.isReadyToChange) {
        alterPathAndEnemies(path);
      }
    }
  }
  if(isGameInTypingState) {
    enableTypingState();
    if(isWordTyped) {
      Enemy e = new Enemy();
      e.location = new PVector();
      e.location.x = width/2;
      e.location.y = height/2;
      PowerUp p = new PowerUp();
      p.spawnPowerUp(e);
      powerUps.add(p);
      endTypingPhase();
    }
  }
}

void enableTypingState() {
  if(!isRandomKeyGenerated) {
    // we retrieve a word only once every time
    randomKey = retrieveRandomKey();
    isRandomKeyGenerated = true;
    if(!isWordPreparedForChecking) {
       prepareWordChecking();
       isWordPreparedForChecking = true;
    }
  }
  typingStateCounter();
  if(randomKey != null) {
    text("Time Left: " + typingStateCounter, width/2-50, 250);
    text("Type: ", width/2-20, 300);
    int i = 0;
    int pointX = 100;
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
    endTypingPhase();
  }
}

void endTypingPhase() {
    isGameInTypingState = false;
    isRandomKeyGenerated = false;
    isWordPreparedForChecking = false;
    isWordTyped = false;
    typingStateCounter = 0;
}

// key; in the sense of a random word or quote. Also because it "unclocks" access to a power up.
String retrieveRandomKey() {
    String randomWord = receiveRandomWord();
    // boolean isOnlyLeft = false;
    words = getWordsFromJSONString(randomWord, 6);
    if(words[0] == null) {
      // If the first option doesn't work then randomly choose one of the other two.
      // float random = random(0, 1);
      // if(random < 0.66) {
          randomWord = receiveRandomDutchWord();
          words = getWordsFromJSONString(randomWord, 6);
          // System.out.println("(Dutch word)" + words[1]);
          //if(words[0] == null) {
            // isOnlyLeft = true;
          //} else {
          //  return words[1];
          //}
          return words[1];
      /*else if (random >= 0.66 || isOnlyLeft){
        String q = receiveRandomQuote();
        try {
          String[] qs = getWordsFromJSONString(q, 50);
          // if a quote is big, we just get the first sentence. The content doesn't really
          // matter anyway.
          String randomQ = qs[4];
          int pointBefore = 0;
          for(int i=0; i<randomQ.length(); i++) {
            if(randomQ.charAt(i) == '.') {
              pointBefore = i;
              break;
            }
          }
          return randomQ.substring(0, pointBefore);
        } catch(ArrayIndexOutOfBoundsException | NullPointerException e) {
          return "Random Sentence";
        }
      }*/
    } else {
      return words[1];
    }
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
   if(isGameInTypingState && isRandomKeyGenerated) {
     for(int i=0; i<randomKey.length(); i++) {
       if(key == randomKey.charAt(i) && isCharTyped[i] == false) {
         isCharTyped[i] = true;
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
    .header("X-RapidAPI-Key", "e477cbefb7msh5d203ec6373a1f1p1e5e74jsnc3f8fa60ec02")
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
    .header("X-RapidAPI-Key", "e477cbefb7msh5d203ec6373a1f1p1e5e74jsnc3f8fa60ec02")
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
    .header("X-RapidAPI-Key", "e477cbefb7msh5d203ec6373a1f1p1e5e74jsnc3f8fa60ec02")
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
