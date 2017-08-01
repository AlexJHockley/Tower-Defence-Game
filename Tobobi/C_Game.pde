  /* ======================================================================= */
 /*  This tab contains all class  for GAME, which managed the overall game. */  
/* ======================================================================= */



/**
* Manages the current game, keeping track of coins, waves, etc.
**/
class Game {
  int maxWaves = 10, currentWave = 2;
  int currentCoins = 100;
  float currentBaseHp = 500, maxBaseHp = 1000;
  Wave[] waveEnemies;
  
  Game(int maxWaves, int startCoins, int baseHp) {
    this.maxWaves = maxWaves;
    this.currentWave = 0;
    this.currentCoins = startCoins;
    this.maxBaseHp = baseHp;
    this.currentBaseHp = baseHp;
    waveEnemies = new Wave[maxWaves];
  }
  
  /* COIN MANAGEMENT BEYOND THIS POINT */
  
  /**
  *  Checks if a purchase can be afforded.
  **/
  boolean canAfford(int amount) {
   if (amount > currentCoins) return false;
   return true;
  }
  
  /**
  * Attempts to purchase an item, throws an error if it cannot be done
  **/
  void purchaseItem(int amount) {
   this.currentCoins -= amount;
   if (currentCoins < 0) throw new RuntimeException("Coins below 0, should not have reached purchase! Coins: " + currentCoins + " Amount payed: " + amount);
  }
  
  /**
  * Sells an item, refunding the amount to the account. The amount refunded depends on the item.
  **/
  void sellTurret(Turret t) {
   currentCoins += (this.getTurretCost(t) / 2); 
  }
  
  /**
  * Gets the cost of upgrading this particular turret.
  **/
  int getUpgradeCost(Turret t) {
    return (t.type * 50 + (50 * (t.level + 1)));
  }
  
  /**
  * Gives money relative to the unit killed.
  **/
  void unitKillPay(Entity enem) {
    this.currentCoins += enem.maxHp * 0.05; 
  }
  
  /**
  * Gets the value of this turret.
  **/
  int getTurretCost(Turret t) {
   return (t.type * 50 + (t.level * 50) + 100);  //Turrets cost 100 for MG, 150 for cannon. Add 50 for each level they have 
  }
  
  
  
  /* WAVE GENERATION BEYOND THIS POINT */
  
  /**
  * Checks if the wave is over or not.
  **/
  boolean waveOver() {
   if (currentEnemies == null) {
    return true;
   }
   else {
    for (Entity e: currentEnemies) {
     if (!(e instanceof DyingEntity) && !e.endReached) {
      return false;  //Entity is not at end or dead, the wave is not over.
     }
    }
   }
   return true;
  }
  
  /**
  * Generates waves for the game. SOme waves are manually built
  **/
  void generateWaveEnems() {
    int numPerWave = 10;
    int waveSize = 0;
    Wave thisWave;
    int halfWave;
    for (int i = 0; i < maxWaves; i++) {
      waveSize = (i + 1) * numPerWave;
      thisWave = new Wave();
      halfWave = round(waveSize / 2);
      if (i < 2) 
        thisWave.addAll(generateEnemies(waveSize, 0, 0));
      else if (i < 5) {
        thisWave.addAll(generateEnemies(halfWave, 0, 0));
        thisWave.addAll(generateEnemies(halfWave, 1, halfWave));
      }
      else if (i == 6) {
        thisWave.addAll(generateEnemies(20, 0, 0));
        thisWave.addAll(generateEnemies(30, 1, 20));
        thisWave.addAll(generateEnemies(10, 2, 50));
      }
      else if (i == 7) {
        thisWave.addAll(generateEnemies(10, 0, 0));
        thisWave.addAll(generateEnemies(30, 1, 10));
        thisWave.addAll(generateEnemies(30, 2, 40));
      }
      else if (i == 8) {
        thisWave.addAll(generateEnemies(20, 1, 0));
        thisWave.addAll(generateEnemies(40, 2, 20));
        thisWave.addAll(generateEnemies(20, 3, 60));
        
      }
      else if (i == 9) {
        thisWave.addAll(generateEnemies(10, 1, 0));
        thisWave.addAll(generateEnemies(40, 2, 10));
        thisWave.addAll(generateEnemies(40, 3, 50));
        
      }
      else {
        thisWave.addAll(generateEnemies(halfWave, 2, 0));
        thisWave.addAll(generateEnemies(halfWave, 3, halfWave));
      }
      waveEnemies[i] = thisWave;
    }
  }
  
  /**
  * Loads a set number of same type entities and returns them
  **/
  Entity[] generateEnemies(int numEnems, int type, int counter) {
   Entity[] enems = new Entity[numEnems];
   for (int i = 0; i < numEnems; i++) {  //Load all enemies of this type
     enems[i] = new Entity(type, i + counter);
   }
   return enems;
  }
  
  /**
  * Get the enemies from the given wave
  **/
  Entity[] getWaveEnemies(int wave) {
    numEnemies = wave * 10;
    Entity[] enems  = new Entity[numEnemies];  //Initialise the array 
    enems = waveEnemies[wave - 1].enemies;
    return enems;
  }
}


class Wave {
 Entity[] enemies;
 
 Wave(Entity[] enems) {
  this.enemies = new Entity[enems.length];
  for (int i = 0; i < enems.length; i++) {
   enemies[i] = enems[i]; 
  }
 }
 
 Wave() {
  this.enemies = new Entity[0]; 
 }
 
 void addAll(Entity[] enems) {
  Entity[] temp = new Entity[enemies.length + enems.length];
  for (int i = 0; i < enemies.length; i++) {
   temp[i] = enemies[i]; 
  }
  int num = 0;
  if (enemies.length > 0) num = enemies.length;
  for (int i = num; i < temp.length; i++) {
   temp[i] = enems[i - num]; 
  }
  enemies = temp;
 }
}