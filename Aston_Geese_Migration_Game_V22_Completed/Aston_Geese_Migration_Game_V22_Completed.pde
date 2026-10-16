//Constants
final int OBS_WIDTH = 100; //Obstacle Width
final int OBS_HEIGHT = 40; //Obstacle Height
final int LEADER_START_X = 800; //Leader starting x position
final int LEADER_START_Y = 650; //Leader starting y position

//Variables
Goose leader = new Goose(); //Lead goose
float obsX = 800; //Obstacle starting point
float obsY = -50; //Obstacle starting point
float obsSpeed = 3; //Obstacle speed
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>(); //Stores all falling Obstacles into an ArrayList
ArrayList<PVector> trail = new ArrayList<PVector>(); //Stores the leaders previous position so that the flock can follow and placed into an ArrayList
ArrayList<Goose> flock = new ArrayList<Goose>(); //Stores the 5 following flock of geese into an ArrayList
int [] moregeese = {3, 3, 6, 6, 9}; //Array List for 5 additional geese
float[] xstagger = {-45, 45, -95, 95, 0}; //Additional geese staggered x axis
float[] ystagger = {40, 40, 80, 80, 120}; //Additional geese staggered y axis
boolean aLeft = false; //Key function for clicking "a" to move left
boolean dRight = false; //Key function for clicking "d" to move right
boolean obsHit = false; //Obstacle hit variable
int gamestate = 2; //Game state: 0 = playing, 1 = game over, 2 = splash, 3 = instructions
int distanceCovered = 0; //Tracks how far the player has has travelled
int currentLevel = 1; //Current level, this increases as distance progresses
int highScore = 0; //Stores the highest distance covered from the player


//Game Setup = Canvas size, Starting position, Staggered position for flock, Delay for movement
void setup() {
  size(1600, 900); //Canvas Size
  leader.x = LEADER_START_X; //Lead Goose Size x axis
  leader.y = LEADER_START_Y; //Lead Goose Size y axis
  for (int i = 0; i < 5; i = i + 1) {
    flock.add(new Goose());
    flock.get(i).delay = moregeese[i];
    flock.get(i).offX = xstagger[i];
    flock.get(i).offY = ystagger[i];
  }
}

//Main Game Loop
void draw() {
  if (gamestate == 0) {

    updateLevel(); //This command calls the update level function created at the bottom of the file

    moveLeader(); //This command calls the move leader function created at the bottom of the file

    displayWorld(); //This command calls the display world function at the bottom of the file, this is the entire display for the game (background, drawings etc)

    obsY = obsY + obsSpeed; //Moves single obstacle down
    if (obsY > height) { //Respawns the same obstacle when it falls off screen
      obsY = - 50; //-50 is the height at which the obstacle respawns from, this is off screen
      obsX = random(0, width - OBS_WIDTH); //Randomises the x position on the canvas for the respawned obstacle
      obsHit = false; //Resets the obstacle hit
    }

    //"Distance Covered" Text input at the top of the screen with colour and positions
    fill(255, 215, 0);
    textSize(30);
    textAlign(CENTER); //Aligns the text on screen centrally
    text("Distance Covered: " + distanceCovered, width/2, 60);
    text("Level: " + currentLevel, width/2, 90);

    checkHits(); //Checks leader against all obstacles and handles the flocks falling consequences
  } else if (gamestate == 1) {
    background(20, 20, 40); //Background of the GAME OVER canvas screen colour
    fill(255, 215, 0); //Gold text colour for the GAME OVER title
    textSize(60); //Text size for GAME OVER text
    textAlign(CENTER);
    text("GAME OVER!", width/2, height/2 - 100); //Width and Height ratio for the text GAME OVER title
    fill(255);
    textSize(30);
    text("Distance Covered: " + distanceCovered, width/2, height/2); //Final score
    if (distanceCovered >= highScore) { //Checks if current game beats the high score
      fill(255, 215, 0);
      text("NEW HIGH SCORE!", width/2, height/2 + 80); //Displays new high score message
    } else {
      text("High Score: " + highScore, width/2, height/2 + 80); //Displays existing high score
    }
    fill(255);
    textSize(25);
    text("Press 'R' To Restart The Game", width/2, height/2 + 160);
  } else if (gamestate == 2) { //Gamestate 2 is the splash screen/loading screen before the game starts
    background(128, 0, 128); //Background purple for the splash screen
    fill(255, 215, 0); //Text colour
    textSize(80); //Text size for the below
    textAlign(CENTER); //Centrally aligns the text below. This goes before the text as the code reads this first
    text("Aston Geese Migration Game", width/2, height/2 - 60); //Text for the splash screen, width and height
    textSize(25); //Textsize for the below
    fill(255); //Text colour
    text("Press The SPACEBAR To Continue", width/2, height/2 +40);
  } else if (gamestate == 3) {
    background(128, 0, 128);
    fill(255, 215, 0);
    textSize(50);
    textAlign(CENTER);
    text("How To Play", width/2, height/2 - 200);
    fill(255);
    textSize(25);
    text("Press 'A' to move left, Press 'D' to move right", width/2, height/2 - 100);
    text("Press 'R' to reset the game at anytime", width/2, height/2 - 40);
    text("Avoid the falling obstacles, each collision will cost you a flock member!", width/2, height/2 + 20);
    text("Survive as long as possible as the speed increases with each level", width/2, height/2 + 80);
    fill(255, 255, 0);
    text("Help the flock migrate, press the 'SPACEBAR' to begin!", width/2, height/2 + 180);
  }
}


