//https://www.shadertoy.com/view/wXdXRn
//Debugs: Only enable 1 at a time.
#define testDepth   0
#define testNormals 0
#define testLights  0
//Turning test clouds off will show bare bones raymarcher (unneeded for the most part, leaving it here so I can steal it again for the future)
#define testClouds  1


//Positions & Vars
#define sunPosition vec3(10,10,-1)
#define RAYORIGIN vec3(0.0,1,-5.0);
#define ZOOM 1.3

//Math
#define PIHALF 1.5707
#define PI 3.1415
#define TAU 6.2831

//RM
#define MAX_DIST 200.0
#define MIN_SURF_DIST 0.001
//PERFORMANCE HEAVY
#define MAX_STEPS 80
#define MARCH_SIZE 0.15

//Resources
//https://www.shadertoy.com/view/WdXGRj
//https://www.shadertoy.com/view/lss3zr
//https://blog.maximeheckel.com/posts/real-time-cloudscapes-with-volumetric-raymarching/
//https://shaderbits.com/blog/creating-volumetric-ray-marcher 






mat2 rotate2D(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat2(c, -s, s, c);
}

vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((x*(a*x + b)) / (x*(c*x + d) + e), 0.0f, 1.0f);
}


//inigo quilez sdf

float nextStep(float t, float len, float smo) {
  float tt = mod(t += smo, len);
  float stp = floor(t / len) - 1.0;
  return smoothstep(0.0, smo, tt) + stp;
}

float sdSphere(vec3 p, float radius) {
  return length(p) - radius;
}

float sdTorus(vec3 p, vec2 r) {
  float x = length(p.xz) - r.x;
  return length(vec2(x, p.y)) - r.y;
}

float sdCross(in vec3 p, in float s)
{
  float da = max(abs(p.x), abs(p.y));
  float db = max(abs(p.y), abs(p.z));
  float dc = max(abs(p.z), abs(p.x));
  return min(da, min(db, dc)) - s;
}

//====dave=hoskins=hash===
float hash(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
//====dave=hoskins=hash===

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );
              
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    
    f += 0.2500*noise( p ); p = m*p*2.03;
    
    f += 0.12500*noise( p ); p = m*p*2.01;
    
    f += 0.06250*noise( p );
    return f;
}


//
float GetDistance(vec3 distancePoint)
{   
    vec3 p = distancePoint;
    
    vec4 _SpherePos = vec4(0.,0.5,0.0,.5);
    vec3 sp = _SpherePos.xyz;
    //sp.x += sin(iTime*2.) * 2.;
    float dSphere = length(p - (sp)) - _SpherePos.w;
    float dPlane = p.y;
    

    float distanceToScene = min(dSphere, dPlane);         //get min from the 2 objects so we dont step into something we dont want to.
    return distanceToScene; //distance to scene is the distance scalar from ANYTHING in the scene
}


//in order to get normals on complex objects that have a curve on them its fairly simple, you have to sample 2 points inifi close to each other and 
//draw a line between them, effectively the slope & then you get the normal from that line!
vec3 GetNormals(vec3 p)
{
    float d = GetDistance(p);
    vec2 e = vec2(0.001, 0);
    
    
    vec3 normals = d - vec3(
      GetDistance(p - e.xyy),
      GetDistance(p - e.yxy),
      GetDistance(p - e.yyx)
    );
    
    
        /*trying to understand how partial derivatives work, slightly missing how this gives you a correct normal vector
        same as above but with partial derivatives
        float df_dx = (d - GetDistance(p - e.xyy));
        float df_dy = (d - GetDistance(p - e.yxy));
        float df_dz = (d - GetDistance(p - e.yyx));
        return normalize(float3(df_dx, df_dy, df_dz));
        */

        //ok now i kind of understand, after tons of images and desmos trials but a simple summary is to compare the distances of the shifted points (shifting the points means the whole sphere will move with it!) 
        //to the original points in the 4 quadrants. (the result from [original distance point] - [shifted distance point] is you get a x and y value that is the vector/correct color gradient to be used as the normal! ) 
        //here is a extremely bad drawing of what i was doing and figured it out? https://prnt.sc/DQRrOrAIYs1c i might still be wrong but the idea at least is in my head now. will revisit this later.
        //Im not sure if my thinking is right but help is needed understanding partial derivatives and how you obtain normals with them. Any explanations in the comments would help.
    return normalize(normals);
}


