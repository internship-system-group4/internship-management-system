import * as THREE from './vendor/three.module.min.js';

// Password recovery terminal for the Gate 1 scene (ForgotPassword.aspx only).
// A free-standing access-control kiosk: dark plinth with a light ring, a satin column carrying the GJU mark, and an
// angled head whose screen is a canvas texture redrawn for each recovery state:
//   idle -> "ready", submitting -> "processing" (spinner), success -> "Reset Link Sent" (check), denied -> "try again".
// The screen only changes when the page reports the real server result; nothing here decides success.

// Front-rounded box: the front outline has rounded corners and every depth edge is bevelled.
function roundedBox(width, height, depth, radius, bevel = .008) {
 const shape = new THREE.Shape(), x = -width / 2 + bevel, y = -height / 2 + bevel, w = width - bevel * 2, h = height - bevel * 2, r = Math.min(radius, w / 2, h / 2);
 shape.moveTo(x + r, y); shape.lineTo(x + w - r, y); shape.quadraticCurveTo(x + w, y, x + w, y + r);
 shape.lineTo(x + w, y + h - r); shape.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
 shape.lineTo(x + r, y + h); shape.quadraticCurveTo(x, y + h, x, y + h - r);
 shape.lineTo(x, y + r); shape.quadraticCurveTo(x, y, x + r, y);
 const geometry = new THREE.ExtrudeGeometry(shape, { depth:depth - bevel * 2, bevelEnabled:true, bevelThickness:bevel, bevelSize:bevel, bevelSegments:2, curveSegments:8 });
 geometry.center(); return geometry;
}

const SCREEN_W = 512, SCREEN_H = 400;
const COLORS = { idle:'#7fc4ff', submitting:'#f2c25b', success:'#38c172', denied:'#f08a6c' };