//Lead Goose
void drawLeadGoose() {

  //Lead goose drawing
  fill(40, 40, 40); //Body
  ellipse(leader.x, leader.y, 50, 30); //Body
  fill(40, 40, 40); //Neck
  rect(leader.x - 30, leader.y - 15, 10, 20); //Neck
  circle(leader.x - 25, leader.y - 20, 22); //Head
  fill(225, 200, 0); //Beak
  triangle(leader.x - 36, leader.y - 24, leader.x - 36, leader.y - 16, leader.x - 52, leader.y - 20); //Beak
  fill(255, 250, 240);  //Chin
  circle(leader.x - 28, leader.y - 13, 9);  //Chin
}

//Flock of geese values on size. Smaller than the Lead goose
void drawGeeseFlock(float x, float y) {

  fill(40, 40, 40); //Body
  ellipse(x, y, 26, 16); //Body
  fill(40, 40, 40); //Neck
  rect(x - 15, y - 8, 5, 10); //Neck
  circle(x - 13, y - 10, 12); //Head
  fill(225, 200, 0); //Beak
  triangle(x - 18, y - 12, x - 18, y - 8, x - 26, y - 10); //Beak
}

//Obstacle Drawing
void drawObstacle() {

  fill(90, 90, 90); //Obstacle colour
  rect(obsX, obsY, OBS_WIDTH, OBS_HEIGHT); //Obstacle rectangle size
}

//Reset Function
void keyPressed() {
  if (key == 'r') { //Game reset if the letter "r" is pressed
    restartGame();
  }
  if (key == 'a') { //Move left
    aLeft = true;
  }
  if (key == 'd') { //Move right
    dRight = true;
  }
  if (key == ' ' && gamestate == 2) {
    gamestate = 3; //The spacebar key moves from the splash screen to the instructions screen
  } else if (key == ' ' && gamestate == 3) {
    restartGame(); //The spacebar moves from the instructions screen and begins the game
  }
}

void keyReleased() { //When the key is released, the movement is set to false, stopping the geese from moving
  if (key == 'a') {
    aLeft = false;
  }
  if (key == 'd') {
    dRight = false;
  }
}

void createObstacles() {
//Determines the obstacle count depending on the current level
  int count = 4;
  if (currentLevel >= 2) count = 5; 
  if (currentLevel >= 3) count = 6;
  if (currentLevel >= 4) count = 6;
  if (currentLevel >= 5) count = 7;
  if (currentLevel >= 6) count = 7;
  if (currentLevel >= 7) count = 8;
  if (currentLevel >= 8) count = 8;
  if (currentLevel >= 9) count = 10;
  if (currentLevel >= 10) count = 12;

  //Below checks all existing obstacles, if the new obstacle position is within 200 pixels of an existing one, it will reject it and try again
  while (obstacles.size() < count) {
    float newX = random(0, width - OBS_WIDTH);
    float newY = random(- 2000, - 50);
    boolean closeCall = false;
    for (int i = 0; i < obstacles.size(); i = i + 1) {
      if (abs(newX - obstacles.get(i).x) < 200 && abs(newY - obstacles.get(i).y) < 200) {
        closeCall = true;
      }
    }
    if (!closeCall) {
      Obstacle o = new Obstacle();
      o.x = newX;
      o.y = newY;
      obstacles.add(o);
    }
  }
}

