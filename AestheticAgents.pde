class AestheticAgent {
  int x, y, target_image, lifespan, size;

  AestheticAgent(int x, int y, int target_image, int lifespan) {
    this.x = x;
    this.y = y;
    this.target_image = target_image;
    this.lifespan = lifespan;
    this.size=1;
  }

  void feed() {
    int loc = x + y * width;
   // println("TARGET:" + " " + target_image);
    pixels[loc] = lerpColor(pixels[loc], images[target_image].pixels[loc], LERP_AMOUNT);
  }
  //move randomly in one of 8 directions, canvas is toroidal
  void move() {
   
    int [] direction = new int[] { 
      -1, 0, 1
    };
    
    int rand = int(random(0, 3));
    x += direction[rand];
    rand = int(random(0, 3));
    y += direction[rand];
   
    checkBounds();
    lifespan--;
  }
  
  int getLifespan(){
    return lifespan;
  }

  void checkBounds() {
    if( x < 0 ) { 
      x = width-1;
    }
    if( x > width - 1 ) { 
      x = 0;
    }
    if( y < 0 ) { 
      y = height - 1;
    }
    if( y > height - 1 ) { 
      y = 0;
    }
  }
}