float rm (vec3 rayOrigin, vec3 rayDirection)
{
    float dO = 0.0; //Distance from Origin
    float dS = 0.0; //Distance from Scene
    for (int i = 0; i < MAX_STEPS; i++)
    {
        vec3 p = rayOrigin + rayDirection * dO;             // standard point calculation dO is the offset for direction or magnitude
        dS = GetDistance(p);                             
        dO += dS;
        if (dS < MIN_SURF_DIST || dO > MAX_DIST) break;     // if we are close enough to a surface or went to infinity, break & return distance to the origin
    }
    return dO;
}


float cloudMap(vec3 pM) {

    vec3 p = pM;

    // Handle Mouse Input
    vec2 mouse = iMouse.xy / iResolution.xy * 2.0 - 1.0;
    mouse.x *= iResolution.x / iResolution.y;  // Aspect correction

    // no fancy rayplane intersection here, probably will save that for another idea
    if(iMouse.z > 0.0) { //if you grab the cloud it idles and moves with mouse
        p.x -= mouse.x * 5.;
        p.y -= mouse.y * 7.5;
        p.z += mouse.y * 7.5;
                    }else{// else go around in a tiny circle ish shape
       p.x += sin(iTime*4.)*.3;
       p.y += cos(iTime*4.)*.15;
    }
    


  

  float f = fbm(p + (iTime*0.33));
  vec3 os = vec3(0,-4,0);
  vec3 p1 = p;
  p1 += os;
  p1.xz *= rotate2D(PI * .33 + iTime * 0.22);
  p1.yz *= rotate2D(PI * 1. + iTime * 1.3);

  
  float s1 = 1. - sdTorus(p1, vec2(3., -0.5)) + f*1.;
  float s2 = 1. - sdCross(p1 * 2., .3) + f*2.;
  float s3 = 1. - sdSphere(p+os, .3) + f*2.;
  float s4 = 1. - length(p * vec3(0.35, 1., 0.35)+os) + f*2.;//sdCapsule(p1, vec3(-1.0, -1., 0.0), vec3(1.0, 1., 0.0), .5);

  float t = mod(nextStep(iTime, 3., 0.5), 4.0);

  float distance = mix(s1, s2, clamp(t, 0.0, 1.0));
  distance = mix(distance, s3, clamp(t - 1.0, 0.0, 1.0));
  distance = mix(distance, s4, clamp(t - 2.0, 0.0, 1.0));
  distance = mix(distance, s1, clamp(t - 3.0, 0.0, 1.0));
  
  //float distance = sdSphere(p+vec3(0,-1,0), 1.);

 return distance;// -distance + f; //f being here was not as nice as having them in shapes themselves as you can control how much fbm each shape has which is nice!
 
}

vec4 rmc(vec3 rayOrigin, vec3 rayDirection, float blueNoiseOffset) {


  float depth = 0.0;
  depth += MARCH_SIZE * blueNoiseOffset;
  vec3 p = rayOrigin + depth * rayDirection;
  vec3 sunDirection = normalize(sunPosition);
  vec4 res = vec4(0.0);
  
  for (int i = 0; i < MAX_STEPS; i++) {
    float density = cloudMap(p);
    // We only draw the density if it's greater than 0
    if (density > 0.0) {
      float diffuse = clamp((cloudMap(p) - cloudMap(p + 0.3 * sunDirection)) / 0.3, 0.0, 1.0 );
      vec3 lin = vec3(0.60,0.60,0.75) * 1.1 + 0.8 * vec3(1.0,0.6,0.3) * diffuse;
      
      vec4 color = vec4(mix(vec3(1.0,1.0,1.0), vec3(0.0, 0.0, 0.0), density), density );
      color.rgb *= lin;
      
      color.rgb *= color.a;
      res += color * (1.0 - res.a);
    }
    
    depth += MARCH_SIZE;
    p = rayOrigin + depth * rayDirection;
  }
  return res;
}


