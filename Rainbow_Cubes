//View on shadertoy > https://www.shadertoy.com/view/lcsGDB

//NOTE: THIS WAS ORIGNALLY DONE ON UNITY AND MOVED OVER TO SHADERTOY FOR FUN!
//THIS IS ALSO NOT OPTIMIZED!
#define DEBUG 0.0
//#define DEBUG 0.0 = FOR FULL IMAGE
//#define DEBUG 1.0 = FOR VIEWING NORMALS & "DEPTH BUFFER"
//MAC = PRESS (CMD + ENTER) TO COMPILE AFTER CHANGING DEBUG
//WINDOWS = PRESS (ALT + ENTER) TO COMPILE AFTER CHANGING DEBUG

//source
#define PI 3.1415
#define TAU 6.2831
#define MAX_DIST 100.0
#define MIN_SURF_DIST 0.001
#define MAX_STEPS 100

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

//IMPORTANT: GET DISTANCE IS USED TO GET THE DISTANCE OF EVERYTHING IN THE SCENE, SO IF YOU WANT TO ADD MORE OBJECTS, YOU NEED TO ADD IT HERE.
//THIS IS KEY WHEN UNDERSTANDING HOW RAYMARCHING ACTUALLY WORKS. The raymarching algortihim is so simple tbh but understanding distances is 10x more important.
float GetDistance(vec3 distancePoint)
{   
    vec4 _SpherePos = vec4(0.,0.5,8.0,0.5);
    vec3 sp = _SpherePos.xyz;
    sp.x += sin(iTime*2.) * 2.;
    //sp.z += sin(iTime*2.)+(iTime);
    float dSphere = length(distancePoint - (sp)) - _SpherePos.w;
    float dPlane = distancePoint.y;// REFERENCE NOTE 1 // for some reason i had a hard time understanding just (dPlane = distancePoint.y).
    
    distancePoint.z += iTime;
    distancePoint.y += sin(distancePoint.z*4. + iTime*5.)*0.1;
    vec3 q = fract(distancePoint)-0.5;
    
    q.z = mod(distancePoint.z, 0.3) - 0.15;
    //q.y += sin(distancePoint.z *4. + iTime*1.) * 0.2 +0.2;//this causing the artifacting
    

    float dbox = sdBox(q,0.025 + vec3(float(cos((distancePoint.z*2.) + iTime*3.) * 0.05+0.05)));
    
    //float dbox = length(q - float3(0.01,0.01,0.01)) - 0.1;
    

    float distanceToScene = min(dbox,min(dSphere, dPlane));         //get min from the 2 objects so we dont step into something we dont want to.
    //float distanceToScene = min(dSphere, dPlane);
    
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



vec2 rot2D(vec2 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}


float rm (vec3 rayOrigin, vec3 rayDirection)
{
    float dO = 0.0; //Distance from Origin
    float dS = 0.0; //Distance from Scene
    for (int i = 0; i < MAX_STEPS; i++)
    {
        vec3 p = rayOrigin + rayDirection * dO;             // standard point calculation dO is the offset for direction or magnitude
        //p.xy += rot2D(p.xy, p); //rotate the scene
        //p.y += sin(p.z * 4. + iTime*3.)*0.1;
        dS = GetDistance(p);                             
        dO += dS;
        if (dS < MIN_SURF_DIST || dO > MAX_DIST) break;            // if we are close enough to a surface or went to infinity, break & return distance to the origin
    }
    return dO;
}

float GetLight(vec3 p)
{
    vec4 _LightPos = vec4(.0,7.,8.,8.);
    _LightPos.xz += vec2(sin(iTime*2.),cos(iTime*2.))*_LightPos.w;
    vec3 lightDir = normalize(_LightPos.xyz - p).xyz;
    vec3 normal = GetNormals(p);

    float dotNL = clamp(dot(normal, lightDir),0.,1.);
    float d = rm(p + normal * (MIN_SURF_DIST * 2.), lightDir);
    if (d < length(lightDir)) 
    {
        dotNL *= smoothstep(0.9, 1., d / length(lightDir));
        //dotNL *= 0.1;
    }

    return dotNL;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec2 cuv = uv * 2. - 1.;
    vec4 _CameraOrigin = vec4(0.0,2.0,1.0,1.0);
    vec3 ro = _CameraOrigin.xyz;
    //ro.z += (iTime);
    ro.xy += vec2(sin(iTime*0.5) * 2.,cos(iTime*1.) * 1.);

    vec3 rd = normalize(vec3(cuv.xy,1));

    rd.z += rot2D(rd.xy, iTime).x * 0.5;
    rd.xy += rot2D(rd.xy, iTime) * 0.2;
    rd = normalize(rd);

    float distanceRM = rm(ro, rd);//i.camPos
    //return (distanceRM)*0.01;

    //if(distanceRM > MAX_DIST) return float4(0,0.4,0.8,1);//skybox
    vec3 p = ro + rd * distanceRM;
    //return float4(abs(p.rrr/50),1);
    
    vec3 tCol = palette(distanceRM + iTime*2.,vec3(0.7, 0.5, 0.5),vec3(0.5, 0.2, 0.9),vec3(1.0, 0.5, 0.3),vec3(0.09, 0.33, 0.67));
    //fragColor = vec4(tCol,1);
    
    
    vec3 light = vec3(GetLight(p));
    //fragColor = vec4(light,1);
    //return;

    light -= (light * (distanceRM*0.05));
    light += (distanceRM*0.04) + tCol.xyz;
    vec3 diff = GetNormals(p); //test normals


    if(cuv.x < (1. - DEBUG)){ 
        fragColor = vec4(light * vec3(1,1,1),1);
        return;
    } else {
        if(cuv.y < 0.){fragColor = vec4(diff,1.); return;}
        fragColor = vec4(vec3((distanceRM*0.01)),1.);
        return;
    }

            
}
