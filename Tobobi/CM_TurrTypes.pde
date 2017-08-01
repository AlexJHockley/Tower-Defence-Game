  /* ========================================================================================== */
 /*  This tab contains all classes for different TURRET TYPES, such as machine gun and cannon. */  
/* ========================================================================================== */


/**
* The machine gun turret. Fires rapidly with low range but high DPS. Appears on the top
* down view as a base with a single line coming out from the centre as the barrel.
*/
class TurretMG extends Turret {
  
  TurretMG(int gX, int gY) {
   super(gX, gY, 0);  //Call the super constructor, which will define almost all of the necessary information
  }
  
  void drawBarrel(float divide) {
    float adjustDivide = 2.3;
    float barLength = TILE_SIZE / adjustDivide;
    if (borders) {
      strokeWeight(TILE_SIZE / divide);  //Set the width then the colour for border
      stroke(0);
      
      line(0, 0, barLength, 0);
      stroke(col);
      strokeWeight(TILE_SIZE / divide / 1.2);
    }
    line(0, 0, barLength, 0);
  }
  
  /**
  * Fires the gun, if it has reloaded. Returns a bullet if it can fire, returns null if not.  
  */
  Bullet shoot() {
    float acceptableAngle = radians(10);
    if (target != null && angle == targetAngle || (angle >= targetAngle - acceptableAngle && angle <= targetAngle + acceptableAngle)) {
      if (frameCount - this.lastFired >= this.reloadTimeFrames && this.target != null) {  //Check if the gun can fire. If it can, update the last fired time, and do so.
        this.lastFired = frameCount;
        int randomFire = (int)target.size / 3;
        float randomizedAmount = (random(-randomFire, randomFire));
        float barrelLength = TILE_SIZE / 2.3;
        return new Bullet(this.damage, this.target.x + randomizedAmount, this.target.y + randomizedAmount, this.cartX + cos(-angle) * barrelLength, cartY - sin(-angle) * barrelLength, this.bulletVelo * 3, this.range - barrelLength);
      }
    }
    return null;  //The gun cannot fire, do not return a bullet.
  }
}





/**
* The cannon gun turret. Fires slow with high range and high damage. Appears on the top
* down view as a base with a triangle coming out from the centre as the barrel.
*/
class TurretCannon extends Turret {
  
  TurretCannon(int gX, int gY) {
   super(gX, gY, 1);  //Call the super constructor, which will define almost all of the necessary information
  }
  
  void drawBarrel(float divide) {
    float adjustDivide = 2.3;
    float barLength = TILE_SIZE / adjustDivide;
    float barAdj = TILE_SIZE / 7;
    if (borders) {
      strokeWeight(TILE_SIZE / divide);  //Set the width then the colour for border
      stroke(0);
      
      line(0, -barAdj, barLength, 0);
      line(0, barAdj, barLength, 0);
      stroke(col);
      strokeWeight(TILE_SIZE / divide / 1.2);
    }
    line(0, -barAdj, barLength, 0);
    line(0, barAdj, barLength, 0);
  }
  
  /**
  * Fires the gun, if it has reloaded. Returns a bullet if it can fire, returns null if not.  
  */
  Bullet shoot() {
    float acceptableAngle = radians(10);
    if (target != null && angle == targetAngle || (angle >= targetAngle - acceptableAngle && angle <= targetAngle + acceptableAngle)) {
      if (frameCount - this.lastFired >= this.reloadTimeFrames && this.target != null) {  //Check if the gun can fire. If it can, update the last fired time, and do so.
        this.lastFired = frameCount;
        int randomFire = (int)target.size;
        float randomizedAmount = (random(-randomFire, randomFire));
        float barrelLength = TILE_SIZE / 2.3;
        return new Bullet(this.damage, this.target.x + randomizedAmount, this.target.y + randomizedAmount, this.cartX + cos(-angle) * barrelLength, cartY - sin(-angle) * barrelLength, this.bulletVelo * 3, this.range - barrelLength);
      }
    }
    return null;  //The gun cannot fire, do not return a bullet.
  }
}