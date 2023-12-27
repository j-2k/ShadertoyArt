<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta http-equiv="Content-Style-Type" content="text/css">
  <title></title>
  <meta name="Generator" content="Cocoa HTML Writer">
  <meta name="CocoaVersion" content="2487.2">
  <style type="text/css">
    p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica; -webkit-text-stroke: #000000}
    p.p2 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica; -webkit-text-stroke: #000000; min-height: 14.0px}
    span.s1 {font-kerning: none}
  </style>
</head>
<body>
<p class="p1"><span class="s1">//learning reflecting rays via https://www.shadertoy.com/view/4dt3zn</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">//Kings reflection Checkpoint 1</span></p>
<p class="p1"><span class="s1">#define DEBUG 0.0</span></p>
<p class="p1"><span class="s1">//#define DEBUG 0.0 = FOR FULL IMAGE</span></p>
<p class="p1"><span class="s1">//#define DEBUG 1.0 = FOR VIEWING NORMALS &amp; "DEPTH BUFFER"</span></p>
<p class="p1"><span class="s1">//MAC = PRESS (CMD + ENTER) TO COMPILE AFTER CHANGING DEBUG</span></p>
<p class="p1"><span class="s1">//WINDOWS = PRESS (ALT + ENTER) TO COMPILE AFTER CHANGING DEBUG</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">//source</span></p>
<p class="p1"><span class="s1">#define PI 3.1415</span></p>
<p class="p1"><span class="s1">#define TAU 6.2831</span></p>
<p class="p1"><span class="s1">#define MAX_DIST 100.0</span></p>
<p class="p1"><span class="s1">#define MIN_SURF_DIST 0.0001</span></p>
<p class="p1"><span class="s1">#define MAX_STEPS 150.</span></p>
<p class="p1"><span class="s1">//CHANGE THIS TO HALF TO OPTIMIZE(MAX_STEPS*0.5)</span></p>
<p class="p1"><span class="s1">#define MAX_REFLECTION_STEPS (MAX_STEPS*1.)</span></p>
<p class="p1"><span class="s1">#define T iTime</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">//palette by inigo quilez</span></p>
<p class="p1"><span class="s1">vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )</span></p>
<p class="p1"><span class="s1">{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return a + b*cos( 6.28318*(c*t+d) );</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">//sdf box inigo quilez</span></p>
<p class="p1"><span class="s1">float sdBox( vec3 p, vec3 b )</span></p>
<p class="p1"><span class="s1">{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 q = abs(p) - b;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">float GetDistance(vec3 distancePoint)</span></p>
<p class="p1"><span class="s1">{<span class="Apple-converted-space">   </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec4 _SpherePos = vec4(0.,1.,6.0,1.);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 sp = _SpherePos.xyz;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//sp.x += sin(iTime*2.) * 2.;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float dSphere = length(distancePoint - (sp)) - _SpherePos.w;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>sp.xyz += vec3(2.,-0.5,0.5);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float dSphere2 = length(distancePoint - (sp)) - _SpherePos.w*0.5;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float dPlane = dot(distancePoint,normalize(vec3(0.,1.,0.)));</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//sin(distancePoint.z)*0.5+0.5;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float distanceToScene = min(dSphere2,min(dSphere, dPlane));</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return distanceToScene;</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">vec3 GetNormals(vec3 p)</span></p>
<p class="p1"><span class="s1">{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float d = GetDistance(p);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec2 e = vec2(0.001, 0);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 normals = d - vec3(</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">      </span>GetDistance(p - e.xyy),</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">      </span>GetDistance(p - e.yxy),</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">      </span>GetDistance(p - e.yyx)</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return normalize(normals);</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">vec2 rot2D(vec2 p, float a)</span></p>
<p class="p1"><span class="s1">{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float c = cos(a);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float s = sin(a);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return vec2(p.x * c - p.y * s, p.x * s + p.y * c);</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">float rm (vec3 rayOrigin, vec3 rayDirection, float MaxSteps)</span></p>
<p class="p1"><span class="s1">{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float dO = 0.0; //Distance from Origin</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float dS = 0.0; //Distance from Scene</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>for (float i = 0.; i &lt; MaxSteps; i++)</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">        </span>vec3 p = rayOrigin + rayDirection * dO; <span class="Apple-converted-space">            </span>// standard point calculation dO is the offset for direction or magnitude</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">        </span>//p.xy += rot2D(p.xy, p); //rotate the scene</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">        </span>//p.y += sin(p.z * 4. + iTime*3.)*0.1;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">        </span>dS = GetDistance(p);<span class="Apple-converted-space">                             </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">        </span>if (abs(dS) &lt; MIN_SURF_DIST || dO &gt; MAX_DIST) break;<span class="Apple-converted-space">            </span>// if we are close enough to a surface or went to infinity, break &amp; return distance to the origin</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">        </span>dO += dS;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>}</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return dO;</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">float GetLight(vec3 p,vec4 _LightPos)</span></p>
<p class="p1"><span class="s1">{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>_LightPos.xz += vec2(sin(iTime*2.),cos(iTime*2.))*_LightPos.w;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 lightDir = normalize(_LightPos.xyz - p).xyz;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 normal = GetNormals(p);</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float dotNL = clamp(dot(normal, lightDir),0.,1.);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float d = rm(p + (normal * MIN_SURF_DIST *2.), lightDir, MAX_STEPS);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>if (d &lt; length(lightDir))<span class="Apple-converted-space"> </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">        </span>dotNL *= smoothstep(0.9, 1., d / length(lightDir));</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return dotNL;</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">vec3 getObjectColor(vec3 p){</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float size = 0.5;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec2 gridId = floor(p.xz*size);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 index = (mod(gridId.x+gridId.y,2.) &gt; 0.) ? vec3(0.93,0.93,0.82):vec3(0.46,0.58,0.33);//1. : 0.;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>if(p.y&gt;0.1)</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>{return vec3(.0,.0,2.);}</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>else</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>{return vec3(0.8);}</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return index;</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">vec3 ColorScene(in vec3 hitEP,in vec3 rd,in vec3 n,in vec4 lp, float t)</span></p>
<p class="p1"><span class="s1">{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//Lighting</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 lDir = lp.xyz - hitEP;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float lDist = max(length(lDir),0.001);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>lDir/= lDist;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float atten = 1.-lDist*0.1;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//float atten = 1. / (1. + lDist*.2 + lDist*lDist*.1);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float dotNL = clamp(dot(n,lDir),0.,1.);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//DIFFUSE LIGHT = N DOT L</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float diffuse = max(dotNL, 0.);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//SPECULAR LIGHT (check phong lighting)</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float specular = pow(max(dot(reflect(lDir,n),rd),0.),100.);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//Shadow RM | s = distance from hitEP to light/blocked areas</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float s = rm(hitEP + (n * MIN_SURF_DIST *2.),lDir, MAX_STEPS);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>if(s &lt; length(lDir))</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">         </span>dotNL *= smoothstep(0.7, 1., s);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">         </span>//return vec3(0,0,1);//shows the shaded area on the sphere &amp; the floor behind the sphere to light</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">         </span>//we dont want that, we need to shade the floor and do so via dot</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">         </span>//return vec3(dotNL);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>}</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>// Coloring all Objects</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 objCol = getObjectColor(hitEP);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">   </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//vec3 sceneColors = (objCol*diffuse*(dotNL*0.5+0.5)) + (vec3(1., 1., .2) * specular);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 sceneColors = ((objCol*(diffuse+0.1)*(dotNL*0.5+0.5)) + (vec3(1., 1., .2) * specular )) * atten;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float depth = smoothstep(0.,1.,t*0.03);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return vec3(depth);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return vec3(mix(sceneColors, vec3(0.,0.1,0.2),depth));</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return clamp(vec3(mix(sceneColors, vec3(0.,0.1,0.2),depth)),0.,1.);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return vec3(specular + diffuse);// + vec3(0,0,0.3);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return vec3(specular + diffuse * dotNL + objCol);// + objCol);</span></p>
<p class="p1"><span class="s1">}</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1">void mainImage( out vec4 fragColor, in vec2 fragCoord )</span></p>
<p class="p1"><span class="s1">{</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>// Normalized pixel coordinates (from 0 to 1)</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec2 uv = fragCoord/iResolution.xy;</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec2 cuv = uv * 2. - 1.;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 ro = vec3(0.,2.,1.);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//fragColor=vec4(1)*1.-iMouse.z;</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 rd = normalize(vec3(cuv.xy,1.));</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>rd.xz = vec2(rot2D(rd.xz,(sin(T*1.5)*0.25 * (1. - clamp(iMouse.z,0.,1.)) ) + ( clamp(iMouse.z,0.,1.) * (3.14 - iMouse.x*0.01)) ));//sin(T*1.2)*0.2));</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 col = vec3(0.);</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//1st raymarch</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float hitDist = rm(ro, rd, MAX_STEPS);//first hit an object or extend to inf</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return (distanceRM)*0.01;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//col += hit1*0.1;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//if(distanceRM &gt; MAX_DIST)<span class="Apple-converted-space">  </span>{fragColor = vec4(0,0.4,0.8,1);return;}//skybox</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 hitPos = ro + rd * hitDist;//</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//fragColor=vec4(abs(p.zzz/50.),1);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//fragColor = vec4(vec3(distanceRM/50.),1.);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec4 _LightPos = vec4(2.,2. + sin(T*2.),5.,8.);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//vec3 light = vec3(GetLight(hit1point,_LightPos));</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//fragColor = vec4(light,1);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 normalsHit = GetNormals(hitPos); //test normals</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//fragColor = vec4(normalsHit,1);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//return;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//get first scene colors, hit1point , rd, normalsHit, light position, hit1</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 sceneColors = ColorScene(hitPos,rd,normalsHit,_LightPos,hitDist);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//REFLECTION RAY 2nd pass</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>rd = reflect(rd,normalsHit);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//2nd raymarch</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float hitRef = rm(hitPos + (normalsHit * MIN_SURF_DIST *2.),rd,MAX_REFLECTION_STEPS);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//point of contact of the reflected ray</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>vec3 refHitPoint = hitPos + rd * hitRef;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>normalsHit = GetNormals(refHitPoint);</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>sceneColors += ColorScene(refHitPoint,rd,normalsHit,_LightPos,hitRef)*.3;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>//fake ambient occulusion based on the reflection ray</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>float fAO = smoothstep(.0,0.4,hitRef);//pow(smoothstep(.0,0.4,hitRef),1.)</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>sceneColors *= fAO;</span></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">    </span></span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>fragColor = vec4(sceneColors * vec3(1,1,1),1);</span></p>
<p class="p1"><span class="s1"><span class="Apple-converted-space">    </span>return;</span></p>
<p class="p2"><span class="s1"></span><br></p>
<p class="p2"><span class="s1"><span class="Apple-converted-space">            </span></span></p>
<p class="p1"><span class="s1">}</span></p>
</body>
</html>
