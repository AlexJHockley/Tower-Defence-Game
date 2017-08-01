  /* ================================================================================== */
 /*  This tab contains all classes for different USER INTERFACE, which has many types. */  
/* ================================================================================== */


abstract class UIElement {
  int x, y;
  int popupX, popupY;
  int popupSize;
  int size;
  boolean clicked = false;  //IF the element is clicked or not
  boolean hovered = false;  //If the mouse is hovering over this UI or not
  color col = color(59, 135, 255);
  
  UIElement(int x, int y, int size) {
   this.x = x;
   this.y = y;
   this.size = size;
  }
  
   /**
  * Draw the UI element itself. Will be transparent when not hovered or selected.
  **/
  abstract void drawElement();
  
  
  /**
  * Draw the popup for this UI element. Not all UI elements have popups, and the ones that do use it to show extra info.
  **/
  abstract void drawPopup(); 
  
  
  void move(int x, int y) {
   this.x = x;
   this.y = y;
  }
  
  abstract void movePopup();
  
  abstract boolean contains(int x, int y);
  
}




/**
* A UI element for the currently selected unit. Displays all the information about said unit.
**/
class UnitElement extends UIElement {
  Turret turr;
  Entity enem;
  int halfSize;  //This value is half the width of the element, used for the popup. It is a field to reduce computation
  
  UnitElement() {
    super(width / 10, width / 10, round(width / 5));
    
    this.halfSize = round(size / 2.0);
    this.popupSize = halfSize;
    movePopup();  //Use move popup to adjust the popup position
  }
  
  UnitElement(Entity e) {
    super(width / 10, width / 10, round(width / 5));
    this.enem = e;
    
    this.halfSize = round(size / 2.0);
    this.popupSize = halfSize;
    movePopup();
  }
  
  void drawElement() {
    noStroke();
    if (turr != null || enem != null || clicked)   //If hovered or clicked, fill in darker. Else use high transparency
      fill(col, 128);  
    else 
     return;  //No need to draw if nothing selected
    
    ellipse(x, y, size, size);
    
    
    
    if (turr != null || enem != null) {  //If this element is hovered or clicked, draw its popup
     drawPopup(); 
    }
    pushMatrix();
    
    if (turr != null) {
     translate(-turr.cartX, -turr.cartY);
     translate(this.x, this.y);
     turr.displayRange = false;
     turr.drawTurret();
     turr.displayRange = true;
    }
    else if (enem != null) {
     translate(-enem.x, -enem.y);
     translate(this.x, this.y);
     enem.drawEntity();
    }
    
    
    popMatrix();
  }
  
  void drawPopup() {
    ellipse(popupX, popupY, popupSize, popupSize);
    
    textAlign(CENTER);
    if (turr != null) {
       float fontSize = this.popupSize / 8;
       textSize(fontSize);
       fill(turr.col);
       //Display all turret info
       text("Type: " + turr.getType(), popupX, popupY - (fontSize * 2));
       text("Damage: " + turr.damage, popupX, popupY - (fontSize));
       text("Turnrate: " + turr.turnRate, popupX, popupY);
       text("Reload: " + (String.format("%.2fs", turr.reloadTimeFrames / 60)), popupX, popupY + (fontSize));
       text("Range: " + (int)turr.range, popupX, popupY + (fontSize * 2));
    }
    else if (enem != null) {
       float fontSize = this.popupSize / 7;
       textSize(fontSize);
       fill(enem.col);
       //Display all turret info
       text("Type: " + enem.type, popupX, popupY - (fontSize / 2));
       text("Health:\n" + (int)enem.currentHp + "/" + (int)enem.maxHp, popupX, popupY + (fontSize / 2));
    }
  }
  
  void movePopup() {
   this.popupX = this.x +  halfSize + (halfSize / 2);
   this.popupY = this.y - (halfSize / 2);
  }
  
  //This contains method only checks the primary box, and not the popup one.
  boolean contains(int x, int y) {
   if(dist(this.x, this.y, x, y) <= size / 2) 
     return true;
   return false;
  }
  
}



///**
//* A UI element for the game controls. These are the play/pause commands, the next wave command, and the new game command.
//* This control element class is also used for the primary game information element, which displays useful data to the user.
//**/
class ControlElement extends UIElement {
  String job = "";  //A string stating the particular job of this element. Dictates which button it represents.
  
