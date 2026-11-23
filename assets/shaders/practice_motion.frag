#include <flutter/runtime_effect.glsl>
precision highp float;

uniform vec2 uSize;
uniform float phase;
uniform float motion;
uniform float masked;
uniform sampler2D artwork;
uniform sampler2D matte;
out vec4 fragColor;

float region(vec2 p, vec2 center, vec2 radii) {
  vec2 d = (p - center) / radii;
  return 1. - smoothstep(.06, 1., dot(d, d));
}

// Local inverse warps ease back to the original drawing around each anchor.
vec2 tip(vec2 p, vec2 center, vec2 radii, vec2 travel) {
  return -travel * region(p, center, radii);
}

vec2 radial(vec2 p, vec2 center, vec2 radii, float amount) {
  return -(p - center) * amount * region(p, center, radii);
}

vec2 turn(vec2 p, vec2 pivot, vec2 center, vec2 radii, float angle) {
  vec2 offset = p - pivot;
  vec2 rotated = mat2(cos(angle), -sin(angle), sin(angle), cos(angle)) * offset;
  return (rotated - offset) * region(p, center, radii);
}

vec2 spread(vec2 p, vec2 center, vec2 radius, float amount) {
  return tip(p, center - vec2(radius.x * .63, 0.), radius, vec2(-amount, -amount * .3))
      + tip(p, center + vec2(radius.x * .63, 0.), radius, vec2(amount, -amount * .3));
}

float sweep(vec2 p, vec2 center, vec2 radii, float cycle) {
  vec2 d = (p - center) / radii;
  float distance = d.x + .48 * d.y - .8 * sin(cycle);
  float band = exp(-32. * distance * distance);
  return band * region(p, center, radii) * (.62 + .38 * cos(cycle));
}

vec4 artAt(vec2 p) {
  if (any(lessThan(p, vec2(0.))) || any(greaterThan(p, vec2(1.)))) return vec4(0.);
  vec4 art = texture(artwork, p);
  if (masked > .5) {
    float alpha = texture(matte, p).r;
    art *= smoothstep(.01, .96, alpha);
  }
  return art;
}

