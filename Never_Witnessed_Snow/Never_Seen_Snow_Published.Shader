//ref from https://www.shadertoy.com/view/4dSXDK
#define time0 (iTime*0.1)
#define time1 (iTime)
#define time2 (iTime*10.)
#define snowlayers 6.
#define ITERS 6
//Dave Hoskins 1x1 hash
float hash11(float p)
{p = fract(p * .1031); p *= p + 33.33; p *= p + p; return fract(p);}
//Dave Hoskins 1x2 hash
float hash12(vec2 p)
{vec3 p3  = fract(vec3(p.xyx) * .1031);p3 += dot(p3, p3.yzx + 33.33);return fract((p3.x + p3.y) * p3.z);}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    uv.x *= iResolution.x / iResolution.y;
    
    float s = 0.;
    for(float i = 1.; i < snowlayers + 1.; i++)
    {
        vec2 suv = uv;
        float n = (i/snowlayers);
        suv.x -= time0 * ((1. + i)*1.5);
        suv.y += time0 * 5.;

        //make a better ramp method iuc
        float ramp = 50. * n;// - (i*20.);
        suv *= ramp;
        
        float r = hash12(floor(suv + (i * 10.)));
        
        s = r > 0.96 ? n : s;
    }
    
    s += 0.3;
    
    float topmask = smoothstep(0.2, 0., uv.y);
    s -= topmask / 5.;
    
    float botsnow = smoothstep(0.3, 0., uv.y);
    s += botsnow;
    
    vec3 snow = vec3(s,s,1);
    fragColor = vec4(snow,1.0);
}
