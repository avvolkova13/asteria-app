#include <flutter/runtime_effect.glsl>
precision highp float;

uniform vec2 uSize;
uniform float phase;
uniform float scene;
out vec4 fragColor;

const float tau = 6.2831853;

float haze(vec2 p, vec2 center, vec2 radius) {
  vec2 delta = (p - center) / radius;
  return exp(-dot(delta, delta) * 1.65);
}

float ridge(float x, float center, float width) {
  float distanceToRidge = (x - center) / width;
  return exp(-distanceToRidge * distanceToRidge);
}

float hash(vec2 p) {
  return fract(52.9829189 * fract(dot(p, vec2(.06711056, .00583715))));
}

vec3 dawn(vec2 p) {
  float sway = sin(phase);
  vec3 sky = mix(vec3(.13,.084,.22), vec3(.53,.27,.39), haze(p,vec2(.4,.52),vec2(.92,.65)));
  sky += vec3(.52,.30,.12) * haze(p,vec2(.42+.12*sway,.51),vec2(.55,.24));
  sky += vec3(.15,.10,.11) * ridge(p.y,.49+.03*sin(p.x*4.+phase),.04);
  for (int i = 0; i < 3; i++) {
    float layer = float(i);
    float a = phase * (i == 1 ? -1. : 1.) + layer * 1.5;
    float edge = .62 + .09 * layer +
      (.035+.009*layer) * sin(p.x*(4.8+layer*.7)+a) +
      .015 * cos(p.x*8.-a);
    float depth = max(0.,p.y-edge);
    vec3 clay = mix(vec3(.65,.37,.49),vec3(.30,.19,.43),layer/2.);
    clay *= mix(1.15,.41,smoothstep(0.,.24,depth));
    clay += vec3(.30,.20,.17) * ridge(depth,.012,.023) *
      (.55+.41*sin(p.x*4.+a));
    sky = mix(sky,clay,smoothstep(-.006,.016,p.y-edge));
  }
  return sky;
}

vec3 dusk(vec2 p) {
  float sweep = sin(phase);
  vec3 plum = vec3(.10,.066,.16);
  plum += vec3(.29,.13,.25) *
    haze(p,vec2(.54+.23*sweep,.41-.06*cos(phase)),vec2(.56,.47));
  float light = ridge(p.x,.51+.35*sweep-(p.y-.42)*.83,.158);
  plum += vec3(.35,.16,.13) * light *
    haze(p,vec2(.53,.43),vec2(.67,.40));
  float edge = .71 + .032*sin(p.x*7.-phase);
  plum += vec3(.29,.10,.17) * ridge(p.y,edge,.038) *
    haze(p,vec2(.51-.17*sweep,.70),vec2(.86,.18));
  return plum;
}

vec3 stars(vec2 p, float strength) {
  vec3 light = vec3(0.);
  for (int i = 0; i < 2; i++) {
    float layer = float(i);
    vec2 shift = vec2(sin(phase+layer*1.4),cos(phase-layer*1.8)) * (.30+.13*layer);
    vec2 grid = p * vec2(15.+10.*layer,26.+15.*layer) + shift;
    vec2 tile = floor(grid);
    float seed = hash(tile);
    vec2 center = vec2(.15+.70*seed,.16+.67*hash(tile.yx+5.));
    float spark = 1. - smoothstep(.015,.11+.035*seed,length(fract(grid)-center));
    light += vec3(.52,.43,.80) * spark * step(.67,seed) *
      (.43+.33*sin(phase+seed*16.));
  }
  return light*strength;
}

vec4 moon(vec2 p) {
  float sway = sin(phase);
  vec3 night = vec3(.14,.095,.29);
  night += vec3(.33,.22,.68) * haze(p, vec2(.61-.11*sway,.38), vec2(.64,.42));
  night += stars(p,1.);
  float wisps = ridge(p.y,.64 + .05*sin(5.*p.x-phase),.034)*
    haze(p,vec2(.47+.10*sway,.62),vec2(.65,.20));
  night += vec3(.17,.15,.40)*wisps;
  return vec4(night*.56,.56);
}

vec3 bloom(vec2 p) {
  vec3 water = vec3(.084,.13,.22);
  water += vec3(.11,.31,.30) * haze(p,vec2(.52,.52),vec2(.80,.51));
  float rays = 0.;
  for (int i = 0; i < 3; i++) {
    float n = float(i);
    float beamX = .30 + n*.16 + (p.y-.25)*(.24+.09*n) + .054*sin(phase+n*1.3);
    rays += ridge(p.x,beamX,.040+n*.012) * (.60+.40*cos(phase+n));
  }
  water += vec3(.13,.26,.22)*rays*haze(p,vec2(.55,.41),vec2(.70,.55));
  vec2 surface = (p - vec2(.53,.645)) * vec2(1.,4.4);
  float radius = length(surface);
  for (int i = 0; i < 4; i++) {
    float progress = fract(phase/tau + float(i)*.25);
    float ring = ridge(radius,.08+progress*.62,.007+progress*.014);
    water += vec3(.31,.51,.43) * ring * sin(progress*3.14159265) * .48;
  }
  return water + stars(p + vec2(.1,.2),.24);
}

vec3 silk(vec2 p) {
  vec3 color = vec3(.11,.065,.18) +
    vec3(.26,.10,.24)*haze(p,vec2(.60-.14*sin(phase),.56),vec2(.74,.51));
  color += vec3(.065,.04,.13)*ridge(p.x,.55+p.y*.30+.18*cos(phase),.19);
  for (int i = 0; i < 3; i++) {
    float layer = float(i);
    float a = phase * (i == 1 ? -1. : 1.) + layer*1.72;
    float center = .67+layer*.056 - (p.x-.45)*(.24+layer*.045) +
      (.032+layer*.010)*sin(p.x*(4.9+layer*.4)+a);
    float halfWidth = .071+.025*sin(p.x*4.+a+1.);
    float across = (p.y-center)/halfWidth;
    float edge = 1. - smoothstep(.79,1.03,abs(across));
    float fold = .35+.65*ridge(across,-.32+.11*sin(p.x*7.+a),.43);
    vec3 material = mix(vec3(.55,.36,.69),vec3(.89,.53,.59),layer/2.);
    vec3 sheen = vec3(.92,.67,.87)*ridge(across,-.56,.115)*.28;
    color = mix(color,material*fold+sheen,edge*(.29+layer*.065));
  }
  return color;
}

void main() {
  vec2 p = FlutterFragCoord().xy/uSize;
  if (scene < .5) fragColor = vec4(dawn(p),1.);
  else if (scene < 1.5) fragColor = vec4(dusk(p),1.);
  else if (scene < 2.5) fragColor = moon(p);
  else if (scene < 3.5) fragColor = vec4(bloom(p),1.);
  else fragColor = vec4(silk(p),1.);
}
