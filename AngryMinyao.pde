import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

Maxim maxim;
AudioPlayer droidSound, wallSound;
AudioPlayer [] crateSounds;

Physics physics;
Body droid;
Body [] crates;
boolean [] cratestate;
boolean [] destroy;


Vec2 startPoint;
CollisionDetector detector;

int crateSize = 80;
int ballSize = 60;

PImage crateImage, ballImage, tip;
PImage [] explode;

int score = 0;
int [] index ;

boolean dragging = false;

String blessing="Baby! Happy Birthday!";
PFont f;
float x;

void setup()
{
  size(1024,768);
  frameRate(60);
  
  tip = loadImage("scrapyard2.jpg");
  crateImage = loadImage("xinquan.jpg");
  ballImage = loadImage("minyao.jpg");
  index = new int[7];
  
  explode = new PImage[9];
  for(int i = 0 ; i < 9 ; i++)
  {
    explode[i] = loadImage("Explode-01-june-" + i + ".jpg");
  }
  imageMode(CENTER);
  
  physics = new Physics(this,width,height,0,-5,width*2, height*2, width, height, 100);
  physics.setCustomRenderingMethod(this,"myCustomRenderer");
  physics.setDensity(10.0);
  
  crates = new Body[7];
  crates[0] = physics.createRect(600, height-crateSize, 600+crateSize, height);
  crates[1] = physics.createRect(600, height-2*crateSize, 600+crateSize, height-crateSize);
  crates[2] = physics.createRect(600, height-3*crateSize, 600+crateSize, height-2*crateSize);
  crates[3] = physics.createRect(600+1.5*crateSize, height-crateSize, 600+2.5*crateSize, height);
  crates[4] = physics.createRect(600+1.5*crateSize, height-2*crateSize, 600+2.5*crateSize, height-crateSize);
  crates[5] = physics.createRect(600+1.5*crateSize, height-3*crateSize, 600+2.5*crateSize, height-2*crateSize);
  crates[6] = physics.createRect(600+0.75*crateSize, height-4*crateSize, 600+1.75*crateSize, height-3*crateSize);
  
  cratestate = new boolean[7];
  destroy = new boolean[7];
  for(int i = 0 ; i < 7 ; i++){
    cratestate[i] = true;
    destroy[i] = false;
    index[i] = 0 ;
  }
  
  startPoint = new Vec2(200,height-180);
  
  startPoint = physics.screenToWorld(startPoint);
  
  droid = physics.createCircle(width/2,-100,ballSize/2);
  
  detector = new CollisionDetector(physics,this);
  
  maxim = new Maxim(this);
  droidSound = maxim.loadFile("droid.wav");
  wallSound = maxim.loadFile("wall.wav");
  droidSound.setLooping(false);
  wallSound.setLooping(false);
  
  crateSounds= new AudioPlayer[crates.length];
  for(int i = 0 ; i < crates.length ; i++){
    crateSounds[i] = maxim.loadFile("crate2.wav");
    crateSounds[i].setLooping(false);
  }
  f = createFont("ShadowsIntoLight",80,true);
  //f = loadFont("ShadowsIntoLight.ttf");
  x = width;
  
}
void draw(){
  if(score<=24){
    image(tip,width/2,height/2,width,height);
  
    fill(0);
    text("Score: "+ score,20,20);
  }
  else{
    background(255);
    fill(0);
    textFont(f,100);
    textAlign(LEFT);
    text(blessing,x,180);
    x -= 1;
    
    float w = textWidth(blessing);
    if(x<-w){
      x = width;
   
    }
  }
}


void mouseDragged()
{
  dragging = true;
  droid.setPosition(physics.screenToWorld(new Vec2(mouseX,mouseY)));
}