export async function createRecoveryTerminal(host, { compact = false } = {}) {
 const data = host.dataset, rtl = document.documentElement.dir === 'rtl';
 const labels = {
  idle:[data.screenReady || 'Password Recovery', data.screenReadyHint || 'Enter your email'],
  submitting:[data.screenProcessing || 'Processing…', ''],
  success:[data.screenSent || 'Reset Link Sent', ''],
  denied:[data.screenRetry || 'Please try again', '']
 };
 const root = new THREE.Group(); root.name = 'recovery-terminal';
 const body = new THREE.MeshStandardMaterial({ color:'#d5dade', metalness:.35, roughness:.38 });
 const shell = new THREE.MeshStandardMaterial({ color:'#1e2b38', metalness:.25, roughness:.5 });
 const ringMat = new THREE.MeshBasicMaterial({ color:'#55b8ff', toneMapped:false });
 const parts = [];
 function add(geometry, material, position, parent = root) {
  const mesh = new THREE.Mesh(geometry, material); mesh.position.fromArray(position); mesh.castShadow = true; mesh.receiveShadow = true; parent.add(mesh); parts.push(mesh); return mesh;
 }
 // Plinth and the light ring that wraps it (the ring is unlit, so it reads as a glow in daylight).
 add(roundedBox(.44, .15, .34, .06), shell, [0, .075, 0]);
 const ring = add(roundedBox(.452, .022, .352, .065, .004), ringMat, [0, .118, 0]); ring.castShadow = false;
 add(roundedBox(.40, .03, .30, .05), shell, [0, .145, 0]);
 // Column with a navy service seam and the university mark.
 add(roundedBox(.30, .98, .20, .05), body, [0, .65, 0]);
 add(new THREE.BoxGeometry(.008, .62, .004), shell, [.118, .62, .101]).castShadow = false;
 const logo = new THREE.TextureLoader().loadAsync(data.logo).then(map => {
  map.colorSpace = THREE.SRGBColorSpace; map.anisotropy = compact ? 2 : 4;
  const decal = new THREE.Mesh(new THREE.PlaneGeometry(.13, .097), new THREE.MeshStandardMaterial({ map, transparent:true, roughness:.5, polygonOffset:true, polygonOffsetFactor:-2 }));
  decal.position.set(-.01, .46, .1015); root.add(decal); parts.push(decal);
 }).catch(() => { /* the mark is decoration; the terminal works without it */ });
 // Neck and the angled head. The head leans back so the screen faces the visitor and the camera.
 add(roundedBox(.2, .08, .14, .03), shell, [0, 1.17, -.01]);
 // Scaled up from a real 15-inch kiosk head so the display reads at the scene's camera distance.
 const head = new THREE.Group(); head.position.set(0, 1.35, .02); head.rotation.x = -.3; head.scale.setScalar(1.3); root.add(head);
 add(roundedBox(.42, .34, .085, .045), shell, [0, 0, 0], head);
 add(roundedBox(.44, .02, .1, .01, .004), shell, [0, .175, -.004], head);
 // Screen: a canvas texture on an unlit plane, so the display stays legible in shadow.
 const canvas = document.createElement('canvas'); canvas.width = SCREEN_W; canvas.height = SCREEN_H;
 const ink = canvas.getContext('2d');
 // Kept on the page root so browser checks can read what the display shows.
 host.recoveryScreen = canvas;
 const screenMap = new THREE.CanvasTexture(canvas); screenMap.colorSpace = THREE.SRGBColorSpace; screenMap.anisotropy = compact ? 2 : 4;
 const screen = new THREE.Mesh(new THREE.PlaneGeometry(.36, .2813), new THREE.MeshBasicMaterial({ map:screenMap, toneMapped:false }));
 screen.position.set(0, 0, .0436); head.add(screen); parts.push(screen);
 // A faint glass reflection over the display.
 const glass = new THREE.Mesh(new THREE.PlaneGeometry(.36, .2813), new THREE.MeshPhysicalMaterial({ color:'#ffffff', transparent:true, opacity:.08, roughness:.05, metalness:0 }));
 glass.position.set(0, 0, .0446); head.add(glass); parts.push(glass);
 await logo;

 root.updateWorldMatrix(true, true);
 let state = 'idle', since = 0, spin = 0, lastDraw = -1;
 const font = (weight, size) => `${weight} ${size}px "Segoe UI", "Noto Sans Arabic", Arial, sans-serif`;
 function wrap(text, maxWidth) {
  const words = text.split(/\s+/), lines = []; let line = '';
  for (const word of words) { const next = line ? line + ' ' + word : word; if (line && ink.measureText(next).width > maxWidth) { lines.push(line); line = word; } else line = next; }
  if (line) lines.push(line); return lines.slice(0, 3);
 }
 function draw(time) {
  const g = ink, cx = SCREEN_W / 2, cy = 168, color = COLORS[state];
  g.save(); g.direction = rtl ? 'rtl' : 'ltr'; g.textAlign = 'center'; g.textBaseline = 'middle';
  const bg = g.createLinearGradient(0, 0, 0, SCREEN_H); bg.addColorStop(0, '#163d63'); bg.addColorStop(1, '#0d2741');
  g.fillStyle = bg; g.fillRect(0, 0, SCREEN_W, SCREEN_H);
  // Status bar.
  g.fillStyle = 'rgba(255,255,255,.07)'; g.fillRect(0, 0, SCREEN_W, 46);
  g.fillStyle = 'rgba(232,241,250,.82)'; g.font = font(600, 20); g.textAlign = 'start';
  g.direction = 'ltr'; g.fillText('GJU · UIMS', 22, 24); g.textAlign = 'end'; g.fillText('GATE 1', SCREEN_W - 22, 24);
  g.direction = rtl ? 'rtl' : 'ltr'; g.textAlign = 'center';
  // Emblem.
  const intro = Math.min(1, since / .45), ease = 1 - Math.pow(1 - intro, 3);
  g.lineCap = 'round'; g.lineJoin = 'round';
  if (state === 'success') {
   g.fillStyle = color; g.beginPath(); g.arc(cx, cy, 52 * (.7 + .3 * ease), 0, Math.PI * 2); g.fill();
   // The tick draws itself after the disc settles.
   const tick = Math.max(0, Math.min(1, (since - .15) / .4)), a = [cx - 24, cy + 2], b = [cx - 6, cy + 20], c = [cx + 26, cy - 16];
   g.strokeStyle = '#fff'; g.lineWidth = 11; g.beginPath(); g.moveTo(...a);
   if (tick < .4) g.lineTo(a[0] + (b[0] - a[0]) * tick / .4, a[1] + (b[1] - a[1]) * tick / .4);
   else { g.lineTo(...b); const t = (tick - .4) / .6; g.lineTo(b[0] + (c[0] - b[0]) * t, b[1] + (c[1] - b[1]) * t); }
   g.stroke();
  } else if (state === 'submitting') {
   g.strokeStyle = 'rgba(255,255,255,.14)'; g.lineWidth = 10; g.beginPath(); g.arc(cx, cy, 48, 0, Math.PI * 2); g.stroke();
   g.strokeStyle = color; g.beginPath(); g.arc(cx, cy, 48, spin, spin + Math.PI * 1.25); g.stroke();
  } else if (state === 'denied') {
   g.strokeStyle = color; g.lineWidth = 9; g.beginPath(); g.arc(cx, cy, 48, 0, Math.PI * 2); g.stroke();
   g.fillStyle = color; g.fillRect(cx - 5, cy - 28, 10, 34); g.beginPath(); g.arc(cx, cy + 22, 6.5, 0, Math.PI * 2); g.fill();
  } else {
   // Ready: an envelope inside a soft ring, the ring breathing slowly.
   const pulse = .5 + .5 * Math.sin(time * 1.6);
   g.strokeStyle = `rgba(127,196,255,${.25 + .2 * pulse})`; g.lineWidth = 6; g.beginPath(); g.arc(cx, cy, 54 + 3 * pulse, 0, Math.PI * 2); g.stroke();
   g.strokeStyle = '#e8f1fa'; g.lineWidth = 6; g.strokeRect(cx - 30, cy - 21, 60, 42);
   g.beginPath(); g.moveTo(cx - 28, cy - 18); g.lineTo(cx, cy + 4); g.lineTo(cx + 28, cy - 18); g.stroke();
  }
  // Message.
  const [title, hint] = labels[state];
  g.fillStyle = '#ffffff'; g.font = font(700, 40);
  const lines = wrap(title, SCREEN_W - 60), top = (hint ? 268 : 286) - (lines.length - 1) * 22;
  lines.forEach((line, i) => g.fillText(line, cx, top + i * 46));
  if (hint) { g.fillStyle = 'rgba(214,230,245,.78)'; g.font = font(500, 25); g.fillText(hint, cx, top + lines.length * 46 + 6); }
  g.restore(); screenMap.needsUpdate = true;
 }
 draw(0);
 return {
  root, screen,
  setState(value) {
   if (!COLORS[value] || value === state) return;
   state = value; since = 0; lastDraw = -1; draw(0);
  },
  // Called every rendered frame. Returns true while the display is still animating.
  update(dt, time, still) {
   since += dt;
   if (state === 'submitting') spin += dt * 5.2;
   const base = state === 'submitting' ? .55 + .45 * Math.sin(time * 6) : state === 'success' ? 1 : .85;
   ringMat.color.set(state === 'idle' ? '#55b8ff' : COLORS[state]).multiplyScalar(still ? 1 : base);
   // Reduced motion or paused: show the finished state (the full tick) at once, then stop redrawing.
   if (still) { if (since < 10) { since = 10; draw(time); } return false; }
   // The texture upload is the expensive part: 30 redraws a second while the spinner or the tick moves, 10 for the
   // slow idle breathing, none once the confirmation has settled.
   const busy = state === 'submitting' || (state === 'success' && since < .8);
   if (state === 'success' && since >= .8 && lastDraw >= 0) return false;
   if (time - lastDraw >= (busy ? 1 / 30 : 1 / 10) || lastDraw < 0) { draw(time); lastDraw = time; }
   return true;
  },
  dispose() {
   for (const mesh of parts) { mesh.geometry.dispose(); for (const value of Object.values(mesh.material)) if (value?.isTexture) value.dispose(); mesh.material.dispose(); }
   ringMat.dispose(); body.dispose(); shell.dispose(); screenMap.dispose();
  }
 };
}
