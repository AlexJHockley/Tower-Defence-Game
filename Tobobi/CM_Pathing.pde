  /* =================================================================== */
 /*  This tab contains all classes relating to PATHING through the map. */  
/* =================================================================== */



/**
* A simple class for storing both an x and y value. The point can also be drawn as a rectangle, 
* to help with viewing the pathing of entities.
*/
class Point {
 int x, y;  //The position of this point
 int cartX, cartY;
 
 Point(int x, int y) {
   //Initialise the fields
  this.x = x;
  this.y = y;
  this.cartX = round(x * TILE_SIZE + HALF_TILE);
  this.cartY = round(y * TILE_SIZE + HALF_TILE);
 }
 
 /**
 *  Draws the point as a rectangle. This is used primarily for debug purposes.
 */
 void drawPoint() {
  rect(cartX, cartY, pointSize, pointSize);  //Draw the rectangle, centred on x y
 }
}



/**
* The pather class builds and stores the points that each entity will move towards to reach its goal.
* It reads the map to create these points. It can also draw the path if need be.
**/
class Pather {
  int numPoints;  //How many points there are 
  Point[] points; 
  Tile[][] tiles;
  int x, y, rows, cols, endX, endY;
  Point endPoint;
  
  Pather(Map m) {
    this.numPoints = 1;  //There will be at least one point
    
    //Get all the necessary starting information from the map
    this.x = m.startTile.gridX;
    this.y = m.startTile.gridY;
    this.endX = m.endTile.gridX;
    this.endY = m.endTile.gridY;
    this.tiles = m.tiles;
    this.rows = m.rows;
    this.cols = m.cols;
  }
  
  /**
  * Draws all the points along the path. Used for debugging
  **/
  void drawPoints() {
    float lastX = round(path.points[0].x * TILE_SIZE + HALF_TILE), lastY = round(path.points[0].y * TILE_SIZE + HALF_TILE);  //Remember the last point shown. Initially this is the first point.
    //Set the display parameters
    noFill();
    stroke(pointColor);
    strokeWeight(2);
    rectMode(CENTER);
    Point p;  //The currently selected point
    //Loop through all the points
    for (int i = 0; i < this.numPoints; i++) {
      p = this.points[i];
      float x = p.x * TILE_SIZE + HALF_TILE;
      float y = p.y * TILE_SIZE + HALF_TILE;
      line(lastX, lastY,x , y);
      p.drawPoint();
      
      lastX = x;
      lastY = y;
    }
  }
  
  /**
  * Generates a path of points for entities to follow.
  **/
  void generatePath() {
    ArrayList<Point> generatingPoints = new ArrayList<Point>();  //Use this array list while generating the points
    int direction;  //Dictates which direction to look in next
    int count = 0;
    
    direction = findNeighbourDirection(-1);  //Pass in -1 as this is the first run, and there is no given direction
    generatingPoints.add(new Point(x, y));  //Add the starting tile point to the array
    
    while (checkEndReached() == false) {
      if (dist(x, y, endX, endY) == 1) {
        direction = findNeighbourDirection(direction);
        numPoints++;
        generatingPoints.add(new Point(x, y));;
        moveToNextTile(direction);
      }
      else if (dist(x, y, endX, endY) == 0) {
       break; 
      }
      else if (checkNextTile(direction) == false) {
        numPoints++;  //A corner has been found, increase points and add this one to the array
        generatingPoints.add(new Point(x, y));
        direction = findNeighbourDirection(direction);
      }
      else {
       moveToNextTile(direction); 
      }
      count++;
    }
    numPoints++;  //End is reached. Add the point
    if (direction == 0) y--;
    else if (direction == 1) x++;
    else if (direction == 2) y++;
    else x--;
    Point end = new Point(x, y);
    this.endPoint = end;
    generatingPoints.add(end);
    
    
    points = new Point[numPoints];
    points = generatingPoints.toArray(points);
  }
  
  /**
  * Moves the generator x and y points to the next tile along, depending on the direction.
  **/
  void moveToNextTile(int direction) {
   if (direction == 0) y--;
   else if (direction == 1) x++;
   else if (direction == 2) y++;
   else if (direction == 3) x--;
  }
  
  /**
  *  Returns true of false as to whether or not the next tile in line is valid
  **/
  boolean checkNextTile(int direction) {
    if (direction == 0) {  //if the next direction is north
      if (y <= 0) return false;  //Index is out of bounds
      else if (tiles[x][y - 1].type != 1) return false;  //The tile is not of the correct type
    }
    else if (direction == 1) {  //Direction is east
      if (x >= cols - 1) return false;
      else if (tiles[x + 1][y].type != 1) return false;
    }
    else if (direction == 2) {  //Direction is south
      if (y >= rows - 1) return false;
      else if (tiles[x][y + 1].type != 1) return false;
    }
    else if (direction == 3) {  //Direction is west
      if (x <= 0) return false;
      else if (tiles[x - 1][y].type != 1) return false;
    }
    return true;  //No errors encountered, next tile is correct type
  }
  
  /**
  *  Finds the direction of the next neighbour. Throws an exception if none can be found. The searchingForEnd boolean states if it is looking for the end neighbour number (which is 3).
  **/
  int findNeighbourDirection(int direction) {
     int desiredType = 1;  //The desired tile to move on to. Usually this is 1, for path tiles, but at the end this will be 3, for the end tile.
     
     if (x > 0 && direction != 1 && (tiles[x - 1][y].type == desiredType || tiles[x - 1][y].type == 3)) return 3;  //If there is a tile to the west
     else if (x <= cols - 1 && direction != 3 && (tiles[x + 1][y].type == desiredType || tiles[x + 1][y].type == 3)) return 1;  //east
     else if (y > 0 && direction != 2 && (tiles[x][y - 1].type == desiredType || tiles[x][y - 1].type == 3)) return 0;  //north
     else if (y <= rows - 1 && direction != 0 && (tiles[x][y + 1].type == desiredType || tiles[x][y + 1].type == 3)) return 2;  //south
     else throw new RuntimeException("Invalid board for constructing pather");
  }
  
  /**
  *  Returns true of false as to whether or not the end tile has been reached
  **/
  boolean checkEndReached() {
   if (this.x == this.endX && this.y == this.endY) return true;
   return false;
  }
}