/* Tab Key: 
  C = Class, will contain a single large class
  CM = Class Multiple, will contain many related classes
  No tag = Will contain methods relating to the tab name
  FIELDS = contains all of the global fields
*/

/**
* Sarts the game and sets the window size.
**/
void setup() {
  size(700, 700);
  frameRate(60);  //Framerate starts at 60
  turrElemOneX = round(width / 2 + (width / 12));
  turrElemOneY = round(width / 6);
  turrElemTwoX = round(width / 2 - (width / 12));
  turrElemTwoY = turrElemOneY;
  turrElemSize = turrElemOneY;
  
  startScreen = loadImage("startScreen.png");
  tutorialScreen = loadImage("tutorialScreen.png");
  startGame();
}

/*====* STANDARD GAME METHODS *====*/

/**
* Calls all methods for draw and frame-by-frame calculations.
**/
void draw() {
  if (!displayStart && !displayTutorial) {  //If the game is not over
    if (paused == false) {  //Only draw these things if the game is not paused
      background(0);  //Clear the old screen every time
      //Draw the map
      map.drawMap();
      
      if (debug) {  //We are debugging, draw what it has to show
       drawDebug(); 
      }
      //Draw the turrets on the map
      drawTurrets();
      //Draw the entities on the map
      drawEnemies();
      //Draw the bullets fired by the turrets
      drawBullets();
      //Draw the UI elements onto the screen
      drawUI();
    }
  }
  if (gameOver() && !(displayStart || displayTutorial)) {  //Game is over, inform the user
    fill(255, 255, 20);
    float size = width / 6;
    textSize(size);
    textAlign(CENTER); 
      
    if (game.currentBaseHp > 0) {  //if the base is still alive, game was won. Otherwise it was lost.
      text("Game Won!", width / 2, height / 2);
      textSize(size / 3);
      if (mapNum == maxMap) {
       text("You have beaten the whole game!", width / 2, height / 2 + size);
       text("Click anywhere to start again!",  width / 2, height / 2 + size + size);
      }
      else {
        text("Click anywhere to play next map!", width / 2, height / 2 + size);
      }
      gameWon = true;
    }
    else  {
      text("Game Lost!", width / 2, height / 2);
      textSize(size / 3);
      text("Click anywhere to play again!", width / 2, height / 2 + size);
      gameWon = false;
    }
  }
  
  
  if (displayStart) {
    fill(255, 255, 20, 100);
    textSize(width / 6);
    textAlign(CENTER);
    text("Click to view the tutorial!", width / 2, height / 2);
   image(startScreen, 0, 0, width, height);
  }
  else if (displayTutorial) {
   text("Click again to play the game!", width / 2, height / 2);
   image(tutorialScreen, 0, 0, width, height);
  }
  else {
    pause.drawElement();  //The pause element needs to be drawn seperately, so that the user always knows where it is. 
  }
}


/**
* Checks if the game is over.
**/
boolean gameOver() {
 if (game.currentBaseHp <= 0) {
  return true; 
 }
 else if (game.currentWave == game.maxWaves && game.waveOver()) {
  return true; 
 }
 return false;
}

/*====* DRAW METHODS *====*/

/**
* Draws all of the turrets on top of the tiles. ALso performs all logic checks for turret at same time.
**/
void drawTurrets() {
 for (Turret t : turrets) {
   if (t.targetStillValid() == false && currentEnemies != null)
     t.selectTarget(currentEnemies);  //Current target is no longer valid, find another one
     
   if (t.target != null)
     bullets.add(t.shoot());  //There is a target available, shoot at it!
     
   t.drawTurret();   //Draw the turret now, all is well.
 }
}

/**
* Draws all of the enemies on the map. Also moves all the enemies
**/
void drawEnemies() {
 if (currentEnemies == null) return;
 for (Entity e : currentEnemies) {
  e.drawEntity(); 
  e.move();
 }
}

/**
* Draws all of the UI elements
**/
void drawUI() {
 for (UIElement u : elements) {
  if (u != null && u != pause) //Null elements and the pause element should not be drawn in this loop
    u.drawElement();
 }
}

