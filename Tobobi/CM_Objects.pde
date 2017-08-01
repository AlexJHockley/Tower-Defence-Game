  /* =========================================================================== */
 /*  This tab contains all classes relating to ENTITIES and BULLETS on the map. */  
/* =========================================================================== */

/**
* The bullet class represents what is fired from turrets. It can hit entities and damage them.
**/
class Bullet extends PVector {
  private PVector velo;
  public float damage;
  private float bulletSize = TILE_SIZE / 10;
  private color col = color(50, 50, 255);
  private float lastX, lastY;
  private float range;
  private PVector start;
  
  Bullet(float damage, float vX, float vY, float x, float y, float speed, float range) {
    super(x, y);
    this.start = new PVector(x, y);
    this.damage = damage;
    PVector velocity = PVector.sub(new PVector(vX, vY), this);
    velocity.normalize();
    velocity.mult(speed);
    this.velo = velocity;
    this.lastX = x;
    this.lastY = y;
    this.range = range;
  }
  
  /**
  * Draws the bullet and updates its position
  */
  void drawBullet() {
    fill(col);
    noStroke();
    ellipse(x, y, bulletSize, bulletSize);
    fill(col, 50);
    
    stroke(col, 20);
    strokeWeight(bulletSize / 2);
    line(x, y, lastX, lastY);
    
    this.updatePoint();
  }
  
  void updatePoint() {
    add(velo);
  }
  
  /**
  * If the bullet has gone beyond its range, or out of the map view, then it must be removed.
  **/
  boolean outOfBounds() {
    if (dist(this, this.start) > range) {
     return true; 
    }
    else if (this.x < ZERO_X || this.y < ZERO_Y || this.x > END_X || this.y > END_Y)
      return true;
      
    return false;
  }
  
  /**
  * Check if the bullet contains a point
  **/
  boolean targetHit(Entity target) {
   if (dist(this, new PVector(target.x, target.y)) <= target.size / 2) {
     return true;
   }
   return false;
  }
  
  /**
  * Check if the bullet contains a point
  **/
  boolean contains(float inX, float inY) {
   if (dist(this, new PVector(inX, inY)) <= bulletSize * 2) {
     return true;
   }
   return false;
  }
}




/**
* The entity class represents the enemies which move accross the map. They are what the turrets fire at.
* They follow a set path to reach their goal.
**/
class Entity {
  int nextPointIndex = 0;
  Point nextPoint;
  int direction = -1;
  int x, y;
  int type;
  float maxHp, currentHp;
  float size = HALF_TILE;
  int startGap = 90;  //Wait this frames before you start moving
  int num;  //The number of this entity is equivalkent to its position in the array
  color col = color(255, 50, 50);
  boolean endReached = false;
  
  Entity(int type, int num) {
    this.nextPointIndex = 0;  //Set up the target point
    this.nextPoint = path.points[nextPointIndex];
    
    this.x = -width;
    this.y = -height;
    this.type = type;
    
    if (type == 0) {
      this.maxHp = 50;
      this.currentHp = 50;
    }
    else if (type == 1) {
      this.maxHp = 100;
      this.currentHp = 100;
    }
    else if (type == 2) {
      this.maxHp = 500;
      this.currentHp = 500; 
    }
    else if (type == 3) {
      this.maxHp = 1000;
      this.currentHp = 1000;
    }
    this.num = num;
    
    
  }
  
  /**
  * A constructor to copy a dead entity. Will always have 0 health.
  **/
  Entity(Entity dying) {
    this.currentHp = 0;
    this.maxHp = 0;
    this.x = dying.x;
    this.y = dying.y;
    this.type = dying.type;
    this.size = 0;
  }
  
