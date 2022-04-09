import java.util.*;
public class Path {
  
  List<PVector> waypoints;
  List<Enemy> followers;
  int waypointSize = 5;
  int timer;
  /* When less than one second passes, the first enemy will start following the path (-1 will become 0)
     After the same amount of time the next enemy will start following the path. It will keep going this
     way for all enemies.*/
  int enemyNumber = -1;
  
  public Path() {
    waypoints = new ArrayList<>();
    followers = new ArrayList<>();
    timer = 1;
  }
  
  void addWaypoint(PVector waypoint) {
    waypoints.add(waypoint);
  }
  
  void addEnemy(Enemy enemy) {
    followers.add(enemy);
    enemy.path = this;
  }
  
  void display() {
    for(PVector w : waypoints) {
      fill(#FFFFFF);
      circle(w.x, w.y, waypointSize);
    }
  }
  
  void step() {
      displayEnemies();
      // If it was mod 60 it would mean that 1 second has passed. I want the difference to be (almost) the one 
      // third of that.
      if (frameCount % 15 == 0 && timer > 0) { 
        timer--;
      }
      if(timer == 0) {
          enemyNumber++;
          if(enemyNumber < followers.size()) {
            followers.get(enemyNumber).shouldStart = true;
            // reset the timer for the next enemy in line.
            timer = 1;
          }
      }
  }
  
  void displayEnemies() {
    for(Enemy e : followers) {
      e.step();
      e.display();
    }
  }
  
}
