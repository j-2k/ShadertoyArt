//learning reflecting rays via https://www.shadertoy.com/view/4dt3zn
//MAC = PRESS (CMD + ENTER) TO COMPILE AFTER CHANGING DEBUG
//WINDOWS = PRESS (ALT + ENTER) TO COMPILE AFTER CHANGING DEBUG

//source
#define PI 3.1415
#define TAU 6.2831
#define MAX_DIST 100.0
#define MIN_SURF_DIST 0.0001
#define MAX_STEPS 100.
//CHANGE THIS TO HALF TO OPTIMIZE(MAX_STEPS*0.5)
#define MAX_REFLECTION_STEPS (MAX_STEPS*1.)
#define T iTime

//palette by inigo quilez
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

//sdf box inigo quilez
float sdBox( vec3 p, vec3 b )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
//sdf round cyclinder inigo quilez
float sdRoundedCylinder( vec3 p, float ra, float rb, float h )
{
  vec2 d = vec2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
}

float opSmoothUnion( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}


float GetDistance(vec3 distancePoint)
{   
    vec4 _SpherePos = vec4(0.,1.,6.0,1.);
    vec3 sp = _SpherePos.xyz;
    //sp.x += sin(iTime*2.) * 2.;
    float dSphere = length(distancePoint - (sp)) - _SpherePos.w;
    sp.xyz += vec3(2.,-0.5,0.5);
    float dSphere2 = length(distancePoint - (sp)) - _SpherePos.w*0.5;
    float dPlane = dot(distancePoint,normalize(vec3(0.,1.,0.)));
    // + sin(distancePoint.z)*0.5+0.5;
    
    
    vec3 p = distancePoint;
    
    /*
    //float ds = length(p - vec3(-1,0.3,4))-(sin(p.z*2. + T)*0.1+0.3);
    float c1 = sdRoundedCylinder(p - vec3(-1.2,0.2,4),
    .3 - clamp(p.y*0.1,0.,.3)
    ,.1,.1);
    float c2 = sdRoundedCylinder(p - vec3(-1.2,0.4,4),
    .24 + clamp(p.y*0.09,0.,.1)
    ,.1,.1);
    //float base = min(c1,c2);
    
    
    float su = opSmoothUnion(c1,c2,0.01);//min(c1,c2);//
    */
    float b1 = opSmoothUnion(sdRoundedCylinder(p - vec3(-1.2,0.3,4),.25,.1,.2),
    sdRoundedCylinder(p - vec3(-1.2,.8,4),.2,.1,.2),0.2);
    

    float distanceToScene = min(b1,min(dSphere2,min(dSphere, dPlane)));

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



vec2 rot2D(vec2 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
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
        dO += dS;
    }
    return dO;
}

float GetLight(vec3 p,vec4 _LightPos)
{
    _LightPos.xz += vec2(sin(iTime*2.),cos(iTime*2.))*_LightPos.w;
    vec3 lightDir = normalize(_LightPos.xyz - p).xyz;
    vec3 normal = GetNormals(p);

    float dotNL = clamp(dot(normal, lightDir),0.,1.);
    float d = rm(p + (normal * MIN_SURF_DIST *2.), lightDir, MAX_STEPS);
    if (d < length(lightDir)) 
    {
        dotNL *= smoothstep(0.9, 1., d / length(lightDir));
    }

    return dotNL;
}

vec3 getObjectColor(vec3 p){
    
    float size = 0.5;
    vec2 gridId = floor(p.xz*size);
    vec3 index = (mod(gridId.x+gridId.y,2.) > 0.) ? vec3(0.93,0.93,0.82):vec3(0.46,0.58,0.33);//1. : 0.;
    
    if(p.y>0.1)
    {return vec3(1.0,1.0,1.);}
    
    return index;
}

vec3 ColorScene(in vec3 hitEP,in vec3 rd,in vec3 n,in vec4 lp, float t)
{
    //Lighting
    vec3 lDir = lp.xyz - hitEP;
    float lDist = max(length(lDir),0.001);
    lDir/= lDist;
    float atten = 1.-lDist*0.1;
    //float atten = 1. / (1. + lDist*.2 + lDist*lDist*.1);
    
    float dotNL = clamp(dot(n,lDir),0.,1.);
    
    //DIFFUSE LIGHT = N DOT L
    float diffuse = max(dotNL, 0.);
    
    //SPECULAR LIGHT (check phong lighting)
    float specular = pow(max(dot(reflect(lDir,n),rd),0.),100.);
    
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
    vec3 sceneColors = ((objCol*(diffuse+0.1)*(dotNL*0.5+0.5)) + (vec3(1., 1., .2) * specular )) * atten;
    
    float depth = smoothstep(0.,1.,t*0.04);
    

    
    
    //return vec3(depth);
    return vec3(mix(sceneColors, vec3(0.,0.1,0.2),depth));
    //return clamp(vec3(mix(sceneColors, vec3(0.,0.1,0.2),depth)),0.,1.);
    //return vec3(specular + diffuse);// + vec3(0,0,0.3);
    //return vec3(specular + diffuse * dotNL + objCol);// + objCol);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec2 cuv = uv * 2. - 1.;
    vec3 ro = vec3(0.,1.5,1.);
    
    
    
    //fragColor=vec4(1)*1.-iMouse.z;
    //return;
    
    vec3 rd = normalize(vec3(cuv.xy,1.));
    rd.xz = vec2(rot2D(rd.xz,(sin(T*1.5)*0.25 * (1. - clamp(iMouse.z,0.,1.)) ) + ( clamp(iMouse.z,0.,1.) * (3.14 - iMouse.x*0.01)) ));//sin(T*1.2)*0.2));
    //to rot on the x axis do rd.yz
    
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
    
    vec4 _LightPos = vec4(2.,2. + sin(T*2.),5.,8.);
    //vec3 light = vec3(GetLight(hit1point,_LightPos));
    //fragColor = vec4(light,1);
    //return;
    
    vec3 normalsHit = GetNormals(hitPos); //test normals
    //fragColor = vec4(normalsHit,1);
    //return;
    
    //get first scene colors, hit1point , rd, normalsHit, light position, hit1
    vec3 sceneColors = ColorScene(hitPos,rd,normalsHit,_LightPos,hitDist);
    
    //REFLECTION RAY 2nd pass
    rd = reflect(rd,normalsHit);
    
    //2nd raymarch
    float hitRef = rm(hitPos + (normalsHit * MIN_SURF_DIST *2.),rd,MAX_REFLECTION_STEPS);
    
    //point of contact of the reflected ray
    vec3 refHitPoint = hitPos + rd * hitRef;
    
    
    
    normalsHit = GetNormals(refHitPoint);
    
    sceneColors += ColorScene(refHitPoint,rd,normalsHit,_LightPos,hitRef)*.33;
    
    //fake ambient occulusion based on the reflection ray
    float fAO = smoothstep(.0,0.4,hitRef);//pow(smoothstep(.0,0.4,hitRef),1.)
    sceneColors *= fAO;
    


    fragColor = vec4(sceneColors * vec3(1,1,1),1);
    return;

            
}