//Game reset
void restartGame() {
  gamestate = 0; //Game state reset
  leader.x = LEADER_START_X; //Leader x axis size reset
  leader.y = LEADER_START_Y; //Leader y axis size reset
  obsY = -50; //Obstacle starting point reset
  obsX = random(0, width - OBS_WIDTH); //Random x axis start point of the obstacle is reset with boundary line
  obsSpeed = 3; //Obstacle speed reset
  obsHit = false; //Resets the obstacle hit
  trail.clear(); //This clears the leaders trail history
  for (int i = 0; i < flock.size(); i = i + 1) { 
    flock.get(i).falling = false; //Resets each flock member so that all appear on screen after a reset
  }
  distanceCovered = 0; //Resets the distance covered score
  currentLevel = 1; //Resets the level back to 1
  obstacles.clear(); //Removes every obstacle from the last game and starts fresh
  createObstacles(); //Creates a new set of obstacles
}

//Updates the distance score and increases the speed and level as the player progresses
void updateLevel() {
  distanceCovered++; //Increases the distance score by 1 each frame

  if (distanceCovered > 1000 && currentLevel < 2) {
    obsSpeed = 3;
    currentLevel = 2;
    createObstacles();
  } //After DistanceCovered reaches 1000, this changes to Level 2 | Speed remains at 3, an extra obstacle is added

  if (distanceCovered > 1700 && currentLevel < 3) {
    obsSpeed = 4;
    currentLevel = 3;
    createObstacles();
  } //After DistanceSpeed reaches 1700, obstacle speed is increased from 3 - 4 | As distance passes 1700, this changes to Level 3

  if (distanceCovered > 2500 && currentLevel < 4) {
    obsSpeed = 5;
    currentLevel = 4;
    createObstacles();
  } //After DistanceSpeed reaches 2500, obstacle speed is increased from 4 - 5 | As distance passes 2500, this changes to Level 4

  if (distanceCovered > 3250 && currentLevel < 5) {
    obsSpeed = 6;
    currentLevel = 5;
    createObstacles();
  } //After DistanceSpeed reaches 3250, obstacle speed is increased from 5 - 6 | As distance passes 3250, this changes to Level 5

  if (distanceCovered > 4000 && currentLevel < 6) {
    obsSpeed = 7;
    currentLevel = 6;
    createObstacles();
  } //After DistanceSpeed reaches 4000, obstacle speed is increased from 6 - 7 | As distance passes 4000, this changes to Level 6

  if (distanceCovered > 5000 && currentLevel < 7) {
    obsSpeed = 8;
    currentLevel = 7;
    createObstacles();
  } //After DistanceSpeed reaches 5000, obstacle speed is increased from 7 - 8 | As distance passes 5000, this changes to Level 7

  if (distanceCovered > 6000 && currentLevel < 8) {
    obsSpeed = 9;
    currentLevel = 8;
    createObstacles();
  } //After DistanceSpeed reaches 6000, obstacle speed is increased from 8 - 9 | As distance passes 6000, this changes to Level 8

  if (distanceCovered > 7000 && currentLevel < 9) {
    obsSpeed = 10;
    currentLevel = 9;
    createObstacles();
  } //After DistanceSpeed reaches 7000, obstacle speed is increased from 9 - 10 | As distance passes 7000, this changes to Level 9

  if (distanceCovered > 8500 && currentLevel < 10) {
    obsSpeed = 11;
    currentLevel = 10;
    createObstacles();
  } //After DistanceSpeed reaches 8500, obstacle speed is increased from 10 - 11 | As distance passes 8500, this changes to Level 10
  if (currentLevel >= 10) obsSpeed = obsSpeed + 0.002; //Gradually increases the speed beyond level 10, making the game impossible to beat
}