  ControlElement(String job) {
    super(0, 0, width / 10);
    if (job.equals("pause")) { 
      this.x = width / 3; 
      this.y = height - (size / 2);
    }
    else if (job.equals("nextWave")) { 
      this.x = width / 3 + size; 
      this.y = height - (size / 2);
    }
    else if (job.equals("newGame")) { 
      this.x = width / 3 + size + size; 
      this.y = height - (size / 2);
    }
    else if (job.equals("information")) {
     this.size = width / 5;
     this.x = size / 2;
     this.y = height - (size / 2);
    }
    
    this.job = job; 
  }
  
  void drawElement() {
    noStroke();
    if (hovered || job.equals("information")) {   //If hovered or clicked, fill in darker. Else use high transparency. The information element is always visible however
      fill(col, 128);
      ellipse(this.x, this.y, this.size, this.size);
      stroke(0, 200);
    }
    else {
     fill(col, 20);
     ellipse(this.x, this.y, this.size, this.size);
     stroke(0, 20);
    }
    strokeWeight(width / 100);
    
    float quarterSize = this.size / 4;
    float eighthSize = this.size / 8;
    
    //If this is a play/pauyse button, draw it as such
    if (job.equals("pause")) {
      this.drawPlayPause(quarterSize, eighthSize);
    }
    else if (job.equals("nextWave")) {
     this.drawNextWave(quarterSize, eighthSize);
    }
    else if (job.equals("newGame")) {
     this.drawNewGame(quarterSize * 2, eighthSize);
    }
    else if (job.equals("information")) {
     this.drawInformation(quarterSize, eighthSize); 
    }
  }  
  
  void drawInformation(float quarterSize, float eighthSize) {
    //Draw all of the text
   float fontSize = size /  10;
   int textX = round(x + eighthSize - (fontSize / 3));
   textAlign(CENTER);
   textSize(fontSize);
   fill(255, 255, 0);
   text("Credits: " + game.currentCoins, textX, y - (fontSize * 2));
   fill(50, 255, 50);
   text("Base HP: " + (int)((game.currentBaseHp / game.maxBaseHp) * 100) + "%", textX, y);
   fill(255, 0, 0);
   text("Wave: " + game.currentWave + "/" + game.maxWaves, textX, y + (fontSize * 2));
   
  }
  
  void drawNextWave(float quarterSize, float eighthSize) {
    line(this.x - quarterSize, y, x + quarterSize, y);
    line(this.x + quarterSize, y, x, y - eighthSize);
    line(this.x + quarterSize, y, x, y + eighthSize);
  }
  
  void drawNewGame(float quarterSize, float eighthSize) {
    noFill();
    arc(x, y, quarterSize, quarterSize, 0, PI * 1.5);
    ellipse(x + (quarterSize / 2), y, eighthSize, eighthSize);
  }
  
  void drawPlayPause(float quarterSize, float eighthSize) {
   if (paused == false) {
        line(this.x - eighthSize, this.y - quarterSize, this.x - eighthSize, this.y + quarterSize);
        line(this.x + eighthSize, this.y - quarterSize, this.x + eighthSize, this.y + quarterSize);
      }
      else {
        noFill();
        beginShape();
        vertex(this.x - quarterSize, this.y - quarterSize);
        vertex(this.x + quarterSize, this.y);
        vertex(this.x - quarterSize, this.y + quarterSize);
        endShape(CLOSE);
      } 
  }
  
  /**
  * Performs the task that this button is made for
  */
  void performTask() {
    if (job.equals("pause")) {
      paused = !paused;
      waveStartFrame = frameCount -  waveStartFrame;
      for (Turret t: turrets) {
       t.lastFired = frameCount - t.lastFired;
      }
    }
    else if (job.equals("nextWave")) {  //Check if next wave can be played and do so if it can
     if (game.waveOver() && game.currentWave != game.maxWaves) {
      game.currentWave++;
      waveStartFrame = frameCount;
      loadWaveEnemies();
     }
    }
    else if (job.equals("newGame")) {
     if (gameWon == true && !gameOver()) {
       gameWon = false;  //New game before game won, so game was not won
       println("nah"); 
     }
     startGame(); 
    }
  }
  
  //There are no popups for control elements
  void drawPopup() {}
  
  //There is no popup for this, so a popup cannot be moved
  void movePopup() {}
  
  //This contains method only checks the primary box, and not the popup one.
  boolean contains(int x, int y) {
   if(dist(this.x, this.y, x, y) <= size / 2) 
     return true;
   return false;
  }
}








