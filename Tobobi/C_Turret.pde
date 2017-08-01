  /* ============================================================================= */
 /*  This tab contains the TURRET ABSTRACT class, on which all turrets are based. */  
/* ============================================================================= */

/**
* The abstract class for the turrets. Stores a multitude of information and has many methods. 
**/
public abstract class Turret {
 private int gridX, gridY;  //The x and y values of 
 public float cartX, cartY;
 public color col;
 public float damage;
 public float reloadTimeFrames;
 private float turnRate;
 private int level;
 public int type;
 public float range;  //The range of the turret. Its's value is defined as "range * TILE_WIDTH", so that it represents a real value
 public Entity target;  //The target that this tower is focussing on. Will be none if there isnt one.
 public float angle, targetAngle;
 public float lastFired;
 public float bulletVelo;
 public boolean displayRange = false;
 public boolean clicked = false;
 
 Turret(int gridX, int gridY, int type) {
  float reloadTime = 10;  //Represents the realod time in seconds
  this.gridX = gridX;
  this.gridY = gridY;
  this.col = color(255, 200, 15);  //The level starts as 0, so the colour will represent this to start
  this.level = 0;
  this.type = type;
  if (type == 0) {  //If turret is a machine gun turret
    this.damage = 5;
    reloadTime = 0.5;
    this.turnRate = 0.05;
    this.range = 1.5 * TILE_SIZE;
    this.bulletVelo = TILE_SIZE * 0.03;
  }
  else if (type == 1) { //If turret is a cannon turret
    this.damage = 25;
    reloadTime = 2;
    this.turnRate = 0.025;
    this.range = 2.5 * TILE_SIZE;
    this.bulletVelo = TILE_SIZE * 0.05;
  }
  else if (type == 2) { //If turret is a slow turret
    this.damage = 0;
    reloadTime = 0.2;
    this.turnRate = 0.01;
    this.range = 2 * TILE_SIZE;
    this.bulletVelo = 3;
  }
  this.cartX = gridX * TILE_SIZE + HALF_TILE;
  this.cartY = gridY * TILE_SIZE + HALF_TILE;
  this.angle = 0;
  this.targetAngle = 360;
  this.reloadTimeFrames = 60 * reloadTime;  //Assume running at 60 fps
 }
 
 boolean contains(float targetX, float targetY) {
   if (dist(cartX, cartY, targetX, targetY) <= TURRET_SIZE) {
      return true;
   }
   return false;
 }
 
 void drawRange() {
  fill(0, 145, 150, 50);
  stroke(0);
  strokeWeight(width / 500);
  float rangeDisplay = this.range * 2;
  ellipse(cartX, cartY, rangeDisplay, rangeDisplay);
 }
 
 /**
 * Draws the turret. 
 */
 void drawTurret() {
   //The divide numbers specify how wide the border outline is
    float innerDivide = 10, outerDivide = 8.5;
    float innerCircleWidth = TURRET_SIZE / 2.25;
    
    if (displayRange) {
      this.drawRange();
    }
    pushMatrix();
    translate(cartX, cartY);
    noFill();
    /* Draw the two botton shapes */
    if (borders) {  //Check that the border needs to be drawn
      this.drawTurretBase(outerDivide, innerCircleWidth, 0);
    }
    this.drawTurretBase(innerDivide, innerCircleWidth, this.col);
    
    if (target != null) 
      this.calculateAngle(this.target.x, this.target.y, cartX, cartY);
      
    rotate(angle);
    /* Draw the gun barrel */
    this.drawBarrel(outerDivide);
    
    popMatrix();
 }
 
 /**
 * Get the type of this turret
 */
 int getType() {
   return this.type; 
 }
 
 /**
 * Upgrades the turret, if possible
 **/
 boolean upgradeTurret() {
   //TODO check for funds
   this.level++;
   
   if (level == 0) col = color(255, 200, 15);
   else if (level == 1) col = color(255, 110, 0);
   else if (level == 2) col = color(255, 50, 50);
   
   if (this.level > 2) {
    this.level = 2;
    return false;
   }
   
   this.range *= 1.3;
   this.damage *= 2;
   this.reloadTimeFrames /= 1.5;
   return true;
 }
 
 /**
 * Get the name of this turret type, used for drawing popups
 */ 
 String getTypeName() {
  if (type == 0) return "Machine Gun";
  else if (type == 1) return "Cannon";
  else return "Unknown";
 }
 
 /* The shooting methods depend on the type of turret, so they are not defined here */
 abstract Bullet shoot();
 
 /** Draws the barrel of this specific gun **/
 abstract void drawBarrel(float divide);
 
 /**
 * Get the grid based x co-ordinate
 */
 int getGridX() {
   return this.gridX; 
 }
 
 /**
 * Get the grid based x co-ordinate
 */
 int getLevel() {
   return this.level; 
 }
 
 /**
  * Returns the radians value radians value representing the angle the turret must turn to focus on the target point. The turrX and turrY are thte points of where the turret is centred
  */
  void calculateAngle(float targetX, float targetY, float turrX, float turrY) {
    this.targetAngle = atan2((targetY - turrY), (targetX - turrX));
    
    if (targetAngle < angle - PI) targetAngle = TWO_PI + targetAngle;
    if (targetAngle > angle + PI) targetAngle = targetAngle - TWO_PI;
    
    if (angle == targetAngle) return;
    
    if (targetAngle > angle) {
      angle += this.turnRate;
      if (angle > targetAngle) angle = targetAngle; 
    }
    else if (targetAngle < angle) {
      angle -= this.turnRate;
      if (angle < targetAngle) angle = targetAngle;
    }
  }
  
  /**
  * Checks if the current target is still valid
  **/
  boolean targetStillValid() {
   if (target == null || target.currentHp <= 0 || dist(target.x, target.y, this.cartX, this.cartY) > this.range) {
    return false; 
   }
   else if (target.x < 0 || target.x < 0 || target.x > WIDTH || target.y > HEIGHT)
     return false;
   return true;
  }
  
  /**
  * Finds a target within range and selects it
  **/
  void selectTarget(Entity[] selectables) {
    Entity target;
    for (int i = 0; i < selectables.length; i++) {
      target = selectables[i];
      if (dist(target.x, target.y, this.cartX, this.cartY) < range && target.currentHp > 0) {
        this.target = target;
        return;
      }
    }
    this.target = null;  //Target was not found, set to null
  }
  
  /**
  *  Draws the base of the turret (the two circles). The numerical values decide how wide the ellipse will be.
  */
  void drawTurretBase(float divide, float circleWidth, color stroke) {
      stroke(stroke);
      strokeWeight(TURRET_SIZE / divide);  //Set the width then the colour for border
      
      ellipse(0, 0, TURRET_SIZE, TURRET_SIZE);
      ellipse(0, 0, circleWidth, circleWidth);
   }
}