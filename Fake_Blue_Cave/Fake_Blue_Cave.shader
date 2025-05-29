//View on shadertoy > https://www.shadertoy.com/view/WfdGRB

#define MAX_STEPS 100
#define cubeEdgeFixMult 0.3
#define MAX_DIST 70.0
#define SURFACE_DIST 0.001
#define SHADOW_SURF_DIST 0.01
#define PI 3.14159
#define TAU 6.28318
#define T2x iTime*2.
#define T4x iTime*4.




//  1 out, 2 in... //Dave Hoskins
float hash12(vec2 p){
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

//iq
float sdBox( vec3 p, vec3 b ){
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdSphere(vec3 p, float radius) {
    return length(p) - radius;
}



float scene(vec3 pos) {
    //pos.z -= (T2x);
    
    float spread = 2.;
    
    vec3 idP = floor(pos / spread);
    float hash = hash12(idP.xz);
    

    
    
    vec3 p = pos;
    p.xz *= 4.;
    
    float os = 0.;
    float id1 = mod(p.x*0.5,spread);
    float id2 = mod(p.z*0.5,spread);
    if(id1 > 1.0) os += 1.2;
    if(id2 > 1.0) os += 0.8;
    p.y += sin(p.y + os + T4x) * 0.5;
    p.x += sin(p.y + os + (T2x*5.)) *0.2;
    p.z += sin(p.y + os + (T2x*2.)) *0.2;
    
    //p.x -= sin(T2x)*PI*1.5;
    p.xz = mod(p.xz, spread) - 0.5*spread;
    
    
    
    //vec3 os = vec3(0,0,0);
    //float b = sdBox(p + os,vec3(.8)); //0.5
    float sxz = clamp(hash*.9,0.2,0.6);
    float br = length(max(abs(p) - vec3(sxz*0.9,sxz*2.,sxz*0.8), 0.0)) - .1;
    float pl = pos.y + .9;
    float f = min(pl,br);
    //return pl;
    return f;
}

#define CAMSPEED 5.

float rm(vec3 ro, vec3 rd) {
  float dO = 0.0;
  vec3 color = vec3(0.0);

  for(int i = 0; i < MAX_STEPS; i++) {
    vec3 p = ro + rd * dO;

    p.y += clamp(pow(p.x ,2.)             *.05,0.,4.); //0.01
    p.y += clamp(pow(p.z - ro.z + 5.,2.)  *0.05,0.,4.); //0.01

    float dS = scene(p);

    dO += dS * cubeEdgeFixMult;


    if(dO > MAX_DIST || dS < SURFACE_DIST) {
        break;
    }
  }
  return dO;
}

vec3 getNormal(vec3 p) {
  vec2 e = vec2(.01, 0);

  vec3 n = scene(p) - vec3(
    scene(p-e.xyy),
    scene(p-e.yxy),
    scene(p-e.yyx));

  return normalize(n);
}

//can be removed
float getLight(vec3 p) {
    // Light
    vec3 lightPos = vec3(-2.0 * cos(iTime), 4.0, -5. + 2.0 * sin(iTime));
    vec3 l = normalize(lightPos-p);      //Light Dir
    vec3 n = getNormal(p);               //Get Normal Points
    
    float dif = clamp(dot(n,l),0.,1.);
    
    // Shadow (RM from the surface to the light, if blocked shadow its a shadowed surface)
    float shadowRay = rm(p + (n*SHADOW_SURF_DIST),l);
    if(shadowRay < length(lightPos - p)) dif *= 0.8;
    return dif;
}

float getLightNoShadow(vec3 p) {
    // Light
    vec3 lightPos = vec3(-2.0 * cos(iTime), 0.0, -5. + 20.0 * sin(iTime));
    vec3 l = normalize(lightPos-p);      //Light Dir
    vec3 n = getNormal(p);               //Get Normal Points
    
    float dif = clamp(dot(n,l),0.,1.);
    return dif;
}

vec2 rot2D(vec2 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv = uv * 2. - 1.;
    
    vec2 cuv = uv;

    vec3 ro = vec3(0.0, 8.0, 0.);
    ro.z -= T2x*CAMSPEED;
    ro.x -= sin(T4x)*PI*0.5;

    vec3 rd = normalize(vec3(uv, -1.0));
    
    
    rd.yz = rot2D(rd.yz,PI * -sin(T2x)*0.05-0.3);//up/down
    //rd.xz = rot2D(rd.xz,PI * - sin(T2x*.25)); // left/right
    float xr = 0.;
    {
        //shit turning method i cant do it better, 
        //to be fixed: have smth better that either mimics the graph or looks better/is faster.        
        //https://www.desmos.com/calculator/wziodz7a7b my math is bad someone simplify.
        float x = T2x*0.5;
        float sop = sin(x)*PI;
        float b1 = min(sop,0.);
        float b2 = max(sop,0.);
        float t = sin(x + PI)*PI;
        float c = sin((x/3.) + TAU) * PI;
        float c1 = t + b1;
        float c2 = t + b2;
        float u1 = clamp((c*c2/PI),0.,PI);
        float u2 = clamp((c*-c1/PI),-PI,0.);
        float r = u1 + u2;
        xr = r;
        rd.xz = rot2D(rd.xz, r);
    }
    

    float d = rm(ro, rd);
    vec3 p = ro + rd * d;

    vec3 color = vec3(0);


    if(d<MAX_DIST) {
        //color = vec3(sin(T2x)*.5+.75, cos(T4x)*.5+.75, sin(iTime+(PI*0.5))*0.5+0.5) * getLight(p);
        //floor
        float h1 = hash12(floor(p.xz*0.5));
        float h2 = hash12(floor((p.xz+vec2(2))*0.5));
        float h3 = hash12(floor((p.xz+vec2(4))*0.5));
        color = vec3(h1,h2,h3);//* (getLight(p)*2.);
      }else{
      //sky ,PI * - sin(T2x)*0.05-0.3);
          
      //UV SPHERICAL WRAP ATTEMPT: im not sure how to do spherical wrapping properly here so im guna comment it out.
      //maybe somone can help
      //vec3 sp = vec3(...);
      //vec2 SPHUV = vec2(
      //(clamp(((atan(sp.z, sp.x) / PI) + 1.0),0.,1.) / 2.0), 
      //(0.5-(asin(sp.y)/PI)) );
      
      uv.y += PI * - sin(T2x)*0.05;//up/down sync
      //uv.x += PI * - sin(T2x*.25);//left/right sync
      uv.x += xr;


      //float a = hash12(floor((uv+vec2(0))*100.));
      //float b = hash12(floor((uv+vec2(2))*100.));
      //float c = hash12(floor((uv+vec2(4))*100.));
      
      //static star blinking attempt (hmm, not too happy about my choice here but whatever)
      float n1 = hash12(floor((uv+vec2(6))*100.));
      float n2 = hash12(floor((uv+vec2(8))*100.));
      float n3 = smoothstep(n1,n2,sin(T2x*1.)*0.5 + 0.5);
      
      //here you can sin when there are many stars to reduce the amount and when there are less you can do more... keeping that idea for later!
      float t = n2 > 0.95 ? 1. : 0.;
      //color = vec3(a*t,b*t,c*t);
      color = vec3(n3*t);

      //fragColor = vec4(vec3(n3), 1.0);
      //return;
    }
    

    
    d *= .02; //d /= 50.;

    {
        float skytint = smoothstep(-.8,2.,cuv.y + PI * -sin(T2x)*0.05);
        color += vec3(0,0,skytint*2.); //blue uv star only
        //color += vec3(1.,1.,1.); //random star uv color check

        color -= d;
    }
    
    //float fd = 1.-(d*2.);
    //color *= fd;

  color *= sqrt(color);
  fragColor = vec4(vec3(color), 1.0);
}

