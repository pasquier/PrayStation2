class AestheticAgent { //<>//
  int x, y, belief_type, image_index, lifespan;
  float size, speed;

  // for special type of movement
  PVector direction; // for radial move
  PVector center;    // for inwards move

  AestheticAgent(int x, int y, int belief_type, int image_index, int lifespan, float speed) {
    this.x = x;
    this.y = y;
    this.belief_type = belief_type;
    this.image_index = image_index;
    this.lifespan = lifespan;
    this.size = 1;
    this.speed = speed;
    direction = new PVector();
    center = new PVector();

    if (belief_type == HINDUISM) { // radial move
      direction = new PVector((int)random(6), (int)random(6));
    } else if (belief_type == CHINESE) { // inwards move
      do {
        float angle = random(360);
        center = new PVector(x, y);
        float radius = random(50, 120);
        this.x = x + (int)(cos(radians(angle)) * radius + random(20));
        this.y = y + (int)(sin(radians(angle)) * radius + random(20));
        direction.x = center.x - x > 0 ? -1 : 1;
        direction.y = center.y - y > 0 ? -1 : 1;
      } while (this.x < 0 || this.x > width || this.y < 0 || this.y > height);
    }
  }

  void feed() {
    int loc = x + y * width;
    if (loc >= pixels.length) {
      println("Exception Of Function feed(): loc out of bound.");
      lifespan = 0;
      return;
    }
    
    feedPixel(loc);
  }
  
  private void feedPixel(int loc) {
    color c = lerpColor(myPixels[loc], images.get(belief_type).get(image_index).pixels[loc], LERP_AMOUNT);
    myPixels[loc] = c;
    pixels[loc] = c;
  }

  void move() {
    if(lifespan <= 0) return;
    int dx = 0;
    int dy = 0;
    // calculate dx and dy
    if (belief_type == CHRISTIANITY || belief_type == ISLAM 
      || belief_type == ATHEIST || belief_type == HINDUISM) {
      int[] directionX = directions[0];
      int[] directionY = directions[0];
      int rand = 0;
      switch (belief_type) {
        // key 1
      case CHRISTIANITY: // erosion (random walk)
        directionX = directions[1];
        directionY = directions[1];
        break;
        // key 2
      case ISLAM: // directional (right-up)
        directionX = directions[0];
        directionY = directions[2];
        break;
        // key 4
      case ATHEIST: // oval
        directionX = directions[4];
        directionY = directions[1];
        break;
        // key 5
      case HINDUISM: // radial
        directionX = directions[(int)direction.x];
        directionY = directions[(int)direction.y];
        break;
      }
      rand = int(random(0, directionX.length));
      dx = directionX[rand];
      rand = int(random(0, directionY.length));
      dy = directionY[rand];
    } else {
      PVector target = new PVector();
      switch (belief_type) {
        // key 6
      case CHINESE: // inwards
        dx = (int)((center.x - x) / dist(center.x, center.y, x, y) * random(-1, 2) + random(-2, 2));
        dy = (int)((center.y - y) / dist(center.x, center.y, x, y) * random(-1, 2) + random(-2, 2));
        break;
        // key 7
      case BUDDHISM: // gradient attraction (attracted by black)
        target = findDarkestNeighbour();
        dx = (int)target.x;
        dy = (int)target.y;
        break;
        // key 8
      case ANIMISM: // gradient refraction (attracted by white)
        target = findBrightestNeighbour();
        dx = (int)target.x;
        dy = (int)target.y;
        break;
      }
    }
    dx *= 1 + random(speed);
    dy *= 1 + random(speed);
    x += dx;
    y += dy;
    checkBounds();

    // visualize the agent
    int loc = x + y * width;
    if (isVisible) {
      pixels[loc] = color(255, 0, 0);
    }

    lifespan--;
  }

  // when the agent dies, restore the curent pixel from (maybe) white to the original
  void die() {
    int loc = x + y * width;
    if (loc >= pixels.length) {
      println("Exception Of Function die(): loc out of bound.");
      lifespan = 0;
      return;
    }
    pixels[loc] = myPixels[loc];
  }

  int getLifespan() {
    return lifespan;
  }

  void checkBounds() {
    if ( x < 0 ) { 
      x = width-1;
    }
    if ( x > width - 1 ) { 
      x = 0;
    }
    if ( y < 0 ) { 
      y = height - 1;
    }
    if ( y > height - 1 ) { 
      y = 0;
    }
  }

  // return if c1 is brighter than c2
  boolean isBrighter(color c1, color c2) {
    return (brightness(c1)) > (brightness(c2));
  }

  // find the leagle random neighbour of current agent
  PVector findRandomNeighbour() {
    PVector target = new PVector();
    if (pixels.length <= 1) return target;
    int loc;
    do {
      target = new PVector((int)random(3) - 1, (int)random(3) - 1);
      loc = (x + (int)target.x) + (y + (int)target.y) * width;
    } while ((target.x == 0 && target.y == 0) || loc < 0 || loc >= pixels.length);
    return target;
  }

  // find the brightest neighbour of current agent
  PVector findBrightestNeighbour() {
    PVector random = findRandomNeighbour(); // neighbour's relative position to the agent
    PVector darkest = random.copy();
    int loc = (x + (int)random.x) + (y + (int)random.y) * width;
    color c = pixels[loc];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (i==1 && j==1) continue;
        loc = (x - 1 + i) + (y - 1 + j) * width;
        if (loc < 0 || loc >= pixels.length) continue;
        if (isBrighter(pixels[loc], c)) {
          c = pixels[loc];
          darkest.x = - 1 + i;
          darkest.y = - 1 + j;
        }
      }
    }
    return random(1) > 0.25 ? darkest : random;
  }

  // find the darkest neighbour of current agent
  PVector findDarkestNeighbour() {
    PVector random = findRandomNeighbour(); // neighbour's relative position to the agent
    PVector brightest = random.copy();
    int loc = (x + (int)random.x) + (y + (int)random.y) * width;
    color c = pixels[loc];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (i==1 && j==1) continue;
        loc = (x - 1 + i) + (y - 1 + j) * width;
        if (loc < 0 || loc >= pixels.length) continue;
        if (isBrighter(c, pixels[loc])) {
          c = pixels[loc];
          brightest.x = - 1 + i;
          brightest.y = - 1 + j;
        }
      }
    }
    return random(1) > 0.25 ? brightest : random;
  }
}