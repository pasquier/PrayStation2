class AestheticAgent { //<>//
  int x, y, belief_type, image_index, lifespan;
  float speed, size;

  // for special type of movement
  PVector direction; // for radial move
  PVector center;    // for inwards move

  AestheticAgent(int x, int y, int belief_type, int image_index, int lifespan, float speed, float size) {
    this.x = x;
    this.y = y;
    this.belief_type = belief_type;
    this.image_index = image_index;
    this.lifespan = lifespan;
    this.speed = speed;
    this.size = size;
    direction = new PVector();
    center = new PVector();

    // radial move
    if (belief_type == HINDUISM) { 
      direction = new PVector((int)random(6), (int)random(6));
    } 
    // inwards move
    else if (belief_type == CHINESE) { 
      do {
        float angle = random(360);
        center = new PVector(x, y);
        float radius = random(50, 200);
        this.x = x + (int)(cos(radians(angle)) * radius + random(20));
        this.y = y + (int)(sin(radians(angle)) * radius + random(20));
        direction.x = center.x - x > 0 ? -1 : 1;
        direction.y = center.y - y > 0 ? -1 : 1;
      } while (this.x < 0 || this.x > width || this.y < 0 || this.y > height);
    }
  }

  void feed() {
    int loc = x + y * width;
    if (loc < 0 || loc >= pixels.length || loc >= myPixels.length) {
      println("\nException Of Function feed(): loc out of bound.");
      lifespan = 0;
      return;
    }

    // dot brush
    if (size <= 1.0) {        
      feedPixel(loc);
    } 
    // line brush: random horizontal or vertical
    else if (size <= 2.0) { 
      if (random(1) < 0.5) {
        feedPixel(loc);
        feedPixel(loc - 1);
        feedPixel(loc + 1);
      } else {
        feedPixel(loc);
        feedPixel(loc - width);
        feedPixel(loc + width);
      }
    } 
    // cross brush: random wood-cross or x-cross
    else if (size <= 3.0) { 
      if (random(1) < 0.5) {
        feedPixel(loc);
        feedPixel(loc - 1);
        feedPixel(loc + 1);
        feedPixel(loc - width);
        feedPixel(loc + width);
      } else {
        feedPixel(loc);
        feedPixel(loc - width - 1);
        feedPixel(loc - width + 1);
        feedPixel(loc + width - 1);
        feedPixel(loc + width + 1);
      }
    }
    // circle brush
    //  x x 
    // x x x
    //  xxx 
    // x x x
    //  x x 
    else {
      feedPixel(loc);
      feedPixel(loc - 1);
      feedPixel(loc + 1);
      feedPixel(loc - width);
      feedPixel(loc + width);
      feedPixel(loc - width);
      feedPixel(loc - width + 2);
      feedPixel(loc - width - 2);
      feedPixel(loc + width);
      feedPixel(loc + width + 2);
      feedPixel(loc + width - 2);
      feedPixel(loc - width * 2 + 1);
      feedPixel(loc - width * 2 - 1);
      feedPixel(loc + width * 2 + 1);
      feedPixel(loc + width * 2 - 1);
    }

    // erase agent visualization
    if (isVisible && isBold) {
      eraseAgent();
    }
  }

  private void feedPixel(int loc) {
    color c = lerpColor(myPixels[loc], images.get(belief_type).get(image_index).pixels[loc], LERP_AMOUNT);
    paintPixel(pixels, loc, c);
    paintPixel(myPixels, loc, c);
  }

  private void paintPixel(color[] array, int loc, color c) {
    if (loc < 0 || loc >= pixels.length || loc >= myPixels.length) {
      return;
    }
    array[loc] = c;
  }

  void move() {
    if (lifespan <= 0) return;
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
    if (isVisible) {
      drawAgent();
    }

    lifespan--;
  }

  // when the agent dies, restore the curent pixel from (maybe) white to the original
  void die() {
    int loc = x + y * width;
    if (loc >= pixels.length) {
      println("\nException Of Function die(): loc out of bound.");
      lifespan = 0;
      return;
    }
    eraseAgent();
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

  // draw agent if it's visible
  // a dot if not bold, a wood-cross if bold
  private void drawAgent() {
    int loc = x + y * width;
    color c1 = color(255, 0, 0);
    color c2 = color(255, 0, 0, 0.5);
    if (isBold) {
      paintPixel(pixels, loc, c1);
      paintPixel(pixels, loc - 1, c2);
      paintPixel(pixels, loc + 1, c2);
      paintPixel(pixels, loc - width, c2);
      paintPixel(pixels, loc + width, c2);
    } else {
      paintPixel(pixels, loc, c1);
    }
  }

  // erase the agent drewn from the last step
  private void eraseAgent() {
    int loc = x + y * width;
    if (isBold) {
      pixels[loc] = myPixels[loc];
      if(isLeagleLoc(loc-1)) pixels[loc-1] = myPixels[loc-1];
      if(isLeagleLoc(loc + 1)) pixels[loc + 1] = myPixels[loc + 1];
      if(isLeagleLoc(loc - width)) pixels[loc - width] = myPixels[loc - width];
      if(isLeagleLoc(loc + width)) pixels[loc + width] = myPixels[loc + width];
    } else {
      pixels[loc] = myPixels[loc];
    }
  }
  
  private boolean isLeagleLoc(int loc) {
    return loc > 0 && loc < pixels.length;
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