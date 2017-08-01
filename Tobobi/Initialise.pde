  /* ============================================================================================== */
 /*  This tab contains all methods for starting and initialising the game and aspects of the game. */  
/* ============================================================================================== */


/**
* Call all game loading methods, thus starting the game entirely.
**/
void startGame() {
  HEIGHT = Math.round(height);
  WIDTH = Math.round(width);
  
  if (gameWon == true) 
    mapNum++;
  
  if (mapNum > maxMap)
    mapNum = 1;
  
  this.map = loadMap("map" + mapNum);
  
  loadValues();
  loadPather();
  loadGame();
  loadEnemies();
  loadUI();
}


/**
* Calls on the game class and sets all of the entitiy objects for the game waves.
**/
void loadWaveEnemies() {
  currentEnemies = game.getWaveEnemies(game.currentWave);
}

/**
* Loads and returns the map.
**/
Map loadMap(String fileName) {
  Map m = new Map();
  m.parseMap(fileName);
  return m;
}

/**
* Loads in the main fields.
**/
void loadValues() {
  //Load all the standard fields and initialise the arrays
  HALF_TILE = round(TILE_SIZE / 2.0);
  this.ZERO_X = 0;
  this.ZERO_Y = 0;
  this.END_X = ZERO_X + WIDTH;
  this.END_Y = ZERO_Y + HEIGHT;
  this.TURRET_SIZE = TILE_SIZE / 1.5;
  
  displayTutorial = true;
  
  currentEnemies = null;  //Restarted game will have no enemies
  turrets = new ArrayList<Turret>();
  bullets = new ArrayList<Bullet>();
}

/**
* Loads, generates, and sets the pather
**/
void loadPather() {
  this.path = new Pather(map);
  path.generatePath();
  pointSize = TILE_SIZE / 5; 
}

/**
* Loads the game object
**/
void loadGame() {
 this.game = new Game(mapNum * 3, 500, 1000); 
}

/**
* Loads the enemies into the game object
**/
void loadEnemies() {
 game.generateWaveEnems(); 
}

/**
* Loads the UI and all its objects
**/
void loadUI() {
  elements = new UIElement[numElements];
  
  pause = new ControlElement("pause");
  
  elements[0] = new UnitElement();
  elements[1] = pause;
  elements[2] = new ControlElement("nextWave");
  elements[3] = new ControlElement("newGame");
  elements[4] = new ControlElement("information");
}