float GetLight(vec3 p)
{
    vec4 _LightPos = vec4(.0,5.,5.,5.);
    _LightPos.xz += vec2(sin(iTime*2.),cos(iTime*2.))*_LightPos.w;
    vec3 lightDir = normalize(_LightPos.xyz - p).xyz;
    vec3 normal = GetNormals(p);

    float dotNL = clamp(dot(normal, lightDir),0.,1.);
    float lightDist = rm(p + normal * (MIN_SURF_DIST * 2.), lightDir);
    if (lightDist < length(lightDir)) 
    {
        dotNL *= smoothstep(0.8, 1., lightDist / length(lightDir));
    }

    return dotNL;
}

vec3 ColorObjects(vec3 p){
    
    float size = 2.;
    vec2 gridId = floor(p.xz*size);
    vec3 index = (mod(gridId.x+gridId.y,2.) > 0.) ? vec3(1):vec3(0);//vec3(hash32(gridId)):vec3(hash32(gridId));//1. : 0.;
    
    if(p.y>MIN_SURF_DIST){
        return vec3(1);
    }
    //if(length(p) > MAX_DIST){}
    
    return index;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy * 2. - 1.;
    float ratio = iResolution.x/iResolution.y;
    uv *= ratio;
    


    
    //Camera
    vec3 ro = RAYORIGIN
    vec3 rd = normalize(vec3(uv.xy,ZOOM));
    #if testClouds==1
    ro.y -= 2.;
    rd.yz *= rotate2D(PI * -0.25);
    #endif
    
    //Parse BlueNoise
    float bn = texture(iChannel0,uv).r;
    //float offset = fract(bn + float(iFrame%32) / sqrt(0.5));
    float offset = fract(bn);
    
    //Raymarch Clouds
    vec4 clouds = rmc(ro,rd,offset);
    #if testClouds==1
    //float trl = 0.4 *smoothstep(1.5,-3.,.9 * length(uv+vec2(-ratio,-ratio)));
    vec3 bg = mix(vec3(0.3,0.6,0.95),vec3(0.),clouds.a)*.7
    + mix(vec3(0.12,0.33,0.94),vec3(0.),uv.y*0.5)*.3;
    float bgy = (mix(0.,.4,uv.y*0.25+(ratio*0.1275)));
    


    vec3 sunDirection = normalize(sunPosition);
    float sun = clamp(dot(sunDirection, rd), 0.0, 1.0);
    vec3 sCol = .6 * vec3(1.,0.73,0.51) * pow(sun, 10.0);
    
    vec3 final = clouds.xyz + (bg + bgy + sCol);// + trl; 
    
    //final = sqrt(final);
    //final = ACESFilm(final);
    final = pow(final, vec3(1.0 / 2.2));

    fragColor = vec4(vec3(final),1);
    return;
    #endif
    

    //Raymarch Objects
    float t = rm(ro, rd); //hit distance/mag (depth)    
    vec3 p = ro + rd * t; //get hit mag + dir
    
    //Light & Coloring the Scene
    vec3 light = vec3(GetLight(p));
    light -= (light * (t*0.03));
    vec3 getColors = ColorObjects(p);
    
    //Output
    vec3 fc = getColors * light; //+ clouds.xyz;



    
    //Debugs
    {
        /*
        if(uv.x < (ratio - DEBUG)){ 
        fragColor = vec4(fc,1);
        return;
        } else {
            if(uv.y < (sin(iTime*4.)*0.4)){fragColor = vec4(GetNormals(p),1.); return;}
            fragColor = vec4(vec3((t*0.01)),1.);
            return;
        }
        */
        #if testDepth==1
        t *= 0.1; //output only t to see depth buffer like view
        fragColor = vec4(t,t,t,1);
        return;
        #endif
        
        #if testNormals==1
        fragColor = vec4(GetNormals(p),1);
        return;
        #endif
        
        #if testLights==1
        t *= 0.1; //output only t to see depth buffer like view
        fragColor = vec4(light,1);
        return;
        #endif
    }
    

    
    fragColor = vec4(fc,1);
}
