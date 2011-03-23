/*

 
 vincent[at]flyingoctopus.com
 http://flyingoctopus.net/

 Built with Processing (Beta) v0135
 uses Geomerative (Alpha) v004
 ----------------------------------------------------------------
 
 Created 24 February 2008
 *	 Revised to 24 February 2008
 *		 uses Geomerative (Alpha) v034
 
 ---------------------------------------------------------------- 
 Elastic-Type
 ---------------------------------------------------------------- 
 
 */

import traer.physics.*;
import java.util.Vector;
import geomerative.*;

RGroup group;

RFont f;

Vector tendrils;
ParticleSystem physics;
Particle mouse;

//------------------------ Runtime properties ----------------------------------
// Save each frame
boolean SAVEVIDEO;
boolean SAVEFRAME;
//------------------------------------------------------------------------------

//------------------------ Drawing properties ----------------------------------
// Text to be drawn
String STRNG;

// Font to be used
String FONT;

// Margin from the borders
float MARGIN;
//------------------------------------------------------------------------------


String newString = "";


void setup(){
  size(1000,560);
  frameRate(30);

  SAVEVIDEO = false;
  SAVEFRAME = false;

  STRNG = "vincent";
  FONT = "DroidSansMono.ttf";
  MARGIN = 7;

  try{
    smooth();
  }
  catch(Exception e){
  }
  stroke( 0 );
  background(255);
  cursor( CROSS );


  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
  RCommand.setSegmentLength(10);
  
  initialize();
}

void draw(){
  background( 255 );
  translate(width/2, height/2);

  if(mousePressed){
    mouse.position().set( mouseX-width/2, mouseY-height/2, 0 );
    for ( int i = 0; i < tendrils.size(); ++i )
    {
      T3ndril t = (T3ndril)tendrils.get( i );
      t.firstspring.turnOn();
    }
  }else{
    for ( int i = 0; i < tendrils.size(); ++i )
    {
      T3ndril t = (T3ndril)tendrils.get( i );
      t.firstspring.turnOff();
    }
  }  

  physics.tick( 1.0f );

  stroke(0);

  for ( int i = 0; i < tendrils.size(); ++i )
  {
    T3ndril t = (T3ndril)tendrils.get( i );
    drawElastic( t );
  }

  if(SAVEVIDEO) saveFrame(STRNG+"video-####.tga");
}

void drawElastic( T3ndril t )
{
  float lastStretch = 1;
  for ( int i = 0; i < t.particles.size()-1; ++i )
  {
    Vector3D firstPoint = ((Particle)t.particles.get( i )).position();
    Vector3D firstAnchor =  i < 1 ? firstPoint : ((Particle)t.particles.get( i-1 )).position();
    Vector3D secondPoint = i+1 < t.particles.size() ? ((Particle)t.particles.get( i+1 )).position() : firstPoint;
    Vector3D secondAnchor = i+2 < t.particles.size() ? ((Particle)t.particles.get( i+2 )).position() : secondPoint;

    //float springStretch = 2.5f/((Spring)t.springs.get( i )).stretch();
    Spring s = (Spring)t.springs.get( i );
    float springStretch = 2.5*s.restLength()/s.currentLength();

    strokeWeight( (float)((springStretch + lastStretch)/2.0f) );	// smooth out the changes in stroke width with filter
    lastStretch = springStretch;

    curve( firstAnchor.x(), firstAnchor.y(),
    firstPoint.x(), firstPoint.y(),
    secondPoint.x(), secondPoint.y(),
    secondAnchor.x(), secondAnchor.y() );
  }
}

void keyReleased(){
  initialize();
  //exit();
  //saveFrame(STRNG+"-###.tga");
}

void initialize(){
  if(tendrils!=null){
    tendrils.clear();
  }
  
  if(physics!=null){
    physics.clear();
  }
  
  RG.init(this);
  f = new RFont(this.FONT,372,RFont.CENTER);
  group = f.toGroup(STRNG);

  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
  RCommand.setSegmentLength(20);

  group = group.toPolygonGroup();
  group.centerIn(g, MARGIN, 1, 1);

  physics = new ParticleSystem( 0.0f, 0.05f );

  mouse = physics.makeParticle();
  mouse.makeFixed();

  tendrils = new Vector();
  
  if(group!=null){
    for(int k=0;k<group.countElements();k++){
      RPolygon p = (RPolygon)(group.elements[k]);
      if(p!=null){
        for(int i=0;i<p.countContours();i++){
          RPoint[] ps = p.contours[i].getPoints();
          if(ps!=null){
            tendrils.add( new T3ndril( physics, new Vector3D( ps[0].x, ps[0].y, 0 ), mouse ) );
            for(int j=1;j<ps.length;j++){
              ((T3ndril)tendrils.lastElement()).addPoint( new Vector3D( ps[j].x, ps[j].y, 0 ) );
            }
            ((T3ndril)tendrils.lastElement()).addPoint( new Vector3D( ps[0].x, ps[0].y, 0 ) );
          }
        }
      }
    }
  }
}

class T3ndril
{
  public Vector particles;
  public Vector springs;
  public Spring firstspring;
  ParticleSystem physics;

  public T3ndril( ParticleSystem p, Vector3D firstPoint, Particle followPoint )
  {
    particles = new Vector();
    springs = new Vector();

    physics = p;

    Particle firstParticle = p.makeParticle( 1.0f, firstPoint.x(), firstPoint.y(), firstPoint.z() );
    particles.add( firstParticle );
    firstspring = physics.makeSpring( followPoint, firstParticle, 0.1f, 0.1f, 5 );
  }

  public void addPoint( Vector3D p )
  {
    Particle thisParticle = physics.makeParticle( 1.0f, p.x(), p.y(), p.z() );
    springs.add( physics.makeSpring( ((Particle)particles.lastElement()),
    thisParticle, 
    1.0f,
    1.0f,
    ((Particle)particles.lastElement()).position().distanceTo( thisParticle.position() ) ) );
    particles.add( thisParticle );
  }
}


void resize(int w, int h) 
{ 
  super.resize(w,h); 
  if (g != null) 
    smooth(); 
} 
