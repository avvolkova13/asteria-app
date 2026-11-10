#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 uSize;
uniform float phase;
uniform sampler2D lotus;
out vec4 fragColor;

float closure(float lag) {
  float cycle = fract(phase / 6.2831853);
  float start = .14 * lag;
  float crest = .415 + .10 * lag;
  float end = .94 + .06 * lag;
  float opening = clamp((cycle - start) / (crest - start), 0., 1.);
  float settling = clamp((cycle - crest) / (end - crest), 0., 1.);
  // Zero velocity at the start, crest and end of each petal's movement.
  return 1. + .5 * (cos(3.14159265 * opening) - cos(3.14159265 * settling));
}

// Smoothly reduce a tip's displacement to zero as it meets its base.
vec2 tip(vec2 at, vec2 center, vec2 radius, vec2 travel, float lag) {
  vec2 delta = (at - center) / radius;
  float influence = 1. - smoothstep(0., 1., dot(delta,delta));
  return influence * travel * 1.14 * closure(lag);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 at = (uv - .5) / .92 + .5;
  vec2 sampleAt = at;
  float x = at.x - .5;
  float wing = smoothstep(.10,.46,abs(x));
  float upper = 1. - smoothstep(.24,.91,at.y);
  float outer = closure(.14);
  sampleAt.x += x * .115 * wing * upper * outer;
  sampleAt.y += .035 * wing * upper * outer;
  // Lower rim first, then the tall side petals and the inner cup.
  sampleAt += tip(at,vec2(.055,.72), vec2(.18,.20), vec2(-.031,.041), .00);
  sampleAt += tip(at,vec2(.945,.65), vec2(.18,.20), vec2( .030,.039), .14);
  sampleAt += tip(at,vec2(.14,.36), vec2(.16,.22), vec2(-.030,.024), .27);
  sampleAt += tip(at,vec2(.89,.30), vec2(.15,.23), vec2( .028,.024), .38);
  sampleAt += tip(at,vec2(.24,.18), vec2(.13,.23), vec2(-.020,.014), .47);
  sampleAt += tip(at,vec2(.75,.20), vec2(.14,.21), vec2( .018,.015), .56);
  sampleAt += tip(at,vec2(.33,.38), vec2(.13,.19), vec2(-.016,.022), .70);
  sampleAt += tip(at,vec2(.70,.39), vec2(.12,.19), vec2( .014,.022), .78);
  sampleAt += tip(at,vec2(.51,.49), vec2(.10,.12), vec2( .003,.018), .96);
  // The safety margin remains transparent, including under texture clamping.
  if (any(lessThan(sampleAt,vec2(0.))) || any(greaterThan(sampleAt,vec2(1.)))) {
    fragColor = vec4(0.);
  } else {
    fragColor = texture(lotus,sampleAt);
  }
}
