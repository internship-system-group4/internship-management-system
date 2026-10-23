import * as THREE from '../vendor/three.module.min.js';
import { ATMOSPHERE_GLSL, NOISE_GLSL } from './jisr-common.js';

// Scene -> HDR target (MSAA + depth)
//   -> SSAO (half res, blurred) -> atmosphere (AO, height fog, mist)
//   -> sun shafts (radial blur of the visible sky) + two-level bloom
//   -> filmic tone map, grade, vignette, grain -> screen.
const quadVS = 'varying vec2 vUv; void main(){ vUv = uv; gl_Position = vec4(position.xy, 0.0, 1.0); }';
const VIEW_FROM_DEPTH = /* glsl */`
 uniform sampler2D tDepth; uniform mat4 uInvProj;
 vec3 viewPos(vec2 uv) { float d = texture2D(tDepth, uv).r; vec4 v = uInvProj * vec4(uv * 2.0 - 1.0, d * 2.0 - 1.0, 1.0); return v.xyz / v.w; }
`;

export function createPost(renderer, { quality = 'high' } = {}) {
 const sceneRT = new THREE.WebGLRenderTarget(1, 1, { type: THREE.HalfFloatType, samples: quality === 'high' ? 4 : 2, depthTexture: new THREE.DepthTexture(1, 1, THREE.UnsignedIntType) });
 const make = (type = THREE.HalfFloatType) => new THREE.WebGLRenderTarget(1, 1, { type, depthBuffer: false });
 const atmosphereRT = make(), brightRT = make(), blurA = [make(), make()], blurB = [make(), make()], aoRT = [make(THREE.UnsignedByteType), make(THREE.UnsignedByteType)], raysRT = [make(), make()];
 const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1), quad = new THREE.Mesh(new THREE.PlaneGeometry(2, 2)), scene = new THREE.Scene();
 quad.frustumCulled = false; scene.add(quad);
 const shader = (uniforms, fragmentShader) => new THREE.ShaderMaterial({ uniforms, vertexShader: quadVS, fragmentShader, depthTest: false, depthWrite: false });
 const invProj = { value: new THREE.Matrix4() }, proj = { value: new THREE.Matrix4() }, depthTex = { value: sceneRT.depthTexture };

 // Alchemy-style SSAO from depth only (normals rebuilt from neighbouring depth samples).
 const ao = shader({ tDepth: depthTex, uInvProj: invProj, uProj: proj, uRadius: { value: 2.4 }, uTexel: { value: new THREE.Vector2() }, uSamples: { value: quality === 'high' ? 14 : 8 } }, /* glsl */`
  ${VIEW_FROM_DEPTH}
  uniform mat4 uProj; uniform float uRadius; uniform vec2 uTexel; uniform int uSamples; varying vec2 vUv;
  float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
  void main() {
   float d = texture2D(tDepth, vUv).r;
   if (d >= 0.99999) { gl_FragColor = vec4(1.0); return; }
   vec3 P = viewPos(vUv);
   vec3 px = viewPos(vUv + vec2(uTexel.x, 0.0)) - P, py = viewPos(vUv + vec2(0.0, uTexel.y)) - P;
   vec3 nx = viewPos(vUv - vec2(uTexel.x, 0.0)) - P, ny = viewPos(vUv - vec2(0.0, uTexel.y)) - P;
   vec3 N = normalize(cross(abs(px.z) < abs(nx.z) ? px : -nx, abs(py.z) < abs(ny.z) ? py : -ny));
   float radius = uRadius * (1.0 + smoothstep(60.0, 400.0, -P.z) * 3.0);
   float rScreen = radius * uProj[1][1] / -P.z * 0.5;
   float occ = 0.0, ang = hash(gl_FragCoord.xy) * 6.2831;
   for (int i = 0; i < 16; i++) {
    if (i >= uSamples) break;
    float t = (float(i) + 0.5) / float(uSamples);
    float a = ang + float(i) * 2.39996;
    vec2 off = vec2(cos(a), sin(a)) * rScreen * t * vec2(uTexel.x / uTexel.y, 1.0);
    vec3 S = viewPos(vUv + off);
    vec3 v = S - P;
    float vv = dot(v, v);
    occ += max(0.0, dot(v, N) + P.z * 0.002) / (vv + 0.01 * radius * radius) * smoothstep(radius * radius * 4.0, 0.0, vv);
   }
   occ = clamp(1.0 - occ * 2.0 * radius / float(uSamples), 0.0, 1.0);
   gl_FragColor = vec4(vec3(pow(occ, 1.4)), 1.0);
  }`);

 const atmosphereUniforms = {
  tColor: { value: sceneRT.texture }, tDepth: depthTex, tAO: { value: aoRT[1].texture }, uInvProj: invProj, uCamWorld: { value: new THREE.Matrix4() }, uAO: { value: 1 },
  uCamPos: { value: new THREE.Vector3() }, uDensity: { value: .00024 }, uFalloff: { value: .0045 }, uMist: { value: .6 }, uTime: { value: 0 }, uSunColor: { value: new THREE.Color() },
  uSunDir: { value: new THREE.Vector3() }, uZenith: { value: new THREE.Color() }, uHorizon: { value: new THREE.Color() }, uSunGlow: { value: new THREE.Color() }, uGround: { value: new THREE.Color() }, uSkyI: { value: 1 }
 };
 const atmosphere = shader(atmosphereUniforms, /* glsl */`
  ${ATMOSPHERE_GLSL}
  ${NOISE_GLSL}
  ${VIEW_FROM_DEPTH}
  uniform sampler2D tColor; uniform sampler2D tAO; uniform mat4 uCamWorld; uniform vec3 uCamPos; uniform float uAO;
  uniform float uDensity; uniform float uFalloff; uniform float uMist; uniform float uTime; uniform vec3 uSunColor; uniform float uSkyI;
  varying vec2 vUv;
  void main() {
   vec3 col = texture2D(tColor, vUv).rgb;
   float depth = texture2D(tDepth, vUv).r;
   if (depth >= 0.99999) { gl_FragColor = vec4(col, 1.0); return; }
   col *= mix(1.0, texture2D(tAO, vUv).r, uAO);
   vec3 view = viewPos(vUv);
   vec3 world = (uCamWorld * vec4(view, 1.0)).xyz;
   vec3 ray = world - uCamPos; float dist = length(ray); vec3 dir = ray / dist;
   float ry = abs(dir.y) < 1e-4 ? 1e-4 : dir.y;
   float optical = uDensity * exp(-uFalloff * uCamPos.y) * (1.0 - exp(-uFalloff * ry * dist)) / (uFalloff * ry);
   float mist = jFbm3(world.xz * 0.0028 + vec2(uTime * 0.004, uTime * 0.0017));
   float low = exp(-max(world.y, 0.0) * 0.08);
   optical += uMist * low * smoothstep(0.42, 0.85, mist) * min(dist, 1200.0) * 0.00034;
   float fog = 1.0 - exp(-optical);
   vec3 fogCol = atmosphere(normalize(vec3(dir.x, max(dir.y, 0.0) * 0.35, dir.z))) * uSkyI;
   float fogL = dot(fogCol, vec3(0.2126, 0.7152, 0.0722)); fogCol *= min(1.0, 1.6 / max(fogL, 1e-3));
   fogCol += uSunColor * pow(max(dot(dir, uSunDir), 0.0), 16.0) * 0.25;
   gl_FragColor = vec4(mix(col, fogCol, clamp(fog, 0.0, 1.0)), 1.0);
  }`);

 // Sun shafts: bright sky around the sun, radially blurred toward the sun's screen position.
 const raysSource = shader({ tColor: { value: atmosphereRT.texture }, tDepth: depthTex, uSun: { value: new THREE.Vector2() }, uAspect: { value: 1 } }, /* glsl */`
  uniform sampler2D tColor; uniform sampler2D tDepth; uniform vec2 uSun; uniform float uAspect; varying vec2 vUv;
  void main() {
   float sky = step(0.99999, texture2D(tDepth, vUv).r);
   vec2 d = (vUv - uSun) * vec2(uAspect, 1.0);
   float near = exp(-dot(d, d) * 16.0);
   gl_FragColor = vec4(min(texture2D(tColor, vUv).rgb, vec3(2.5)) * sky * near, 1.0);
  }`);
 const raysBlur = shader({ tColor: { value: null }, uSun: { value: new THREE.Vector2() }, uStep: { value: 1 } }, /* glsl */`
  uniform sampler2D tColor; uniform vec2 uSun; uniform float uStep; varying vec2 vUv;
  void main() {
   vec2 delta = (vUv - uSun) * (uStep / 40.0);
   vec2 uv = vUv; vec3 sum = vec3(0.0); float w = 1.0;
   for (int i = 0; i < 40; i++) { sum += texture2D(tColor, uv).rgb * w; w *= 0.965; uv -= delta; }
   gl_FragColor = vec4(sum / 16.0, 1.0);
  }`);

 const bright = shader({ tColor: { value: null }, uThreshold: { value: 1.6 } }, 'uniform sampler2D tColor; uniform float uThreshold; varying vec2 vUv; void main(){ vec3 c = texture2D(tColor, vUv).rgb; float l = dot(c, vec3(0.2126,0.7152,0.0722)); gl_FragColor = vec4(min(c, vec3(40.0)) * smoothstep(uThreshold, uThreshold * 2.5, l), 1.0); }');
 const blur = shader({ tColor: { value: null }, uDir: { value: new THREE.Vector2() } }, /* glsl */`
  uniform sampler2D tColor; uniform vec2 uDir; varying vec2 vUv;
  void main() {
   vec3 s = texture2D(tColor, vUv).rgb * 0.2270270270;
   s += (texture2D(tColor, vUv + uDir * 1.3846153846).rgb + texture2D(tColor, vUv - uDir * 1.3846153846).rgb) * 0.3162162162;
   s += (texture2D(tColor, vUv + uDir * 3.2307692308).rgb + texture2D(tColor, vUv - uDir * 3.2307692308).rgb) * 0.0702702703;
   gl_FragColor = vec4(s, 1.0);
  }`);
 const composite = shader({
  tColor: { value: atmosphereRT.texture }, tBloomA: { value: blurA[1].texture }, tBloomB: { value: blurB[1].texture }, tRays: { value: raysRT[1].texture }, uExposure: { value: 1 }, uTime: { value: 0 },
  uBloom: { value: .32 }, uRays: { value: 0 }, uSunScreen: { value: new THREE.Vector3(.5, .5, 0) }, uSunColor: { value: new THREE.Color() }, uAspect: { value: 1 }, uWarmth: { value: .5 }
 }, /* glsl */`
  uniform sampler2D tColor; uniform sampler2D tBloomA; uniform sampler2D tBloomB; uniform sampler2D tRays; uniform float uExposure; uniform float uTime; uniform float uBloom; uniform float uRays;
  uniform vec3 uSunScreen; uniform vec3 uSunColor; uniform float uAspect; uniform float uWarmth; varying vec2 vUv;
  vec3 aces(vec3 x) { return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0); }
  float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
  void main() {
   vec3 col = texture2D(tColor, vUv).rgb;
   col += (texture2D(tBloomA, vUv).rgb * 0.55 + texture2D(tBloomB, vUv).rgb * 0.8) * uBloom;
   col += texture2D(tRays, vUv).rgb * uRays;
   vec2 d = vUv - uSunScreen.xy; d.x *= uAspect;
   col += uSunColor * (exp(-length(d) * 8.0) * 0.12 + exp(-abs(d.y) * 260.0) * exp(-abs(d.x) * 3.0) * 0.03) * uSunScreen.z;
   col *= uExposure;
   col = aces(col);
   float l = dot(col, vec3(0.2126, 0.7152, 0.0722));
   col = mix(vec3(l), col, 1.1);
   col = mix(col, col * vec3(1.04, 1.0, 0.93), uWarmth * smoothstep(0.35, 0.95, l));
   col = mix(col, col * vec3(0.96, 0.99, 1.04) + vec3(0.0, 0.002, 0.008), (1.0 - smoothstep(0.0, 0.3, l)) * 0.5);
   col = pow(max(col, vec3(0.0)), vec3(1.0 / 2.2)); // the saturation boost can dip below zero; pow() of a negative is NaN
   col = smoothstep(-0.02, 1.02, col); // slight S-curve
   float v = smoothstep(1.2, 0.35, length((vUv - 0.5) * vec2(uAspect * 0.8, 1.0)));
   col *= mix(0.7, 1.0, v);
   col += (hash(vUv * 1000.0 + fract(uTime * 7.0)) - 0.5) * 0.018;
   gl_FragColor = vec4(col, 1.0);
  }`);

 function pass(material, target) { quad.material = material; renderer.setRenderTarget(target); renderer.render(scene, camera); }
 const sunNdc = new THREE.Vector3(), forward = new THREE.Vector3();

 return {
  uniforms: atmosphereUniforms, composite,
  setSize(w, h, dpr) {
   const x = Math.round(w * dpr), y = Math.round(h * dpr);
   sceneRT.setSize(x, y); atmosphereRT.setSize(x, y);
   for (const t of aoRT) t.setSize(x >> 1, y >> 1);
   for (const t of raysRT) t.setSize(x >> 1, y >> 1);
   brightRT.setSize(x >> 1, y >> 1);
   for (const t of blurA) t.setSize(x >> 2, y >> 2);
   for (const t of blurB) t.setSize(x >> 3, y >> 3);
   ao.uniforms.uTexel.value.set(2 / x, 2 / y);
   composite.uniforms.uAspect.value = raysSource.uniforms.uAspect.value = w / h;
  },
  render(worldScene, worldCamera, state, time) {
   renderer.setRenderTarget(sceneRT); renderer.render(worldScene, worldCamera);
   invProj.value.copy(worldCamera.projectionMatrixInverse); proj.value.copy(worldCamera.projectionMatrix);
   pass(ao, aoRT[0]);
   blur.uniforms.tColor.value = aoRT[0].texture; blur.uniforms.uDir.value.set(1 / aoRT[0].width, 0); pass(blur, aoRT[1]);
   blur.uniforms.tColor.value = aoRT[1].texture; blur.uniforms.uDir.value.set(0, 1 / aoRT[0].height); pass(blur, aoRT[0]);
   atmosphereUniforms.tAO.value = aoRT[0].texture;
   const u = atmosphereUniforms;
   u.uCamWorld.value.copy(worldCamera.matrixWorld); u.uCamPos.value.setFromMatrixPosition(worldCamera.matrixWorld);
   u.uTime.value = time; u.uSunDir.value.copy(state.sunDir); u.uZenith.value.copy(state.zenith); u.uHorizon.value.copy(state.horizon); u.uSunGlow.value.copy(state.glow); u.uGround.value.copy(state.ground); u.uSunColor.value.copy(state.sun); u.uSkyI.value = state.skyI;
   pass(atmosphere, atmosphereRT);

   sunNdc.copy(state.sunDir).multiplyScalar(5000).add(u.uCamPos.value).project(worldCamera);
   forward.set(0, 0, -1).applyQuaternion(worldCamera.quaternion);
   const facing = forward.dot(state.sunDir), sunUv = new THREE.Vector2(sunNdc.x * .5 + .5, sunNdc.y * .5 + .5);
   const sunWeight = facing > 0 ? THREE.MathUtils.smoothstep(facing, .35, .9) * THREE.MathUtils.clamp(state.sunDir.y * 12 + .6, 0, 1) : 0;
   if (sunWeight > .01) {
    raysSource.uniforms.uSun.value.copy(sunUv); pass(raysSource, raysRT[0]);
    raysBlur.uniforms.uSun.value.copy(sunUv);
    raysBlur.uniforms.tColor.value = raysRT[0].texture; raysBlur.uniforms.uStep.value = 1; pass(raysBlur, raysRT[1]);
    raysBlur.uniforms.tColor.value = raysRT[1].texture; raysBlur.uniforms.uStep.value = .35; pass(raysBlur, raysRT[0]);
    raysBlur.uniforms.tColor.value = raysRT[0].texture; raysBlur.uniforms.uStep.value = .12; pass(raysBlur, raysRT[1]);
   }
   composite.uniforms.uRays.value = sunWeight * .22;
   composite.uniforms.uExposure.value *= 1 - sunWeight * .38; // the eye adapts when looking into the sun

   bright.uniforms.tColor.value = atmosphereRT.texture; pass(bright, brightRT);
   const chain = (src, pair) => {
    blur.uniforms.tColor.value = src.texture; blur.uniforms.uDir.value.set(1 / pair[0].width, 0); pass(blur, pair[0]);
    blur.uniforms.tColor.value = pair[0].texture; blur.uniforms.uDir.value.set(0, 1 / pair[0].height); pass(blur, pair[1]);
   };
   chain(brightRT, blurA); chain(blurA[1], blurB);
   composite.uniforms.uSunScreen.value.set(sunUv.x, sunUv.y, sunWeight);
   composite.uniforms.uSunColor.value.copy(state.sun); composite.uniforms.uTime.value = time;
   pass(composite, null);
  }
 };
}