/**
* Draws all of the bullets. Also checks for collissions
**/
void drawBullets() {
 Bullet b;
 for (int i = 0; i < bullets.size(); i++) {
   b = bullets.get(i);
   if (b != null) { //Check there is a bullet to draw
     b.drawBullet();
     
     if (b.outOfBounds()) {  //Bullet has gone off the map, remove it
      bullets.remove(i);
      i--;
     }
     else {  //Bullet is still on map
       b.drawBullet();  //Draw the bullet, now check if its hit any enemies. Drawing before check helps with fluidity of game.
       
       Entity e;
       for (int j = 0; j < currentEnemies.length; j++) {
         e = currentEnemies[j];
         if (b.targetHit(e)) {  //Target has been hit
          if (e.damage(b.damage) == false) {  //Enemy has been killed, make it a dying entity
            game.unitKillPay(e);
            currentEnemies[j] = new DyingEntity(e);
          }
          bullets.remove(i);  //Target hit, remove it
          i--;
         }
       }
     }
   }
 }
}

/**
* Draws an FPS counter and the pathing for units
**/
void drawDebug() {
 path.drawPoints();
 fill(255, 255, 0);
 textSize(height / 80);
 text("FPS: " + int(frameRate), width / 50, HALF_TILE);
}


/*====* CONTROL METHODS *====*/

/* Mouse Controls */

/**
* Checks if the mouse is hovering over any UI's or turrets
**/
void mouseMoved() {
 for (UIElement e : elements) {  //Check UI first as its the top layer
   if (e != null)
     if (e.contains(mouseX, mouseY))
       e.hovered = true;  //Set hovered to true as mouse is above it
     else
       e.hovered = false;
 }
 for (Turret t : turrets) {  //Check all the turrets
  if (t.contains(mouseX, mouseY)) //Turret is hovered, display its range
    t.displayRange = true; 
  else if (t.clicked == false)  //Turret no longer hovered, do not display range
    t.displayRange = false;
 }
}

/**
* Mouse has been dragged, move any necessary UI parts with it
**/
void mouseDragged() {
  if (displayStart || displayTutorial) return;  //Can't alter game board before start
  if (mouseButton != RIGHT) return;  //Can only drag with right mouyse button
  for (UIElement e : elements) {
   if (e != null && e.clicked) {
     e.move(mouseX, mouseY);
     e.movePopup();
   }
  }
}

/**
* Checks if anything was clicked when the mouse was pressed
**/
void mousePressed() {
  if (displayStart == true && frameCount > 5) {
    displayStart = false;
    return;
  }
  else if (displayTutorial == true) {
   displayTutorial = false;
   return;
  }
  else if (gameOver() == true) {
    ControlElement newGame = (ControlElement)elements[3];
    newGame.performTask();
  }
  int clickedX = mouseX, clickedY = mouseY;  //Record where the click occured, to avoid bugs due to lag
  //Check all the UI elements first
  if (checkClickedUI(clickedX, clickedY)) {
    return; 
  }
  
  //Now check all the turret elements
  boolean turrFound = checkClickedTurret(clickedX, clickedY);
  
  //Check all the entitys
  if (checkedClickedEntity(clickedX, clickedY, turrFound) == true) 
    return;  //Entity was found, return
  
  //Check all the tiles
  checkClickedTile(clickedX, clickedY);
}

/**
* Check for clicked UI, perform any actions necessary
**/
boolean checkClickedUI(int clickedX, int clickedY) {
  for (UIElement e : elements) {  //All elements must be cleared of a click beforehand
   if (e != null) e.clicked = false; 
  }
  for (UIElement e : elements) {
    if (e != null) {
     if (e.contains(clickedX, clickedY)) {  //UI was pressed
       e.clicked = true;
       if (e instanceof ControlElement && mouseButton == LEFT) {  //Control elements can only be left clicked, as right click drags
         ControlElement cE = (ControlElement)e;
         cE.performTask();  //Do the job the control element was made to do
       }
       else if (e instanceof TurretElement) {  //Turret elements can be left or right clicked as they dont move
         TurretElement tE = (TurretElement)e;
         tE.performTask();
       }
       return true;  //An element was clicked, nothing else must be checked
     }
     else {
      e.clicked = false;  //this element was not clicked on 
     }
    }
  }  
  return false;
}