void mouseReleased()
{
  dragging = false;
  Vec2 impulse = new Vec2();
  impulse.set(startPoint);
  impulse = impulse.sub(droid.getWorldCenter());
  impulse = impulse.mul(50);
  //droid.applyImpulse(impulse,startPoint);
  droid.applyImpulse(impulse,droid.getWorldCenter());
  
}

 void myCustomRenderer(World world) {
   if(score<=24){
   stroke(0);
   
   Vec2 screenStartPoint = physics.worldToScreen(startPoint);
   strokeWeight(8);
   line(screenStartPoint.x,screenStartPoint.y,screenStartPoint.x,height);
   
   Vec2 screenDroidPos = physics.worldToScreen(droid.getWorldCenter());
   float droidAngle = physics.getAngle(droid);
   pushMatrix();
   translate(screenDroidPos.x,screenDroidPos.y);
   rotate(-radians(droidAngle));
   image(ballImage,0,0,ballSize,ballSize);
   popMatrix();
   
   for (int i = 0 ; i < crates.length ; i ++)
   {
     if(cratestate[i] == false && destroy[i] == false){
      Vec2 worldCenter = crates[i].getWorldCenter();
      Vec2 cratePos = physics.worldToScreen(worldCenter);
      pushMatrix();
      translate(cratePos.x, cratePos.y);
      if(index[i]<9000){
        image(explode[int(index[i]/1000)],0,0,crateSize,crateSize);
      }
      index[i] ++;
      popMatrix();
       physics.removeBody(crates[i]);
       destroy[i] = true;
       
     }
     else if(cratestate[i] == true) {
     Vec2 worldCenter = crates[i].getWorldCenter();
     Vec2 cratePos = physics.worldToScreen(worldCenter);
     float crateAngle = physics.getAngle(crates[i]);
     pushMatrix();
     translate(cratePos.x, cratePos.y);
     image(crateImage,0,0,crateSize,crateSize);
     rotate(-crateAngle);
     popMatrix();
     }
     
   }
   boolean flag = false;
   for(int i = 0 ; i < crates.length; i++){
     if (cratestate[i] == true){
       flag = true;
     }
     
   }
   if(flag == false)
   {
     for(int i = 0 ; i < crates.length; i++)
     {
       cratestate[i] = true;
       destroy[i] = false;
       index[i] = 0 ;
       
     }
     crates[0] = physics.createRect(600, height-crateSize, 600+crateSize, height);
     crates[1] = physics.createRect(600, height-2*crateSize, 600+crateSize, height-crateSize);
     crates[2] = physics.createRect(600, height-3*crateSize, 600+crateSize, height-2*crateSize);
     crates[3] = physics.createRect(600+1.5*crateSize, height-crateSize, 600+2.5*crateSize, height);
     crates[4] = physics.createRect(600+1.5*crateSize, height-2*crateSize, 600+2.5*crateSize, height-crateSize);
     crates[5] = physics.createRect(600+1.5*crateSize, height-3*crateSize, 600+2.5*crateSize, height-2*crateSize);
     crates[6] = physics.createRect(600+0.75*crateSize, height-4*crateSize, 600+1.75*crateSize, height-3*crateSize);
  
   }
   if (dragging){
     strokeWeight(2);
     line(screenDroidPos.x, screenDroidPos.y, screenStartPoint.x, screenStartPoint.y);
   }
   }
   else{
     
   }
   
 }
 
 void collision(Body b1, Body b2, float impulse){
   if ((b1 == droid && b2.getMass()>0) || (b2 == droid && b1.getMass()>0))
   {
     if(impulse > 1.5)
     {
       println("impulse is " + impulse);
       score += 30;
       if(b1 == droid)
       {
         for(int i = 0 ; i < crates.length; i ++)
         {
           if (b2 == crates[i])
           {
             cratestate[i] = false;
           }
         }
       }
       else{
          for(int i = 0 ; i < crates.length; i++)
          {
            if(b1 == crates[i])
              cratestate[i] = false;
          }
       }
     }
   }
   if (b1.getMass() == 0 || b2.getMass() == 0) {// b1 or b2 are walls
    // wall sound
    //println("wall speed "+(impulse/100));
    wallSound.cue(0);
    wallSound.speed(impulse / 100);// 
    wallSound.play();
  }
  if (b1 == droid || b2 == droid) { // b1 or b2 are the droid
    // droid sound
    println("droid "+(impulse/10));
    droidSound.cue(0);
    droidSound.speed(impulse / 10);
    droidSound.play();
  }
  for (int i=0;i<crates.length;i++){
     if (b1 == crates[i] || b2 == crates[i]){// its a crate
         crateSounds[i].cue(0);
         //cratestate[i] = false;
         crateSounds[i].speed(0.5 + (impulse / 10000));// 10000 as the crates move slower??
         crateSounds[i].play();
     }
   }
 }