class TurretElement extends UIElement {
  TurretMG turrMG = null;
  TurretCannon turrCann = null;
  
  Tile source;
  
  Turret currentTurr;
  int buttonNum;
  
  TurretElement(int x, int y, int num, Tile source) {
    super(x, y, turrElemSize);
    this.source = source;
    
    if (source.turr == null) {
      if (num == 0) {  //Check which type of turret we are storing
        this.turrMG = new TurretMG(0, 0);
        this.turrMG.cartX = x;
        this.turrMG.cartY = y;
      }
      else if (num == 1) {
        this.turrCann = new TurretCannon(0, 0);
        this.turrCann.cartX = x;
        this.turrCann.cartY = y;
      }
    }
    else {
     this.currentTurr = source.turr; 
    }
    
    this.buttonNum = num;
    
    this.popupX = x;
    this.popupY = y + size;
    this.popupSize = round(size / 1.5);
  }
  
  void performTask() {
    if (currentTurr == null) {
      if (buttonNum == 0 && game.canAfford(game.getTurretCost(new TurretMG(0,0)))) {  //Check if the turret can be placed and afforded
        if (source.placeTurret(new TurretMG(source.gridX, source.gridY))) {  //Place the turret
          game.purchaseItem(game.getTurretCost(source.turr));  //Take away the money for the turret
          elements[5] = null;
          elements[6] = null;
        }
      }
      else if (buttonNum == 1 && game.canAfford(game.getTurretCost(new TurretCannon(0,0)))) {  
        if (source.placeTurret(new TurretCannon(source.gridX, source.gridY))) {
          game.purchaseItem(game.getTurretCost(source.turr));
          elements[5] = null;
          elements[6] = null;
        }
        
      }
    }
    else {
     if (buttonNum == 0 && game.canAfford(game.getUpgradeCost(currentTurr))) {
       game.purchaseItem(game.getUpgradeCost(currentTurr));
       currentTurr.upgradeTurret(); 
     }
     else if (buttonNum == 1) {
      game.sellTurret(source.turr);
      turrets.remove(source.turr);
      source.turr = null;
      elements[5] = null;
      elements[6] = null;
     }
    }
  }
  
  void drawElement() {
     if (hovered) {
       fill(col, 128);
       strokeWeight(size / 20);
       stroke(0);
       noStroke();
       this.drawPopup();
     }
     else {
       noStroke();
       fill(col, 64);
     }
     
     ellipse(this.x, this.y, this.size, this.size);
     
     //If there is a current turret, then display a sell and an upgrade button
     textAlign(CENTER);
     textSize(this.size / 6);
     fill(0);
     if (currentTurr != null) {
       if (buttonNum == 0) 
         text("Upgrade", this.x, this.y);
       else if (buttonNum == 1)
         text("Sell", this.x, this.y);
       
     }
     else {  //Otherwise, draw example turret
         if (turrMG != null)
           turrMG.drawTurret();
         else if (turrCann != null)
           turrCann.drawTurret();
     }
  }
  
  void drawPopup() {
    ellipse(this.popupX, this.popupY, this.popupSize, this.popupSize);
    float fontSize = popupSize / 8;
    textSize(fontSize);
    Turret temp = null;
    fill(0);
    if (currentTurr != null) {
      if (buttonNum == 0) {
        text("Cost: " + game.getUpgradeCost(currentTurr), popupX, popupY);
      }
      else if (buttonNum == 1) {
        text("Sell Price: " + (game.getTurretCost(currentTurr) / 2), popupX, popupY);
      }
      fill(col, 255);
      return;
    }
    else if (turrMG != null) temp = turrMG;
    else if (turrCann != null) temp = turrCann;
    if (temp == null) return;
    text("Cost: " + game.getTurretCost(temp), popupX, popupY - (fontSize * 2));
    text("Type: " + temp.getType(), popupX, popupY - (fontSize));
    text("Damage: " + temp.damage, popupX, popupY);
    text("Reload: " + (String.format("%.2fs", temp.reloadTimeFrames / 60)), popupX, popupY + (fontSize));
    text("Range: " + (int)temp.range, popupX, popupY + (fontSize * 2));
    fill(col, 255);
  }
  
  void move(int x, int y) { 
  }
  
  /**
  * Moves the popup. For this window, it also moves the second button window. Will also move the turret objects.
  */
  void movePopup() {}
  
  boolean contains(int x, int y) {
    if (dist(x, y, this.x, this.y) <= size / 2) {
     return true; 
    }
    return false;
  }
  
}