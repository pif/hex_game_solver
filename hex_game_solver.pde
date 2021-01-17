// Solver for this game https://www.smartgames.eu/uk/one-player-games/iq-stars //<>// //<>// //<>//
// Guide to hexagonal maps: https://www.redblobgames.com/grids/hexagons/

Cell[][] map;

final int Q = 8;
final int R = 4;
final int SIZE = 38;

// 3 violet in row
// 3 orange
// 4 red romb
// 4 yellow
// 4 blue
// 4 green
// 4 purple w
final color C_3LI = #BF21C4;
final color C_3OR = #EE7F31;
final color C_4RO = #D91221;
final color C_4YL = #FBE555;
final color C_4BL = #22A3D3;
final color C_4GR = #C0CA3E;
final color C_4WW = #F470A9;

final color[] FIGS = new color[]{C_3LI, C_3OR, C_4RO, C_4YL, C_4BL, C_4GR, C_4WW};

////////////////////
// UI CONTROLS START 
void setup() {
  size(640, 360);
  
  textAlign(CENTER);

  // setup map
  map = new Cell[Q][R];
  for (int q = 0; q < Q; q++) {
    for (int r = 0; r < R; r++) {
      map[q][r] = new Cell(q, r);
    }
  }
  // disable all non-board cells
  map[0][0].setEdge();
  map[0][1].setEdge();
  map[7][1].setEdge();
  map[7][2].setEdge();
  map[6][3].setEdge();
  map[7][3].setEdge();
  
  noLoop();
}

void draw() {
  drawMap();//startRecursion();
}

boolean isLoop = false;
int ang = 0;
int vf = 0, vq = 0, vr = 0;
void keyPressed() {
  if (key == 'a') {
    ang = (ang + 60) % 360;
  } else if (key == 'f') {
    vf = (vf + 1) % FIGS.length;
  } else if (key == 'r') {
    vr = (vr + 1) % R;
  } else if (key == 'q') {
    vq = (vq + 1) % Q;
  } else if (key == 'p') {
    println(putElement(map, FIGS[vf], vq, vr, ang));
  } else if (key == 'x') {
    long s = System.currentTimeMillis();
    startRecursion();
    long f = System.currentTimeMillis();
    println("Found solutions: " + solutions);
    println("Time, ms: " + (f - s));
    // Time, ms: 59370
    // Time, ms: 8252 – with precomputed map
  } else if (key == 'd') {
    if (isLoop)
      noLoop();
    else 
      loop();
    drawMap();
  } 
  
  println("Controls: figure " + vf + " at (q,r)=(" + vq + "," + vr + ") at angle " + ang);
}

void mouseClicked() {
  clearElement(map, FIGS[vf]);
}

void drawMap() {
  background(0);
  
  translate(SIZE, 2 * SIZE);

  for (int q = 0; q < Q; q++) {
    for (int r = 0; r < R; r++) {
      Cell c = map[q][r];
      c.draw();
    }
  }  
}

String charMap() {
  String charMap = "";
  for (int r = 0; r < R; r++) {
    for (int i =0; i < r; i++) {
      charMap = charMap + " ";
    }
    
    for (int q = 0; q < Q; q++) {
      Cell c = map[q][r];
      charMap = charMap + elemToStr(c.c) + " ";
    }
    charMap = charMap + "\n";
  }  
  
  return charMap;
}

// UI CONTROLS END
////////////////////

////////////////////
// SOLVER START
int solutions = 0;

void startRecursion() {
  println(System.currentTimeMillis());
  generateMap();
  println(System.currentTimeMillis());
  putR("S: ", 0);
  println(System.currentTimeMillis());
}

int putR(String d, int f) {
  //println(d + " --- " + f);
  String newD = d + " --> " + f + '-';
  //println(charMap());
  if (f < FIGS.length) {
    newD = newD + elemToStr(FIGS[f]);
    //println(newD);
  }  
  
  if (checkIsSolution(map)) {
    solutions++;
    //println("SOLUTION! " + solutions);
    //println(charMap()); //<>//
    return 0;
  }
  
  for (int q = 0; q < Q; q++) { //<>//
    for (int r = 0; r < R; r++) {
      if (map[q][r].edge || !map[q][r].available) {
        continue;
      }
      
      for (int a = 0; a < 360; a = a + 60) {
        if (putElement(map, FIGS[f], q, r, a) == 0) {
          putR(newD, f + 1);
          clearElement(map, FIGS[f]);
        }
      }
    }
  }
  
  return 0;  
}

