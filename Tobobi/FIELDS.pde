  /* ============================================================================== */
 /*  This tab contains all FIELDS from the MAIN class, seperated here for clarity. */  
/* ============================================================================== */

/* ------ Map Fields ------ */
Map map;
int HEIGHT;  //The game window width and height, used to define how big everything else is.
int WIDTH;
int ZERO_X;  //The x and y zero points of the map
int ZERO_Y;
int END_X;  //The end points of the map
int END_Y;
int mapNum = 1;
int maxMap = 10;


/* ------ Tile Fields ------ */
int TILE_SIZE;  //How wide and high the tiles are. For the 2D view, the tiles are always square (I.E: width == height)
int HALF_TILE;


/* ------ Pathing Fields ------ */
Pather path;


/* ------ Turret Fields ------ */
ArrayList<Turret> turrets;
float TURRET_SIZE;
ArrayList<Bullet> bullets;


/* ------ Entity Fields ------ */
int numEnemies = 0;
Entity[] currentEnemies;
int waveStartFrame = Integer.MAX_VALUE;


/* ------ Game Logic Fields ------ */
Game game;
boolean paused = false;
boolean gameWon = false;


/* ------ Display Fields ------ */
boolean borders = true;
int frames = 60;
boolean displayStart = true;
boolean displayTutorial = true;
PImage startScreen;
PImage tutorialScreen;
boolean drawOnce = false;


/* ------ User Interface Fields ------ */
UIElement[] elements;  //All of the UI elements on the screen
int turrElemOneX, turrElemOneY;
int turrElemTwoX, turrElemTwoY;
int turrElemSize;
int numElements = 9;

ControlElement pause;


/* ------ Debug Display Fields ------ */
boolean debug = false;
int FPS;
    // Pathing & Related
    //NOTE: To effectively do this, we would only want to initialise these when debug is turned on. To avoid re-initializing something that is already there, we would need a check for if they have been initialised already
int pointSize;
color pointColor = color(255, 0, 255);