// Alpha comes from the same warped coordinates as the colour, keeping all
// edges attached, including narrow rings, petals and fingers.
void main() {
  vec2 p = FlutterFragCoord().xy / uSize;
  float breath = .5 - .5 * cos(phase);
  float sway = sin(phase);
  vec2 delta = vec2(0.);
  float light = 0.;
  float gold = .6;

  if (motion < .5) {  // Hearts and orbit.
    delta = radial(p, vec2(.50,.43), vec2(.49,.34), .18 * breath);
    delta += tip(p, vec2(.31,.28), vec2(.28,.16), vec2(-.028,-.023) * breath);
    light = .42 * sweep(p, vec2(.58,.48), vec2(.44,.19), phase);
  }
  if (motion > 0.5 && motion < 1.5) {  // Birds.
    delta = tip(p, vec2(.24,.35), vec2(.24,.19), vec2(-.060,-.033) * breath);
    delta += tip(p, vec2(.77,.36), vec2(.24,.19), vec2(.056,-.031) * (.5 - .5*cos(phase-.55)));
    delta += tip(p, vec2(.53,.23), vec2(.21,.15), vec2(.008,.014) * sway);
  }
  if (motion > 1.5 && motion < 2.5) {  // Envelope flap and seal.
    delta = tip(p, vec2(.50,.35), vec2(.53,.19), vec2(0.,-.066) * breath);
    light = .45 * sweep(p, vec2(.50,.43), vec2(.21,.15), phase);
  }
  if (motion > 2.5 && motion < 3.5) {  // Key pivots at the loop, tassel trails.
    delta = turn(p, vec2(.48,.15), vec2(.55,.40), vec2(.59,.57), .16 * sway);
    delta += tip(p, vec2(.19,.58), vec2(.20,.25), vec2(.069,.013) * sin(phase-.72));
    light = .39 * sweep(p, vec2(.57,.44), vec2(.35,.42), phase);
  }
  if (motion > 3.5 && motion < 4.5) {  // Bag opens around its rim; coins glint.
    delta = spread(p, vec2(.50,.33), vec2(.40,.22), .058 * breath);
    delta += tip(p, vec2(.50,.35), vec2(.32,.24), vec2(0.,-.036) * breath);
    light = .58 * sweep(p, vec2(.48,.39), vec2(.36,.25), phase);
  }
  if (motion > 4.5 && motion < 5.5) {  // Leaves and seed highlights.
    delta = tip(p, vec2(.18,.33), vec2(.27,.20), vec2(-.065,-.055) * breath);
    delta += tip(p, vec2(.52,.23), vec2(.15,.16), vec2(.026,-.045) * sway);
    light = .37 * sweep(p, vec2(.63,.46), vec2(.28,.25), phase);
  }
  if (motion > 5.5 && motion < 6.5) {  // Sunrise above a still ridge.
    delta = tip(p, vec2(.53,.22), vec2(.30,.135), vec2(0.,-.053) * breath);
    light = .62 * region(p, vec2(.51,.25), vec2(.38,.18)) * breath
          + .30 * sweep(p, vec2(.49,.44), vec2(.50,.22), phase);
  }
  if (motion > 6.5 && motion < 7.5) {  // Mane ripples around an anchored face.
    delta = tip(p, vec2(.17,.39), vec2(.24,.22), vec2(-.057,-.035) * sway);
    delta += tip(p, vec2(.81,.40), vec2(.24,.23), vec2(.057,-.028) * sin(phase-.60));
    delta += tip(p, vec2(.48,.58), vec2(.28,.17), vec2(.029,.031) * sway);
    light = .21 * sweep(p, vec2(.50,.35), vec2(.48,.28), phase);
  }
  if (motion > 7.5 && motion < 8.5) {  // Sun rays; palm and fingers stay joined.
    delta = radial(p, vec2(.52,.27), vec2(.39,.18), .22 * breath);
    delta += turn(p, vec2(.52,.27), vec2(.52,.23), vec2(.41,.14), .20 * sway);
    light = .53 * breath * region(p, vec2(.52,.27), vec2(.36,.19));
  }
  if (motion > 8.5 && motion < 9.5) {  // Rose on the palette.
    delta = radial(p, vec2(.27,.32), vec2(.25,.20), .26 * breath);
    delta += tip(p, vec2(.15,.33), vec2(.20,.15), vec2(-.059,-.031) * breath);
    light = .38 * sweep(p, vec2(.52,.51), vec2(.41,.24), phase);
  }
  if (motion > 9.5 && motion < 10.5) {  // Quill bends from the inkwell.
    delta = turn(p, vec2(.38,.44), vec2(.68,.19), vec2(.48,.30), .23 * sway);
    delta += tip(p, vec2(.84,.10), vec2(.29,.19), vec2(.039,-.041) * sin(phase-.65));
    light = .32 * sweep(p, vec2(.66,.23), vec2(.37,.30), phase);
  }
  if (motion > 10.5 && motion < 11.5) {  // Two sides of the book open from the spine.
    delta = spread(p, vec2(.50,.39), vec2(.43,.25), .074 * breath);
    delta += tip(p, vec2(.49,.24), vec2(.16,.16), vec2(0.,-.049) * breath);
    light = .77 * breath * region(p, vec2(.49,.25), vec2(.19,.16));
  }
  if (motion > 11.5 && motion < 12.5) {  // Cloud lobes drift around a fixed crescent.
    delta = tip(p, vec2(.18,.53), vec2(.32,.22), vec2(-.066,-.038) * breath);
    delta += tip(p, vec2(.77,.53), vec2(.29,.20), vec2(.064,.011) * (.5-.5*cos(phase-.5)));
    light = .31 * sweep(p, vec2(.42,.34), vec2(.37,.26), phase);
  }
  if (motion > 12.5 && motion < 13.5) {  // Floating moon and gilded arch.
    delta = tip(p, vec2(.50,.31), vec2(.54,.30), vec2(0.,-.060) * breath);
    light = .45 * sweep(p, vec2(.51,.60), vec2(.46,.17), phase);
    gold = .25;
  }
  if (motion > 13.5 && motion < 14.5) {  // Orb turns above its fixed stand.
    delta = turn(p, vec2(.50,.35), vec2(.49,.34), vec2(.37,.23), .20 * sway);
    light = .70 * sweep(p, vec2(.49,.33), vec2(.39,.24), phase);
    gold = .0;
  }
  if (motion > 14.5 && motion < 15.5) {  // Lotus opens from the outside in.
    delta = spread(p, vec2(.50,.43), vec2(.44,.20), .095 * breath);
    delta += tip(p, vec2(.50,.26), vec2(.31,.18), vec2(0.,-.068) * (.5-.5*cos(phase-.72)));
    light = .43 * region(p, vec2(.52,.43), vec2(.25,.17)) * breath;
  }
  if (motion > 15.5 && motion < 16.5) {  // Stones settle in sequence; small petal lifts.
    delta = tip(p, vec2(.49,.23), vec2(.30,.15), vec2(.026,-.043) * breath);
    delta += tip(p, vec2(.47,.36), vec2(.43,.14), vec2(0.,-.026) * (.5-.5*cos(phase-.50)));
    delta += tip(p, vec2(.76,.60), vec2(.25,.13), vec2(.036,-.045) * sway);
    light = .28 * sweep(p, vec2(.53,.42), vec2(.45,.33), phase);
  }
  if (motion > 16.5 && motion < 17.5) {  // Cloud ribbons uncurl beneath the moon.
    delta = spread(p, vec2(.53,.54), vec2(.36,.20), .080 * breath);
    delta += tip(p, vec2(.79,.48), vec2(.29,.18), vec2(.035,-.039) * sway);
    light = .37 * sweep(p, vec2(.44,.32), vec2(.35,.28), phase);
  }
  if (motion > 17.5 && motion < 18.5) {  // Morning rays only, above the palm.
    delta = radial(p, vec2(.57,.35), vec2(.33,.27), .22 * breath);
    delta += turn(p, vec2(.57,.35), vec2(.57,.29), vec2(.35,.23), .24 * sway);
    light = .58 * breath * region(p, vec2(.57,.35), vec2(.35,.27));
  }
  if (motion > 18.5 && motion < 19.5) {  // Steam curls out of the mug.
    delta = tip(p, vec2(.772,.479), vec2(.09,.105), vec2(.019,-.012) * sway);
    light = .26 * sweep(p, vec2(.76,.47), vec2(.12,.09), phase);
  }
  if (motion > 19.5 && motion < 20.5) {  // The pillow slowly settles; moon catches light.
    delta = tip(p, vec2(.45,.54), vec2(.41,.36), vec2(0.,.052) * breath);
    delta += spread(p, vec2(.48,.54), vec2(.33,.25), .025 * breath);
    light = .46 * sweep(p, vec2(.69,.34), vec2(.31,.29), phase);
  }
  if (motion > 20.5 && motion < 21.5) {  // Open on inhale, close on exhale.
    delta = tip(p, vec2(.255,.486), vec2(.24,.41), vec2(-.066,0.) * breath);
    delta += tip(p, vec2(.739,.491), vec2(.24,.41), vec2(.066,0.) * breath);
    delta += radial(p, vec2(.492,.537), vec2(.23,.23), .18 * breath);
    light = .38 * breath * region(p, vec2(.49,.53), vec2(.24,.23));
    gold = .15;
  }
  if (motion > 21.5 && motion < 22.5) {  // Feather tip flexes, air curl lags behind.
    delta = turn(p, vec2(.28,.67), vec2(.72,.35), vec2(.44,.45), .22 * sway);
    delta += tip(p, vec2(.20,.47), vec2(.26,.24), vec2(-.061,-.039) * sin(phase-.65));
    light = .31 * sweep(p, vec2(.58,.47), vec2(.45,.34), phase);
  }
  if (motion > 22.5 && motion < 23.5) {  // The wrist is stable while drops follow the flick.
    delta = turn(p, vec2(.22,.63), vec2(.56,.36), vec2(.44,.31), .14 * sway);
    delta += tip(p, vec2(.801,.613), vec2(.10,.13), vec2(.023,.043) * breath);
    delta += tip(p, vec2(.874,.733), vec2(.10,.14), vec2(.026,.050) * (.5-.5*cos(phase-.70)));
    light = .34 * sweep(p, vec2(.81,.66), vec2(.25,.23), phase);
  }
  if (motion > 23.5 && motion < 24.5) {  // The ball rolls; the arch stays attached to the foot.
    delta = turn(p, vec2(.41,.77), vec2(.41,.80), vec2(.21,.17), .39 * sway);
    delta += tip(p, vec2(.46,.67), vec2(.27,.16), vec2(.027,.010) * sway);
    light = .50 * sweep(p, vec2(.41,.79), vec2(.24,.21), phase);
  }
  if (motion > 24.5 && motion < 25.5) {  // Hands move around a breathing cloud.
    delta = turn(p, vec2(.21,.28), vec2(.37,.26), vec2(.35,.19), .22 * sway);
    delta += turn(p, vec2(.80,.75), vec2(.61,.75), vec2(.35,.20), -.21 * sway);
    delta += radial(p, vec2(.495,.522), vec2(.37,.20), .19 * breath);
    light = .43 * sweep(p, vec2(.48,.52), vec2(.39,.22), phase);
  }
  if (motion > 25.5) {  // A light passes over the studs without bending the boards.
    light = .70 * sweep(p, vec2(.51,.50), vec2(.59,.58), phase);
    gold = .85;
  }

  vec4 art = artAt(p + delta);
  vec3 tint = mix(vec3(.55,.65,1.), vec3(1.,.72,.41), gold);
  art.rgb += (art.a - art.rgb) * tint * light;
  fragColor = art;
}
