// TODO: Divide space
// TODO: Color check optimisation
// TODO: Track down halting condition OR restart if halts for x time somewhere else
// TODO: "Start Somewhere Else" logic
// TODO: Multithread it

int width = 256;
int height = 192;

int[][] grid;

int numParticles;
ArrayList<PVector> particles;
ArrayList<PVector> frozenParticles;

PVector centerOfGravity;
float largestDistanceFromCenter;
float initialSpawnRadius;
float spawnRadius;

boolean skipRender;

void calculateCenterOfGravity()
{
  //println(getSpawnArea());
  numParticles = (int)(getSpawnArea()/50);
  int x = 0;
  int y = 0;
  
  for (PVector p : frozenParticles) 
  {
    x+=p.x;
    y+=p.y;
  }
  
  centerOfGravity = new PVector(x/frozenParticles.size(), y/frozenParticles.size());
}

void randomiseGrid()
{
  for (int i = 0; i < width; i++) 
  {
    for (int j = 0; j < height; j++) 
    {
      grid[i][j] = (int)(random(255));
    }
  }
}

void initGrid()
{
  for (int i = 0; i < width; i++) 
  {
    for (int j = 0; j < height; j++) 
    {
      grid[i][j] = 0;
    }
  }
}

boolean isInFrozenParticles(PVector p)
{
  for (PVector p1 : frozenParticles) 
  {
    if(p1 == p)
    {
      return true;
    }
  }
  return false;
}

/*
xb  = xmalloc(sizeof(int) * num);
  yb  = xmalloc(sizeof(int) * num);
  for(i = 0; i < num; i++) {
    xb[i] = random_range(-width / 10, width / 10) + width / 2;
    yb[i] = random_range(-height / 10, height / 10) + height / 2;
  }
  
*/

PVector randomPosNearCenter()
{
  PVector newPos = new PVector(-1000,-1000);
  
  while(PVector.dist(centerOfGravity, newPos) > spawnRadius)
  {
    println("randomPosNearCenter() while");
    newPos = new PVector((int)random(0, width),
                         (int)random(0, height));
  }
  
  return newPos;
}

void newParticle()
{  
  PVector aParticle = randomPosNearCenter();
    while(isInFrozenParticles(aParticle))
    {
      println("newParticle() while");
      aParticle = randomPosNearCenter();
    }
      
    particles.add(aParticle);
}

void initParticles()
{
  particles = new ArrayList<PVector>();
  
  for(int i = 0; i < numParticles; i++)
  {
    newParticle();
  }
}

void initFrozenParticle()
{
  frozenParticles = new ArrayList<PVector>();
  frozenParticles.add(new PVector((int)width/2, (int)height/2));
  calculateCenterOfGravity();
}
void setup()
{
  skipRender = true;
  numParticles = 40;
  initialSpawnRadius = 25;
  spawnRadius = initialSpawnRadius;
  size (256,192, P2D);
  grid = new int[width][height];
  orientation(LANDSCAPE);
  
  initGrid();
  initFrozenParticle();
  initParticles();
}

/*
int nearanother(int x, int y, char **grid)
{
  int nx, ny, i, j;
  
  for(i = -1; i <= 1; i++)
    for(j = -1; j <= 1; j++) {
      if(i == 0 && j == 0) continue;
      nx = x + i; ny = y + j;
      nx = (nx < 0) ? width - 1 : (nx > width - 1) ? 0 : nx;
      ny = (ny < 0) ? height - 1 : (ny > height - 1) ? 0 : ny;
      if(grid[nx][ny]) return(1);
    }
  return(0);
}
*/
void nearTests()
{
  ArrayList toAdd = new ArrayList();
  ArrayList toRemove = new ArrayList();
  
  for (int i = particles.size() - 1; i >= 0; i--) 
  {
    for (PVector p2 : frozenParticles) 
    {
      PVector p1 = particles.get(i);
      if(p1 == p2 ||
         (p1.x-1 == p2.x && p1.y-1 == p2.y) ||
         (p1.x   == p2.x && p1.y-1 == p2.y) ||
         (p1.x+1 == p2.x && p1.y-1 == p2.y) ||
         (p1.x+1 == p2.x && p1.y   == p2.y) ||
         (p1.x+1 == p2.x && p1.y+1 == p2.y) ||
         (p1.x   == p2.x && p1.y+1 == p2.y) ||
         (p1.x-1 == p2.x && p1.y+1 == p2.y) ||
         (p1.x-1 == p2.x && p1.y   == p2.y) )
      {
        float dist = PVector.dist(centerOfGravity, p1);
        if(dist > largestDistanceFromCenter)
        {
          //print(dist);
          largestDistanceFromCenter = dist;
          spawnRadius = dist + initialSpawnRadius;
        }
        toAdd.add(p1);
        toRemove.add(p1);
        skipRender = false;
      }
    }
  }
  
  frozenParticles.addAll(toAdd);
  particles.removeAll(toRemove);
  
  while(particles.size() < numParticles)
  {
    println("newParticle() while outer");
    newParticle();
  } 
  calculateCenterOfGravity();
}

void drawGrid()
{
  for (int i = 0; i < width; i++) 
  {
    for (int j = 0; j < height; j++) 
    {
      stroke(grid[i][j]);
      point(i,j);
    }
  }
}

PVector getRandomDirection()
{ 
  return new PVector((int)(random(3))-1, (int)(random(3))-1);
}
void wanderParticles()
{
  for (PVector p : particles) 
  {
    PVector newDir = getRandomDirection();
    
    if(PVector.dist(centerOfGravity, 
                       new PVector(p.x + newDir.x, 
                                   p.y + newDir.y)) > spawnRadius)
    {
      newDir.x *= -1;
      newDir.y *= -1;
    }
      
    p.add(newDir);
  }
}

void drawParticles()
{
  for (PVector p : particles) 
  {
    stroke(255,255,0);
    point(p.x,p.y);
  }
}

void drawFrozenParticles()
{
  for (PVector p : frozenParticles) 
  {
    stroke(255,255,255);
    point(p.x,p.y);
  }
}

float getSpawnArea()
{
  return PI*(pow(spawnRadius,2));
}

void drawCenterOfGravity()
{
  stroke(255,0,255);
  point(centerOfGravity.x, centerOfGravity.y);
}

void draw()
{
  skipRender = true;
  background(0, 0, 0);
  
  fill(0,0);
  textSize(16);
  text("Frame rate: " + int(frameRate), 10, 20);
  
  //drawGrid();
  while(skipRender)
  {  
    wanderParticles();
    nearTests();
  }
  
  drawParticles();
  drawFrozenParticles();
  drawCenterOfGravity();
  
  ellipseMode(RADIUS);
  stroke(255,0,0);
  ellipse(centerOfGravity.x, centerOfGravity.y, spawnRadius, spawnRadius);
}