//Moves the lead goose based on key input, keeps the goose within the canvas and saves its position to the trail
void moveLeader() {
  if (aLeft) leader.x = leader.x - 8; //'A' Key function moves left
  if (dRight) leader.x = leader.x + 8; //'D' Key function moves right
  if (leader.x < 0) leader.x = 0; //Creates a boundary line so that the geese can not go outside of the created canvas
  if (leader.x > width) leader.x = width; //Creates a boundary line so that the geese can not go outside of the created canvas
  trail.add(0, new PVector(leader.x, leader.y));
}

//Below is the function for displaying the world. This is called in the void draw() section at the top of the file
void displayWorld() {
  background(135, 206, 235); //Main sky background colour
  //Visual wind line affect
  fill(255);
  stroke(255, 255, 255, 150); //Transparent White
  strokeWeight(1);
  for (int w = 0; w < 40; w = w + 1) { //Loops through 40 wind lines
    float wx = (w * 137) % width; //Spreads lines across screen
    float wy = (w * 97 + frameCount * 1.5) % height; //Lines fall slower than obstacles
    bezier(wx, wy, wx + 8, wy - 5, wx + 14, wy + 5, wx + 25, wy); //Draws a curved wind line
  }
  noStroke(); //Resets stroke so geese and obstacles are not affected
  
  drawLeadGoose(); //Draws the lead goose
  for (int i = 0; i < flock.size(); i = i + 1) { //Loops through each flock member
    if (flock.get(i).falling) { //Flock knocks off a goose upon impact with obstacle
      flock.get(i).y = flock.get(i).y + 6; //Falling goose drops down the screen
      drawGeeseFlock(flock.get(i).x, flock.get(i).y); //Draws falling goose at its own position
    } else {
      if (trail.size() > flock.get(i).delay) { //Checks trail is long enough for this goose
        PVector p = trail.get(flock.get(i).delay); //Reads this goose's trail position
        drawGeeseFlock(p.x + flock.get(i).offX, p.y + flock.get(i).offY); //Draws goose at trail position with formation offset
        float smallGoosex = p.x + flock.get(i).offX; //Goose screen x position
        float smallGoosey = p.y + flock.get(i).offY; //Goose screen y position
        if (!obsHit && checkOverlap(smallGoosex, smallGoosey, obsX, obsY, 13, 26, 8, 16)) { //Checks follower vs single obstacle
          flock.get(i).x = smallGoosex; //Saves goose x position before falling
          flock.get(i).y = smallGoosey; //Saves goose y position before falling
          flock.get(i).falling = true; //Triggers falling state
          obsHit = true; //Latches hit so only one goose falls per obstacle pass
          obsY = -50; //Resets the obstacle after collision
          obsX = random(0, width - OBS_WIDTH); //Resets the obstacle after collision randomly with boundary line
        }
      }
    }
  }

  drawObstacle(); //Draws the obstacle on screen
  for (int i = 0; i < obstacles.size(); i = i + 1) { //Loops through ArrayList obstacles
    obstacles.get(i).y = obstacles.get(i).y + obsSpeed; //Moves obstacle down the screen
    if (obstacles.get(i).y > height) { //Respawns obstacle when it falls off screen
      obstacles.get(i).y = random(- 3000, - 50); //New random y position above screen
      obstacles.get(i).x = random(0, width - OBS_WIDTH); //New random x position within canvas
      obstacles.get(i).hit = false; //Resets hit latch for next pass
    }
    fill(90, 90, 90); //Obstacle colour
    rect(obstacles.get(i).x, obstacles.get(i).y, OBS_WIDTH, OBS_HEIGHT); //Draws obstacle rectangle
    for (int f = 0; f < flock.size(); f = f + 1) { //Checks each follower against this obstacle
      if (!flock.get(f).falling && trail.size() > flock.get(f).delay) { //Only checks flying geese with enough trail
        PVector p = trail.get(flock.get(f).delay); //Reads this goose's trail position
        float smallGoosex = p.x + flock.get(f).offX; //Goose screen x position
        float smallGoosey = p.y + flock.get(f).offY; //Goose screen y position
        if (!obstacles.get(i).hit && checkOverlap(smallGoosex, smallGoosey, obstacles.get(i).x, obstacles.get(i).y, 13, 26, 8, 16)) { //Checks follower vs ArrayList obstacle
          flock.get(f).x = smallGoosex; //Saves goose x position before falling
          flock.get(f).y = smallGoosey; //Saves goose y position before falling
          flock.get(f).falling = true; //Triggers falling state
          obstacles.get(i).hit = true; //Latches hit so only one goose falls per obstacle
          obstacles.get(i).y = random(-500, -50); //Respawns obstacle above screen
          obstacles.get(i).x = random(0, width - OBS_WIDTH); //Respawns obstacle at random x
        }
      }
    }
  }
} //End of displayWorld function

