import * as THREE from '../vendor/three.module.min.js';
import { ATMOSPHERE_GLSL, NOISE_GLSL } from './jisr-common.js';

// Time of day is driven by scroll: the page opens as the sun clears the Madaba horizon.
// Each key is a sun elevation in degrees with its sky, light and fog colours (sRGB hex).
const KEYS = [
 { el: -2.5, zenith: '#122042', horizon: '#6f6a88', glow: '#ff6e3a', glowI: 1.3, ground: '#25262d', sun: '#ff7a3a', sunI: 0.0, hemiSky: '#3e4c78', hemiGround: '#2c2522', hemiI: .32, sky: .85, lights: 1 },
 { el: 1.5, zenith: '#1c3f74', horizon: '#c99a8e', glow: '#ff8642', glowI: 2.3, ground: '#4a3d3a', sun: '#ff9550', sunI: 4.4, hemiSky: '#6a82aa', hemiGround: '#55402f', hemiI: .55, sky: 1.0, lights: .8 },
 { el: 5, zenith: '#265a9c', horizon: '#dfb89a', glow: '#ffa45c', glowI: 1.9, ground: '#665443', sun: '#ffac68', sunI: 5.6, hemiSky: '#7f9bbf', hemiGround: '#8a6c50', hemiI: .5, sky: 1.08, lights: .12 },
 { el: 11, zenith: '#2c6ab5', horizon: '#e6d0b2', glow: '#ffc48a', glowI: 1.4, ground: '#7d6a56', sun: '#ffcb94', sunI: 6.2, hemiSky: '#8fabcc', hemiGround: '#957a5e', hemiI: .55, sky: 1.15, lights: 0 },
 { el: 20, zenith: '#3878c2', horizon: '#dfe0dc', glow: '#ffe0bc', glowI: 1.0, ground: '#8f7f6b', sun: '#ffe3c4', sunI: 6.6, hemiSky: '#a2bcd9', hemiGround: '#907b64', hemiI: .6, sky: 1.2, lights: 0 }
];
const tmpA = new THREE.Color(), tmpB = new THREE.Color();
export function timeOfDay(elevationDeg, azimuthDeg = 97) {
 let i = 0; while (i < KEYS.length - 2 && KEYS[i + 1].el < elevationDeg) i++;
 const a = KEYS[i], b = KEYS[i + 1], t = THREE.MathUtils.clamp((elevationDeg - a.el) / (b.el - a.el), 0, 1), s = t * t * (3 - 2 * t);
 const col = key => tmpA.set(a[key]).lerp(tmpB.set(b[key]), s).clone();
 const num = key => a[key] + (b[key] - a[key]) * s;
 const el = THREE.MathUtils.degToRad(elevationDeg), az = THREE.MathUtils.degToRad(azimuthDeg);
 const sunDir = new THREE.Vector3(Math.cos(el) * Math.sin(az), Math.sin(el), -Math.cos(el) * Math.cos(az)).normalize();
 return {
  elevation: elevationDeg, sunDir, zenith: col('zenith'), horizon: col('horizon'), glow: col('glow').multiplyScalar(num('glowI')),
  ground: col('ground'), sun: col('sun'), sunI: num('sunI'), hemiSky: col('hemiSky'), hemiGround: col('hemiGround'), hemiI: num('hemiI'),
  skyI: num('sky'), lights: THREE.MathUtils.clamp(num('lights'), 0, 1)
 };
}

export function createSky() {
 const uniforms = {
  uSunDir: { value: new THREE.Vector3(0, .1, -1) }, uZenith: { value: new THREE.Color() }, uHorizon: { value: new THREE.Color() },
  uSunGlow: { value: new THREE.Color() }, uGround: { value: new THREE.Color() }, uSunColor: { value: new THREE.Color() },
  uSkyI: { value: 1 }, uTime: { value: 0 }, uStars: { value: 0 }
 };
 const material = new THREE.ShaderMaterial({
  uniforms, side: THREE.BackSide, depthWrite: false, depthTest: false,
  vertexShader: /* glsl */`
   varying vec3 vDir;
   void main() { vDir = position; vec4 p = projectionMatrix * modelViewMatrix * vec4(position, 1.0); gl_Position = p.xyww; }`,
  fragmentShader: /* glsl */`
   ${ATMOSPHERE_GLSL}
   ${NOISE_GLSL}
   uniform vec3 uSunColor; uniform float uSkyI; uniform float uTime; uniform float uStars;
   varying vec3 vDir;
   void main() {
    vec3 dir = normalize(vDir);
    vec3 col = atmosphere(dir);
    float mu = dot(dir, uSunDir);
    // Sun disc with limb darkening; it bleeds into bloom in post.
    float disc = smoothstep(0.99985, 0.99993, mu);
    col += uSunColor * disc * 38.0 * smoothstep(-0.01, 0.01, dir.y);
    // A thin altocumulus deck, lit from below at dawn. Projected onto a plane 2.4 km up.
    if (dir.y > 0.0) {
     vec2 uv = dir.xz / (dir.y + 0.06) * 1.6 + vec2(uTime * 0.0035, uTime * 0.0012);
     float n = jFbm(uv * 1.35);
     float detail = jFbm(uv * 5.1 + 3.0);
     float cover = smoothstep(0.56, 0.84, n * 0.82 + detail * 0.3);
     float fade = smoothstep(0.02, 0.22, dir.y) * (1.0 - smoothstep(0.5, 0.95, dir.y) * 0.5);
     float lit = pow(max(mu, 0.0), 2.5);
     vec3 base = mix(uZenith * 0.95, uHorizon * 1.1, 0.45);
     vec3 cloud = base * (0.8 + detail * 0.35) + uSunGlow * (0.3 + lit * 1.5) * (0.25 + detail * 0.9);
     col = mix(col, cloud, cover * fade * 0.85);
     // Last stars before dawn.
     vec2 cell = floor(dir.xz / (dir.y + 0.3) * 260.0);
     float star = step(0.9965, jHash(cell)) * smoothstep(0.25, 0.7, dir.y) * (1.0 - cover);
     col += vec3(star) * uStars * 1.6;
    }
    gl_FragColor = vec4(col * uSkyI, 1.0);
   }`
 });
 const mesh = new THREE.Mesh(new THREE.SphereGeometry(9000, 48, 24), material);
 mesh.name = 'sky-dome'; mesh.frustumCulled = false; mesh.renderOrder = -10;
 function apply(state, time) {
  uniforms.uSunDir.value.copy(state.sunDir); uniforms.uZenith.value.copy(state.zenith); uniforms.uHorizon.value.copy(state.horizon);
  uniforms.uSunGlow.value.copy(state.glow); uniforms.uGround.value.copy(state.ground); uniforms.uSunColor.value.copy(state.sun);
  uniforms.uSkyI.value = state.skyI; uniforms.uTime.value = time; uniforms.uStars.value = THREE.MathUtils.clamp((1.5 - state.elevation) / 4, 0, 1);
 }
 return { mesh, uniforms, apply };
}
