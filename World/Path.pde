import java.util.*;
public class Path {
  
  List<PVector> waypoints;
  List<Boolean> waypointsStatus;
  Boolean[] shouldBegin;
  List<Enemy> followers;
  int waypointSize = 5;
  int timer;
  
  public Path() {
    waypoints = new ArrayList<>();
    waypointsStatus = new ArrayList<>();
    followers = new ArrayList<>();
    timer = 1;
  }
  
  void addWaypoint(PVector waypoint) {
    waypoints.add(waypoint);
    waypointsStatus.add(false);
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
      /*displayEnemies();
      for(Enemy e : followers) {
        if(e.currentPoint != waypoints.size()) {
          if(e.location.x != waypoints.get(e.currentPoint).x 
             && e.location.y != waypoints.get(e.currentPoint).y
             && waypointsStatus.get(e.currentPoint) == false) {
            seek(new PVector(waypoints.get(e.currentPoint).x, waypoints.get(e.currentPoint).y), e);
            if(dist(e.location.x, e.location.y,
                    waypoints.get(e.currentPoint).x, waypoints.get(e.currentPoint).y)
                    < e.spriteSize.x/2 + waypointSize/2) {
              waypointsStatus.set(e.currentPoint, false);
              e.currentPoint++;
            }
          }
        } else {
          e.velocity.x = 0;
          e.velocity.y = 0;
        }
      }*/
      /*displayEnemies();
      for(Enemy e : followers) {
        e.followPath(this);
      }*/
      if (frameCount % 15 == 0 && timer > 0) { 
        timer--;
      }
      displayEnemies();
      if(timer == 0) {
          enemyNumber++;
          if(enemyNumber < followers.size()) {
          followers.get(enemyNumber).shouldStart = true;
          timer = 1;
          }
        }
      for(int i=0;i<followers.size();i++) {
        followers.get(i).followPath();
      }
  }
  boolean isFinished = false;
  int enemyNumber = -1;
  
  void displayEnemies() {
    for(Enemy e : followers) {
      e.step();
      e.display();
    }
  }
  
}