//Checks the leader goose against all obstacles and triggers flock consequences on hit
void checkHits() {
  if (checkOverlap(leader.x, leader.y, obsX, obsY, 25, 55, 15, 32)) {
    obsY = -50; //Resets the obstacle after collision
    obsX = random(0, width - OBS_WIDTH); //Resets the obstacle after collision randomly
    obsHit = false; //Resets the hit latch
    int count = 0;
    for (int j = 0; j < flock.size(); j = j + 1) {
      if (!flock.get(j).falling) count = count + 1; //Counts living flock members
    }
    if (count > 0) {
      int hitGoose = int(random(0, flock.size())); //Picks a random flock member
      while (flock.get(hitGoose).falling) {
        hitGoose = int(random(0, flock.size())); //Re-rolls if already falling
      }
      PVector q = trail.get(flock.get(hitGoose).delay); //Gets victim's trail position
      flock.get(hitGoose).x = q.x + flock.get(hitGoose).offX; //Sets victim x to formation slot
      flock.get(hitGoose).y = q.y + flock.get(hitGoose).offY; //Sets victim y to formation slot
      flock.get(hitGoose).falling = true; //Triggers falling state
    } else {
      if (distanceCovered > highScore) highScore = distanceCovered; //Updates the highscore if the previous score is beaten
      gamestate = 1; //No flock left - game over
    }
  }

  for (int k = 0; k < obstacles.size(); k = k + 1) { //Checks leader against ArrayList obstacles
    Obstacle obs = obstacles.get(k);
    if (!obs.hit && checkOverlap(leader.x, leader.y, obs.x, obs.y, 25, 55, 15, 32)) {
      obs.y = random(-2000, -50); //Respawns obstacle above screen
      obs.x = random(0, width - OBS_WIDTH); //Respawns at random x
      int count = 0;
      for (int j = 0; j < flock.size(); j = j + 1) {
        if (!flock.get(j).falling) count = count + 1; //Counts living flock members
      }
      if (count > 0) {
        int hitGoose = int(random(0, flock.size())); //Picks a random flock member
        while (flock.get(hitGoose).falling) {
          hitGoose = int(random(0, flock.size())); //Re-rolls if already falling
        }
        PVector q = trail.get(flock.get(hitGoose).delay); //Gets victim's trail position
        flock.get(hitGoose).x = q.x + flock.get(hitGoose).offX; //Sets victim x to formation slot
        flock.get(hitGoose).y = q.y + flock.get(hitGoose).offY; //Sets victim y to formation slot
        flock.get(hitGoose).falling = true; //Triggers falling state
      } else {
        if (distanceCovered > highScore) highScore = distanceCovered; //Updates the highscore if the previous score is beaten
        gamestate = 1; //No flock left - game over
      }
    }
  }
} //End of checkHits function

//This function will return True if the goose and obstacle positions overlap. This is used for collision detection.
boolean checkOverlap(float ox, float oy, float lx, float ly, float r, float l, float d, float u) {
  return ox + r > lx && ox - l < lx + OBS_WIDTH && oy + d > ly && oy - u < ly + OBS_HEIGHT;
}

class Goose {
  float x;
  float y;
  int delay;
  float offX;
  float offY;
  boolean falling = false;
}

class Obstacle {
  float x;
  float y;
  boolean hit = false;
}
