//learning reflecting rays via https://www.shadertoy.com/view/4dt3zn
//kings reflection on shader toy https://www.shadertoy.com/view/lflGD2

//DEBUG "false" or "true" to see other info
//REFLECTION 0. TO 1. (default 0.7)
//COLORS 0. OR 1. to make kings scroll through colors
#define DEBUG false 
#define REFLECTION 0.6
#define COLORS 0. 
//MAC = PRESS (CMD + ENTER) TO COMPILE AFTER CHANGING DEBUG
//WINDOWS = PRESS (ALT + ENTER) TO COMPILE AFTER CHANGING DEBUG

//source
#define PIHALF 1.5707
#define PI 3.1415
#define TAU 6.2831
#define MAX_DIST 100.0
#define MIN_SURF_DIST 0.0001
#define MAX_STEPS 90.
//CHANGE THIS TO HALF TO OPTIMIZE(MAX_STEPS*0.5)
#define MAX_REFLECTION_STEPS (MAX_STEPS*.9)
#define T iTime

float s01(float s)
{return (sin(T * s) *0.5 +0.5);}
vec2 rot2D(vec2 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

//hash12 by dave hoskins 
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

//=vvv=sdfs & palette by Inigo Quilez=vvv=
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}
float sdBox( vec3 p, vec3 b )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}
float sdRoundedCylinder( vec3 p, float ra, float rb, float h )
{
  vec2 d = vec2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
}
float sdCone(vec3 p, vec3 a, vec3 b, float ra, float rb)
{
    float rba  = rb-ra;
    float baba = dot(b-a,b-a);
    float papa = dot(p-a,p-a);
    float paba = dot(p-a,b-a)/baba;

    float x = sqrt( papa - paba*paba*baba );

    float cax = max(0.0,x-((paba<0.5)?ra:rb));
    float cay = abs(paba-0.5)-0.5;

    float k = rba*rba + baba;
    float f = clamp( (rba*(x-ra)+paba*baba)/k, 0.0, 1.0 );

    float cbx = x-ra - f*rba;
    float cby = paba - f;
    
    float s = (cbx < 0.0 && cay < 0.0) ? -1.0 : 1.0;
    
    return s*sqrt( min(cax*cax + cay*cay*baba,
                       cbx*cbx + cby*cby*baba) );
}
float opSmoothUnion( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

float sdfs(vec3 p, float r)
{
    return length(p)-r;
}
//=^^^=sdfs & palette by Inigo Quilez=^^^=


float GetDistance(vec3 distancePoint)
{   
    /*
    vec4 _SpherePos = vec4(0.,1.,6.0,1.);
    vec3 sp = _SpherePos.xyz;
    //sp.x += sin(iTime*2.) * 2.;
    float dSphere = length(distancePoint - (sp)) - _SpherePos.w;
    sp.xyz += vec3(2.,-0.5,0.5);
    float dSphere2 = length(distancePoint - (sp)) - _SpherePos.w*0.5;
    */
    float dPlane = dot(distancePoint,normalize(vec3(0.,1.,0.)));
    // + sin(distancePoint.z)*0.5+0.5;
    
    
    vec3 p = distancePoint;
    
    
    vec3 q = p;//fract(p)-0.5;
    //q.xz = fract(p.xz)-0.5;
    //q.xz = mod(p.xz, 4.)-2.;
    
    //q.y -= 1.;
    //vec3 of = vec3(0);//vec3(0.,1.5 + sin(T*2.),0.);
    
    float fs = sdfs((q-vec3(0.,1.5 + sin(T*2.),0.)),0.3);
    //p.xz = fract(p.xz*.5)-.5;
    //p.xz *= 2.;
    p.xz = mod(distancePoint.xz, 2.)-1.;
    //p.xz *= 1.;
    //p.y = mod(distancePoint.y, 8.);


    p.y -= 1.75*sin(length((vec2(1,1)-distancePoint.xz)*.5)-(T*2.))*0.5+.75;
    //p.y -=  length(distancePoint.xz*sin(T)*0.5+0.5);
    
    vec2 gridId = floor(distancePoint.xz*0.5);
    //vec3 index = (mod(gridId.x+gridId.y,2.) > 0.) ? vec3(0.93,0.93,0.82):vec3(0.46,0.58,0.33);//1. : 0.;
    float index = (mod(gridId.x+gridId.y,2.) > 0.) ? 1. : 0.;////
    
    //p.y += mix(index,1.-index, sin(iTime)*0.5+0.5);
    if(floor(length(distancePoint.xz)) > 12.)// || (length(distancePoint.y)) > 100.  )//(distancePoint.xz)
    {
        return min(fs,dPlane);
        //return min(dSphere2,min(dSphere, min(fs,dPlane)));
    }
    
    if((q.x > 0. && q.x < 2.)&&(q.z < 2. && q.z > 0.)){p*=.9;p.yz = rot2D(p.yz,sin(T*2.)*0.05);
    p.xz = rot2D(p.xz,T*2.);p.xy = rot2D(p.xy,sin(T*1.5)*0.05);
    }
    
    //p.y += mix(index,1.-index, sin(iTime)*0.5+0.5);
    vec3 k = -vec3(-1.2,0,4.);
    //send king to origin
    k = vec3(0);
    
    float base = opSmoothUnion(sdRoundedCylinder(p - vec3(0,0.2,0)+k,.25,.1,.1),
    sdRoundedCylinder(p - vec3(0,.6,0)+k,.2 - ((p.y*p.y)*0.09),.026,.2),0.2);
    
    float mid = opSmoothUnion(sdRoundedCylinder(p - vec3(0,1.7,0)+k,.15 - (log(p.y*2.)*0.05),.02,1.),base,0.05);
    
    float midTop = opSmoothUnion(opSmoothUnion(sdRoundedCylinder(p - vec3(0,2.2,0)+k,.15,.03,.015),
    sdRoundedCylinder(p - vec3(0,2.3,0)+k,.11,.06,.02),0.09),mid,0.1);
    
    float topCone = opSmoothUnion(
    opSmoothUnion(sdRoundedCylinder(p - vec3(0,2.7,0)+k,.11,.03,.02),mid,0.05)
    ,sdCone(p - vec3(0,2.7,0)+k,
    vec3(0.,.6,0.),
    vec3(0.,0.,0.),
    0.3,0.15),0.1);
    
    float topHat = opSmoothUnion(
    min(sdRoundBox(p - vec3(0,3.5,0)+k,vec3(0.03,0.3,0.05),0.02),
    sdRoundBox(p - vec3(0,3.6,0)+k,vec3(0.15,0.05,0.05),0.02)),
    topCone,
    0.1);//cone x rect merge
    float distanceToScene = min(topHat,min(midTop,min(mid,min(base,min(fs,dPlane)))));
    //float distanceToScene = min(topHat,min(midTop,min(mid,min(base,min(dSphere2,min(dSphere,min(fs,dPlane)))))));
    
    return distanceToScene;
}


vec3 GetNormals(vec3 p)
{
    float d = GetDistance(p);
    vec2 e = vec2(0.001, 0);
    
    vec3 normals = d - vec3(
      GetDistance(p - e.xyy),
      GetDistance(p - e.yxy),
      GetDistance(p - e.yyx)
    );
    return normalize(normals);
}






float rm (vec3 rayOrigin, vec3 rayDirection, float MaxSteps)
{
    float dO = 0.0; //Distance from Origin
    float dS = 0.0; //Distance from Scene
    for (float i = 0.; i < MaxSteps; i++)
    {
        vec3 p = rayOrigin + rayDirection * dO;             // standard point calculation dO is the offset for direction or magnitude
        //p.xy += rot2D(p.xy, p); //rotate the scene
        //p.y += sin(p.z * 4. + iTime*3.)*0.1;
        dS = GetDistance(p);                             
        if (abs(dS) < MIN_SURF_DIST || dO > MAX_DIST) break;            // if we are close enough to a surface or went to infinity, break & return distance to the origin
        dO += dS*0.9;
    }
    return dO;
}

vec3 getObjectColor(vec3 p){
    
    float size = 0.5;
    vec2 gridId = floor(p.xz*size);
    vec3 index = (mod(gridId.x+gridId.y,2.) > 0.) ? vec3(0.93,0.93,0.82)*2.:vec3(0.46,0.58,0.33)*1.;//1. : 0.;
    
    if(p.y>0.1){
        if((p.x > 0.3 && p.x < 2.)&&(p.z < 2. && p.z > 0.3)){return vec3(10,10,0);}
        //return vec3( hash12(floor(p.xz))*2.,hash12(floor(p.zx))*1.6,hash12(floor(p.xx))*3.4 );
        
        
        /*
        vec3 l = vec3(p/length(p));
        return (1. * l) * ((1. - COLORS) + (0. + COLORS)*
        ((sin(T)+2.)*palette(length(p.yy*PIHALF)  + iTime*5.,vec3(0.7, 0.5, 0.5),vec3(0.5, 0.2, 0.9),vec3(1.0, 0.5, 0.3),vec3(0.09, 0.33, 0.67))));
        */
        
        return 1.*((1. - COLORS) + (0. + COLORS)*
        ((sin(T)+2.)*palette(length(p.yy*PIHALF)  + iTime*5.,vec3(0.7, 0.5, 0.5),vec3(0.5, 0.2, 0.9),vec3(1.0, 0.5, 0.3),vec3(0.09, 0.33, 0.67))));
        
    }
    
    
    return index;
}

vec3 ColorScene(in vec3 hitEP,in vec3 rd,in vec3 n,in vec4 lp, float t,vec2 uv)
{
    //Lighting
    vec3 lDir = lp.xyz - hitEP;
    float lDist = max(length(lDir),0.001);
    lDir/= lDist;
    //float atten = 1.-lDist*0.1;
    float atten = 1. / (1. + lDist*.2 + lDist*lDist*.1);
    
    float dotNL = clamp(dot(n,lDir),0.,1.);
    
    //DIFFUSE LIGHT = N DOT L
    float diffuse = max(dotNL, 0.);
    
    //SPECULAR LIGHT (check phong lighting)
    float specular = pow(max(dot(reflect(lDir,n),rd),0.),80.);
    
    //Shadow RM | s = distance from hitEP to light/blocked areas
    float s = rm(hitEP + (n * MIN_SURF_DIST *2.),lDir, MAX_STEPS);
    if(s < length(lDir))
    {
         dotNL *= smoothstep(0.7, 1., s);
         //return vec3(0,0,1);//shows the shaded area on the sphere & the floor behind the sphere to light
         //we dont want that, we need to shade the floor and do so via dot
         //return vec3(dotNL);
    }
    

    
    // Coloring all Objects
    vec3 objCol = getObjectColor(hitEP);
    
   
    //vec3 sceneColors = (objCol*diffuse*(dotNL*0.5+0.5)) + (vec3(1., 1., .2) * specular);
    vec3 sceneColors = ((objCol*(diffuse+0.2)*(1.*dotNL*0.5+0.5)) + (vec3(1., 1., .2) * specular )) * (atten*1.);
    
    float depth = smoothstep(0.,1.,t*0.02);

    //vec3 p = palette(length(1.*PIHALF)  + iTime*5.,vec3(0.7, 0.5, 0.5),vec3(0.5, 0.2, 0.9),vec3(1.0, 0.5, 0.3),vec3(0.09, 0.33, 0.67));
    //return sceneColors;
    //return vec3(depth*1.);
    //return vec3(mix(sceneColors, vec3(0.3,.0,0.3) ,depth*0.4 ));
    //return clamp(vec3(mix(sceneColors, vec3(.1,.1,0.2),depth)),0.,1.);
    //return vec3(specular + diffuse);// + vec3(0,0,0.3);
    
    if(DEBUG == false)
    {
        return vec3(mix(sceneColors, vec3(0.3,.0,0.3) ,depth*.5 ));
    }
    else
    {
        if(uv.x>(sin(T)*0.33+.66))
        {return vec3(sceneColors);}
        else if (uv.x>(sin(T)*0.33+.33))
        {return vec3(mix(sceneColors, vec3(0.3,.0,0.3) ,depth*.5 ));}
        else
        {return vec3(depth);}
    }

    
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec2 cuv = uv * 2. - 1.;
    //cuv.x*=1.2;
    vec3 ro = vec3(0.0,6.,0.);
    
    
    //fragColor=vec4(1)*1.-iMouse.z;
    //return;
    
    vec3 rd = normalize(vec3(cuv.xy,1.));
    int rot = 1;
    if(rot == 1)
    {
        //rd.xz = vec2(rot2D(rd.xz,(sin(T*1.5)*0.25 * (1. - clamp(iMouse.z,0.,1.)) ) + ( clamp(iMouse.z,0.,1.) * (3.14 - iMouse.x*0.01)) ));//sin(T*1.2)*0.2));
        //rd.yz = vec2(rot2D(rd.yz, -PIHALF + clamp(PI*(iMouse.y/iResolution.y),0.,PI) ));
        //rd.yz = vec2(rot2D(rd.yz,PI*0.2));
        ro.z += -6. - sin(T)*.6;
        rd.yz = vec2(rot2D(rd.yz,0.3+(PI*0.15)*s01(1.)));
        ro.xz = vec2(rot2D(ro.xz,T*0.6));
        //rd.xz += vec2(rot2D(rd.xz,(sin(T*1.5)*0.25 * (1. - clamp(iMouse.z,0.,1.)) ) + ( clamp(iMouse.z,0.,1.) * (3.14 - iMouse.x*0.01)) ));//sin(T*1.2)*0.2));
        rd.xz = vec2(rot2D(rd.xz,T*0.6));
        ro.y += sin((T*1.))*1.;
        //ro.yz = vec2(rot2D(ro.yz,T));
    }
    else
    {
        rd.yz = vec2(rot2D(rd.yz,PI*0.5));
        ro.xz += vec2(-10.+(iMouse.x*0.03),-10. + ((iMouse.y*0.04)));
        ro.y += 5.;
        if(iMouse.z > 0.5){ro.y = ro.y - 2.;;}
    }


    
    vec3 col = vec3(0.);

    //1st raymarch
    float hitDist = rm(ro, rd, MAX_STEPS);//first hit an object or extend to inf
    //return (distanceRM)*0.01;
    
    //col += hit1*0.1;
    

    //if(distanceRM > MAX_DIST)  {fragColor = vec4(0,0.4,0.8,1);return;}//skybox
    
    vec3 hitPos = ro + rd * hitDist;//
    //fragColor=vec4(abs(p.zzz/50.),1);
    //fragColor = vec4(vec3(distanceRM/50.),1.);
    //return;
    //if((p.x > 0. && p.x < 2.)&&(p.z < 4. && p.z > 2.))
    vec4 _LightPos = vec4(1,3. + (sin(T*3.)*2.),1,8.);//orig 2 height + sin
    //vec3 light = vec3(GetLight(hit1point,_LightPos));
    //fragColor = vec4(light,1);
    //return;
    
    vec3 normalsHit = GetNormals(hitPos); //test normals
    //fragColor = vec4(normalsHit,1);
    //return;
    
    //get first scene colors, hit1point , rd, normalsHit, light position, hit1
    vec3 sceneColors = ColorScene(hitPos,rd,normalsHit,_LightPos,hitDist,uv);
    
    //REFLECTION RAY 2nd pass
    rd = reflect(rd,normalsHit);
    
    //2nd raymarch
    float hitRef = rm(hitPos + (normalsHit * MIN_SURF_DIST *2.),rd,MAX_REFLECTION_STEPS);
    
    //point of contact of the reflected ray
    vec3 refHitPoint = hitPos + rd * hitRef;
    
    normalsHit = GetNormals(refHitPoint);
    
     //i think this method is garb for ao not sure, fake ambient occulusion based on the reflection ray
    float fAO = smoothstep(.0,1.,hitRef);//pow(smoothstep(.0,0.4,hitRef),1.)
    sceneColors *= vec3(clamp(fAO+0.3,0.,1.));
    
    sceneColors += ColorScene(refHitPoint,rd,normalsHit,_LightPos,hitRef,uv) * (REFLECTION);
    
    //gamma correction commented by spalmer
    //sceneColors = pow(sceneColors, vec3(.4545)); //with gamma correction colors are off & need some work so i will keep it off untill i fix it.
    

    fragColor = vec4(sceneColors * vec3(1,1,1),1);
    return;

            
}