  void drawEntity() {
    pushMatrix();
    /* Draw the entity itself. Depends on the type of entity. The entities health is drawin within itself */
    noStroke();
    fill(100);
    float innerSize = size * (currentHp / maxHp);
    ellipseMode(CENTER);
    rectMode(CENTER);
    translate(x, y);
    if (type == 0) {  //TODO alter this
      strokeWeight(size / 10);
      stroke(100);
      noFill();
      ellipse(0, 0, size, size);
      stroke(col);
      ellipse(0, 0, innerSize, innerSize);
    }
    else if (type == 1) {
      ellipse(0, 0, size, size);
      fill(col);
      ellipse(0, 0, innerSize, innerSize);
    }
    else if (type == 2) {
      rotate(radians(45));
      strokeWeight(size / 10);
      stroke(100);
      noFill();
      rect(0, 0, size, size);
      stroke(col);
      rect(0, 0, innerSize, innerSize);
    }
    else if (type == 3) {
      rotate(radians(45));
      rect(0, 0, size, size);
      fill(col);
      rect(0, 0, innerSize, innerSize);
    }
    popMatrix();
  }
  
  /**
  * Deals damage to the entity. Returns true if entity is still alive, and false if not.
  **/
  boolean damage(float damage) {
   this.currentHp -= damage; 
   if (currentHp > 0) return true;
   return false;
  }
  
  /**
  * Moves the entity closer to the next point. If the next point is reached, it moves to the next one.
  * Will return true if the point has been moved, and false if it has reached the end and cannot be moved
  **/
  boolean move() {
    if (frameCount >= waveStartFrame + (startGap * num)) {
      if (this.x <= -width) {
       this.x = nextPoint.x * TILE_SIZE + HALF_TILE;
       this.y = nextPoint.y * TILE_SIZE + HALF_TILE;
      }
      int tempX = adjustedX(), tempY = adjustedY();
      
      if (endReached) {
       return true;  //End is reached, nothing else must be done. 
      }
      if (tempX == 0 && tempY == 0) {
        if (path.points.length > this.nextPointIndex + 1) {
          this.nextPointIndex++;
          this.nextPoint = path.points[nextPointIndex];
        }
        else if (endReached == false) {
          game.currentBaseHp -= 100;
          endReached = true;
         return false;  //The end has been reached 
        }
      }
      else {
       this.x += tempX;
       this.y += tempY;
      }
    }
    
    return true;
  }
  
  /**
  * Adjusts the x to move towards the next point
  **/
  int adjustedX() {
    if (this.x != nextPoint.cartX) {
     if (nextPoint.cartX < this.x) return -1;
     else return 1;
   }
   return 0;
  }
  
  /**
  * Adjusts the y to move towards the next point
  **/
  int adjustedY() {
   if (this.y != nextPoint.cartY) {
     if (nextPoint.cartY < this.y) return -1;
     else return 1;
   }
   return 0;
  }
  
  /**
  * Basic contains method for entitity. Checks if point is within entity.
  **/
  boolean contains(int x, int y) {
   if (dist(x, y, this.x, this.y) < this.size / 2) {
    return true; 
   }
   return false;
  }
}


/**
* A class to draw a dying entity. This entity type cannot move, and simply draws an animation for death.
**/
class DyingEntity extends Entity {
  int maxSize;
  boolean growing = true;
  
  DyingEntity(Entity dying) {
    super(dying);
    this.maxSize = TILE_SIZE;
  }
  
  /**
  * Draw the dying entity. The size of its drawing will change over time
  **/
  void drawEntity() {
    if (growing == false || !(growing && size == -1)) {
      fill(255, 0, 0, 90);
      noStroke();
      ellipse(x, y, size, size);
      ellipse(x, y, size/1.5, size/1.5);
      ellipse(x, y, size/3, size/3);
      if (size <= maxSize && growing) {
        size += 2;
      }
      else if (size >= maxSize) {
       size -= 2;
       growing = false;
      }
      else if (size > 0 && !growing) 
        size -= 2;
      else {
        size = -1;
        growing = true; 
      }
    }
  }
  
  /**
  * Dead entities cannot move, so the move method is overriden and will always return false.
  **/
  boolean move() {
    return false;
  }
  
  /**
  * A dead entity will never contain a point.
  **/
  boolean contains(int x, int y) {
    return false;
  }
  
  /**
  * A dead entity cannot die once more, so return true so that the entity does not update.
  **/
  boolean damage(float damage) {
   return true; 
  }
}