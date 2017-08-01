   /* ================================================================================ */
  /*  This tab contains all classes relating to the MAP. This includes the PARSING    */
 /*    of maps from files, drawing of the map, TILES, etc.                           */    
/* ================================================================================ */


/**
* The map class defines a 2d array of tiles. Everything happens on top of the map,
* and as such it is drawn first. The map will load itself from a file using a 
* parser. Does not have a constructor as one is not necessary for this class.
**/
class Map {
  Tile[][] tiles;  //The 2d array of tiles representing the board
  int rows, cols;  //How many rows and columns of tiles there are
  Tile endTile, startTile;  //The start and end tiles dictate where entities enter and exit the map
  
  
  /**
  * Draws all the tiles on the map to display it.
  **/
  void drawMap() {
    rectMode(CORNER);  //All tiles are drawn from the top left corner
    for (int col = 0; col < cols; col++) {  //Loop through all the tiles and draw them
     for (int row = 0; row < rows; row++) {
      tiles[col][row].drawTile(); 
     }
    }
  }
  
  /* MAP PARSER CODE BELOW THIS POINT */
  
  /**
  * Reads the line and returns the index of the comma within it. Returns -1 if none found
  **/
  int getCommaPoint(String line) {
    char[] info = line.toCharArray();
    for (int i = 0; i < info.length; i++) {
     if (info[i] == ',')
       return i;
    }
    return -1;
  }
  
  /**
  * Reads from a specified file to load in a map to the game.
  */
  void parseMap(String fileName) {
    BufferedReader scan = createReader(fileName + ".txt");  //Create a scanner with the file
    try {  //Attempt to read the file
      String line = scan.readLine();  //Read the line about the size of the array
      char[] info = line.toCharArray();
      int index = getCommaPoint(line);
      
      if (index == -1)   //The comma was not found, the file is broken, throw an error.
        throw new RuntimeException("Invalid map size specification: " + line);  
      
      cols = parseInt(line.substring(1, index));  //The rows and columns are defined at the top, read them and build an array with them
      rows = parseInt(line.substring(index + 1, line.length() - 1));
      
      line = scan.readLine();
      index = getCommaPoint(line);
      int startTileCol = parseInt(line.substring(1, index));
      int startTileRow = parseInt(line.substring(index + 1, line.length() - 1));
      
      line = scan.readLine();
      index = getCommaPoint(line);
      int endTileCol = parseInt(line.substring(1, index));
      int endTileRow = parseInt(line.substring(index + 1, line.length() - 1));
      
      //Tile size can now be set
      TILE_SIZE = round(float(WIDTH) / float(cols));
      
      tiles = new Tile[cols][rows];
      if (cols == 0) return;
      int row = 0;
      
      while ((line = scan.readLine()) != null) {
       line = line.replaceAll("\\,", "");  //Clear the extra chars from the line
       line = line.replaceAll("\\[", "");
       line = line.replaceAll("\\]", "");
       info = line.toCharArray();  //Turn the array into chars to read
       
       for (int col = 0; col < cols; col++) {  //Read over the line and fill a row with the information from it
        tiles[col][row] = new Tile(col, row, Character.getNumericValue(info[col]), rows, cols);   //Make a new tile, after converting the character to a number to use
       }
       row++;  //Increment the row count as the next line is going to be read
      }
      
      startTile = tiles[startTileCol][startTileRow];
      endTile = tiles[endTileCol][endTileRow];
   } 
   catch (IOException e) {  //Error encountered, inform the user and print the message
    throw new RuntimeException("Invalid map file! " + e.getMessage());
   }
  }
}




/**
*  The tile class represents a single tile from the map. Its type defines its purpose (0 represents a wall, 1
*  represents a path for enemies). The type also defines its colour.
**/
class Tile {
  int gridX, gridY;
  int type;
  float cartX, cartY;
  int arrowDirection = -1;  //The direction the arrow points, assuming that there is one
  Turret turr;
  boolean clicked = false;
  
  Tile(int col, int row, int type, int rows, int cols) {
    this.gridX = col;
    this.gridY = row;
    this.type = type;
     
    updatePlacement();  //Reusing the update placement method here, as it sets the cartX and cartY fields
    
    if (type == 2 || type == 3)  //If this tile needs an arrow, set it up
      directArrow(rows, cols); 
      
  }
  
  /**
  * Updates the placement (cartesian x and y) of the tile based on the current TILE_SIZE field value.
  **/
  void updatePlacement() {
    this.cartX = TILE_SIZE * this.gridX;
    this.cartY = TILE_SIZE * this.gridY;
  }
  
  /**
  *  Draw this tile. The colour is based on the tile type.
  **/
  void drawTile() {
    if (debug) {  //If the game is in debug mode, outline the tiles. Otherwise use no stroke
     strokeWeight(1);
     stroke(255);
    }
    else {
     noStroke();
    }
    
    //Check which type of tile this is, and assign an appropriate colour
    if (clicked)
      fill(80, 80, 80);
    else if (type == 0) 
      fill(120);
    else if (type == 1) 
     fill(180, 230, 30); 
    else if (type == 2) 
     fill(54, 124, 234); 
    else if (type == 3) 
     fill(179, 27, 5); 
    else
      fill(0);
    //Draw the tile
    rect(this.cartX, this.cartY, TILE_SIZE, TILE_SIZE);
    
    if (arrowDirection != -1) drawArrow();

    
    if (debug) {
     fill(0);
     text("(" + gridX + ", " + gridY + ")", cartX + (TILE_SIZE / 10), cartY + (TILE_SIZE / 5));
    } 
  }
  
  boolean placeTurret(Turret newTurr) {
   if (this.type == 0 && turr == null) {
    this.turr = newTurr; 
    turrets.add(newTurr);
    return true;
   }
   return false;
  }
  
  /**
  * Draws an arrow on the tile facing a specified direction.
  **/
  void drawArrow() {
   pushMatrix();
   strokeWeight(WIDTH / 100);
   stroke(0);
   int angle = 0;
   if (arrowDirection == 0) 
     angle = -90;
   else if (arrowDirection == 2)
     angle = 90;
   else if (arrowDirection == 3) 
     angle = 180;
   
   if (type == 3)
     angle = angle + 180;
   
   translate(cartX + HALF_TILE, cartY + HALF_TILE);
   rotate(radians(angle));
   
   float x1 = (TILE_SIZE / 5.0);
   float quarterTile = (TILE_SIZE / 4.0);
   beginShape();
   vertex(-x1 , -quarterTile);
   vertex(x1, 0);
   vertex(-x1, quarterTile);
   endShape(CLOSE);
   popMatrix();
  }
  
  /**
  * Works out the direction the arrow needs to go. Given the start and end tiles are always on the edge of the game, it decides based on which side it is adjacent to.
  **/
  void directArrow(int rows, int cols) {
    if (gridY == rows - 1) arrowDirection = 0;  //Face arrow north
    else if (cartX <= 0) arrowDirection = 1;  //Face arrow east
    else if (cartY <= 0) arrowDirection = 2;  //Face arrow south
    else if (gridX == cols - 1) arrowDirection = 3;  //Face arrow west
  }
  
  /**
  * Check if a point is within this tile. Used for clicking.
  **/
  boolean contains(int x, int y) {
   if (x >= this.cartX && y >= this.cartY && x <= (this.cartX + TILE_SIZE) 
       && y <= (this.cartY + TILE_SIZE))
         return true;
   return false;
  }
}