/**
* Check for clicked Turret, perform any actions necessary
**/
boolean checkClickedTurret(int clickedX, int clickedY) {
  Turret found = null;  //The turret that has been clicked
  for (Turret t: turrets) {
    if (t.contains(clickedX, clickedY)) {
     found = t;
     t.displayRange = true;
     t.clicked = true;
    }
    else {
     t.displayRange = false;
     t.clicked = false;
    }
  }
  UnitElement uE = (UnitElement)elements[0];  //Cast the unit element to its type
  uE.turr = found;  //The unit element now contains this turret
  elements[0] = uE;  //Set the unit element back
  
  return found != null;
}

/**
* Check for clicked Entity, perform any actions necessary
**/
boolean checkedClickedEntity(int clickedX, int clickedY, boolean found) {
  UnitElement uE = (UnitElement)elements[0];
  if (currentEnemies == null || currentEnemies.length <= 0) return false;  //There are no current enemies, return
  for (Entity en : currentEnemies) {
   if (en.contains(clickedX, clickedY)) {
    uE.enem = en;  //The unit element now contains this enemy
    elements[0] = uE;  //Set the unit element back
    elements[5] = null;  //There is a new selected unit, no longer need to show the purchase HUD
    elements[6] = null;
    return true;  //Enemy found, return
   }
  
  }
  uE.enem = null;  //There is no unit found, the interface should reflect this
  elements[0] = uE;  //Set the unit element back
  
  if (found) {  //Something was found, there should be no purchase UI
      elements[5] = null;
      elements[6] = null;
  } 
  return false;
}

/**
* Check for clicked Tile, perform any actions necessary
**/
void checkClickedTile(int clickedX, int clickedY) {
   Tile[][] tiles = map.tiles;
   Tile t;
   boolean found = false;
   for (int row = 0; row < map.rows; row++) {
    for (int col = 0; col < map.cols; col++) {
      t = tiles[col][row];
      
      if (found == false && t.contains(clickedX, clickedY)) {  //Tile was clicked
        found = true;
        if (t.type == 0) {
         t.clicked = true;
         if (t.turr != null) {  //If there is no current turret, show a purchase menu
           if (t.turr.level < 2)
             elements[5] = new TurretElement(turrElemOneX, turrElemOneY, 0, t);
             elements[6] = new TurretElement(turrElemTwoX, turrElemTwoY, 1, t);
         }
         else {  //Otherwise allow the upgrading or selling of items
           elements[5] = new TurretElement(turrElemOneX, turrElemTwoY, 0, t);
             elements[6] = new TurretElement(turrElemTwoX, turrElemTwoY, 1, t);
         }
        }
        else {  //Tile type was not valid, remove their UI elements
          elements[5] = null;
          elements[6] = null;
        }
      }
      else {
        t.clicked = false;
      }
    }
   }
}

/* KEYBOARD CONTROLS */
void keyPressed() {
 if (keyCode == ALT) {
  debug = !debug; 
 }
 else if (keyCode == SHIFT) {
  borders = ! borders; 
 }
 else if (keyCode == ENTER) {
  save("Screenshot" + (int)random(0, 100) + ".png");
 }
 else if (keyCode == CONTROL) {
   loadUI();
 }
 else if (keyCode == RIGHT) {
  if (frames == 120) frames = 240;
  else frames = 120;
  frameRate(frames);
 }
 else if (keyCode == LEFT) {
  if (frames >= 60) frames = 30;
  else frames = 10;
  frameRate(frames);
 }
 else if (keyCode == UP) {
  frames = 60;
  frameRate(frames);
 }
  
  
}