/**
 * -1 – ended in edge, need to backtrack
 *  0 – all good
 */
int putElement(Cell[][] m, color elem, int offset_q, int offset_r, int angle) {
  //println("Placing "+elemToStr(elem)+" at offset q,r="+offset_q+","+offset_r+" at angle "+angle);
  //println(charMap());
  
  Cell[] fig = getFig(elem, offset_q, offset_r, angle);
  
  // check if good to set first
  for(int i = 0; i < fig.length; i++) {
    int pq = fig[i].q;
    int pr = fig[i].r;
    if (pq < 0 || pr < 0 || pq >= Q || pr >= R) {
      // got outside of the board
      return -1;
    }
    
    if (!(!m[pq][pr].edge && m[pq][pr].available)) {
      // intersect with something
      return -1;
    }
  }
  
  // all good, let's set
  for(int i = 0; i < fig.length; i++) {
    int pq = fig[i].q;
    int pr = fig[i].r;
    m[pq][pr].set(elem);
  }
  
  return 0;
}

void clearElement(Cell[][] m, color elem) {
  for (int q = 0; q < Q; q++) {
    for (int r = 0; r < R; r++) {
      if (m[q][r].c == elem) {
        m[q][r].clear();
      }
    }
  }
}

boolean checkIsSolution(Cell[][] m) {
  for (int q = 0; q < Q; q++) {
    for (int r = 0; r < R; r++) {
      if (m[q][r].edge) {
        continue;
      } else if (m[q][r].available) {
        return false;
      }
    }
  }
  
  return true;
}

// SOLVER END
////////////////////

////////////////////
// FIGURES: PRECOMPUTE & UTILS START

Cell[][][][][] precomputed = new Cell[][][][][]{};
void generateMap() {
  precomputed = new Cell[FIGS.length][Q][R][360/60][];
  for (int e = 0; e < FIGS.length; e++) {
    precomputed[e] = new Cell[Q][R][360/60][];
    for (int q = 0; q < Q; q++) {
      precomputed[e][q] = new Cell[R][360/60][];
      for (int r = 0; r < R; r++) {
        precomputed[e][q][r] = new Cell[360/60][];
        for (int a = 0; a < 360; a = a + 60) {
          precomputed[e][q][r][a/60] = genFig(FIGS[e],q,r,a);
        }
      }
    }
  }
}

Cell[] genFig(color elem, int offset_q, int offset_r, int angle) {
  Cell[] fig = new Cell[]{};
  
  switch(elem) {
    case C_3LI:
      fig = new Cell[3];
      fig[0] = new Cell(0, 0);
      fig[1] = new Cell(1, 0);
      fig[2] = new Cell(2, 0);
      //
      break;
    case C_3OR:
      fig = new Cell[3];
      fig[0] = new Cell(0, 0);
      fig[1] = new Cell(0, 1);
      fig[2] = new Cell(1, 1);
      //
      break;
    case C_4RO:
      fig = new Cell[4];
      fig[0] = new Cell(0, 0);
      fig[1] = new Cell(1, 0);
      fig[2] = new Cell(0, 1);
      fig[3] = new Cell(1, 1);
      break;
    case C_4YL:
      fig = new Cell[4];
      fig[0] = new Cell(0, 0);
      fig[1] = new Cell(0, 1);
      fig[2] = new Cell(0, 2);
      fig[3] = new Cell(1, 1);
      break;
    case C_4BL:
      fig = new Cell[4];
      fig[0] = new Cell(0, 0);
      fig[1] = new Cell(0, 1);
      fig[2] = new Cell(0, 2);
      fig[3] = new Cell(1, 0);
      break;
    case C_4GR:
      fig = new Cell[4];
      fig[0] = new Cell(0, 0);
      fig[1] = new Cell(0, 1);
      fig[2] = new Cell(0, 2);
      fig[3] = new Cell(1, 2);
      break;
    case C_4WW:
      fig = new Cell[4];
      fig[0] = new Cell(0, 0);
      fig[1] = new Cell(0, 1);
      fig[2] = new Cell(1, 1);
      fig[3] = new Cell(2, 0);
      break;
  }
  
  for(int i = 0; i < fig.length; i++) {
    Cell c = fig[i];
    fig[i] = c.rotatedAt(angle).translatedAt(offset_q, offset_r);
  }
  
  return fig;
}

Cell[] getFig(color elem, int offset_q, int offset_r, int angle) {
  return precomputed[elemToInt(elem)][offset_q][offset_r][angle/60];
}

char elemToStr(color elem) {
  switch (elem) {
    case C_3LI: return 'I';
    case C_3OR: return 'C';
    case C_4RO: return 'R';
    case C_4YL: return 'Y';
    case C_4BL: return 'K';
    case C_4GR: return 'L';
    case C_4WW: return 'W';
    case #ffffff: return '_';
    default: return ' ';
  }
}

int elemToInt(color elem) {
  switch (elem) {
    case C_3LI: return 0;
    case C_3OR: return 1;
    case C_4RO: return 2;
    case C_4YL: return 3;
    case C_4BL: return 4;
    case C_4GR: return 5;
    case C_4WW: return 6;
    default: return -1;
  }
}

// FIGURES: PRECOMPUTE & UTILS END
////////////////////

////////////////////
// HEX MATH START
 //<>//
// There's a mixture of hex-math and game-related
// things in here. Ideally it should be split.

// From hex article:
// I've chosen q for "column" = x and r as "row" = z.
// ...
// In my projects, I name the axes q, r, s 
// so that I have the constraint q + r + s = 0, 
// and then I can calculate s = -q - r
class Cell { 
  boolean edge = false;
  boolean available = true;

  int q, r;
  
  color c;
  
  int size = SIZE;

  Cell(int q, int r) {
    this.q = q;
    this.r = r;
    c = #ffffff;
  } 

  int getS() {
    return -q - r;
  }

  int getX() {
    return q;
  }

  int getY() {
    return getS();
  }

  int getZ() {
    return r;
  }
  
  float getPixelX() {
    return size * (sqrt(3) * q  +  sqrt(3)/2 * r);
  }
  float getPixelY() {
    return size * (                         3./2 * r);
  }
  
  void draw() {
    pushMatrix();
    translate(getPixelX(), getPixelY());
    rotate(TWO_PI / 4);
    fill(c);
    polygon(0, 0, size, 6);
    
    rotate(- TWO_PI / 4);
    fill(0);
    text(q + "," + r, 0, 0);
    popMatrix();
  }
  
  String toString() {
    return "q = " + q + ", r = " + r;
  } 
  
  void setEdge() {
    edge = true;    
    available = false;
    c = #444444;
  }
  
  void set(color v) {
    c = v;
    available = false;
  }
  
  void clear() {
    c = #ffffff;
    available = true;
  }
  
  Cell rotatedAt(int angle) {
    int[] loc = new int[] {getX(), getY(), getZ()};
    int[] new_loc = rotateCell(loc, angle);
    return new Cell(new_loc[0], new_loc[2]);
  }
  
  Cell translatedAt(int oq, int or) {
    return new Cell(q + oq, r + or);
  }
} 


void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

int[] rotateCell(int[] loc, int angle) {
  int[] res = new int[3];
  res[0] = loc[0];
  res[1] = loc[1];
  res[2] = loc[2];
  
  int rots = angle / 60;
  for (int i = 0; i < rots; i++) {
     res = rotate60cw(res);
  }
  
  return res; 
}

int[] rotate60cw(int[] loc) {
  int[] res = new int[3];
  res[0] = -loc[2];
  res[1] = -loc[0]; 
  res[2] = -loc[1]; 
  return res;
}

// HEX MATH END
////////////////////
