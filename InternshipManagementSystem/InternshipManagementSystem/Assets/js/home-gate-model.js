import * as THREE from './vendor/three.module.min.js';

// Gate 1: b1138b1f front + 4f98f98f side photographs. Dimensions are normalized.
export async function createGateModel(logoUrl) {
    const logo = new Image(); logo.src = logoUrl; await logo.decode();
    const root = new THREE.Group(); root.name = 'university-gate';
    const parts = new Map(), flags = [];
    function group(id) { const g = new THREE.Group(); g.name = id; root.add(g); parts.set(id, g); return g; }
    const stone = new THREE.MeshStandardMaterial({ color: '#d9c9ac', roughness: .89 });
    const pores = new Uint8Array(256 * 256 * 4); let seed = 109;
    for (let i = 0; i < pores.length; i += 4) {
        seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
        pores[i] = pores[i + 1] = pores[i + 2] = 100 + (seed >>> 26); pores[i + 3] = 255;
    }
    const stoneBump = new THREE.DataTexture(pores, 256, 256); stoneBump.wrapS = stoneBump.wrapT = THREE.RepeatWrapping;
    stoneBump.magFilter = THREE.LinearFilter; stoneBump.needsUpdate = true; stone.bumpMap = stoneBump; stone.bumpScale = .018;
    const metal = new THREE.MeshStandardMaterial({ color: '#687477', roughness: .5, metalness: .55 });
    const road = new THREE.MeshStandardMaterial({ color: '#aeb6b8', roughness: .96 });
    const marble = new THREE.MeshStandardMaterial({ color: '#e5e8e5', roughness: .8 });
    const dark = new THREE.MeshStandardMaterial({ color: '#31434d', roughness: .75 });
    function box(parent, id, size, position, material = stone) {
        const mesh = new THREE.Mesh(new THREE.BoxGeometry(...size), material);
        mesh.name = id; mesh.position.fromArray(position); mesh.castShadow = true; mesh.receiveShadow = true; parent.add(mesh); return mesh;
    }
    function cylinder(parent, id, radius, height, position, material = metal) {
        const m = new THREE.Mesh(new THREE.CylinderGeometry(radius, radius, height, 12), material);
        m.name = id; m.position.fromArray(position); m.castShadow = true; parent.add(m); return m;
    }
    const frame = group('limestone-portal');
    for (const x of [-5.6, 5.6]) box(frame, x < 0 ? 'portal-pier-left' : 'portal-pier-right', [1.05, 3.6, .9], [x, 1.8, 0]);
    box(frame, 'portal-lintel', [12.25, 1.8, .9], [0, 4.5, 0]);
    const ground = group('ground');
    box(ground, 'forecourt', [17, .2, 11], [0, -.15, -1.6], marble);
    box(ground, 'entrance-road', [8.8, .025, 10.8], [0, -.03, -1.6], road);
    for (const x of [-4.6, 4.6]) box(ground, 'road-edge-' + x, [.12, .1, 10.8], [x, .01, -1.6], stone);
    const fence = group('metal-gates');
    for (const [center, width] of [[-3.65, 3], [4.4, 1.25]]) {
        for (const y of [.3, 2.35]) box(fence, 'fence-rail-' + center + '-' + y, [width, .055, .065], [center, y, .4], metal);
        for (let x = center - width / 2; x <= center + width / 2 + .01; x += .22) cylinder(fence, 'gate-bar-' + x, .023, 2.4, [x, 1.25, .4]);
    }
    const booth = group('right-return');
    box(booth, 'stone-return', [1.35, 2.45, 1.9], [6.25, 1.225, -.65]);
    box(booth, 'return-window', [.95, 1.4, .04], [6.25, 1.2, .32], dark);
    for (let i = 0; i < 6; i++) cylinder(booth, 'window-grille-' + i, .015, 1.4, [5.82 + i * .17, 1.2, .36]);
    const signage = group('university-sign');
    const sign = document.createElement('canvas'); sign.width = 2048; sign.height = 256;
    const ctx = sign.getContext('2d');
    ctx.drawImage(logo, 36, 20, 300, 220); ctx.fillStyle = '#18232b';
    ctx.direction = 'rtl'; ctx.textAlign = 'right'; ctx.font = 'bold 94px "Segoe UI", sans-serif';
    ctx.fillText('الجامعة الألمانية الأردنية', 1740, 112, 1310);
    ctx.direction = 'ltr'; ctx.textAlign = 'left'; ctx.font = 'bold 82px "Segoe UI", sans-serif';
    ctx.fillText('German Jordanian University', 410, 218, 1330);
    ctx.font = 'bold 196px "Segoe UI", sans-serif'; ctx.fillText('1', 1840, 214);
    const signTexture = new THREE.CanvasTexture(sign); signTexture.colorSpace = THREE.SRGBColorSpace;
    const signMesh = new THREE.Mesh(new THREE.PlaneGeometry(11.8, 1.55), new THREE.MeshBasicMaterial({ map: signTexture, transparent: true, depthWrite: false }));
    signMesh.name = 'official-logo-and-bilingual-gate-sign'; signMesh.position.set(0, 4.5, .457); signage.add(signMesh);

    function flagTexture(country) {
        const canvas = document.createElement('canvas'); canvas.width = 1000; canvas.height = country === 'jordan' ? 500 : 600;
        const c = canvas.getContext('2d'), w = canvas.width, h = canvas.height;
        const colors = country === 'jordan' ? ['#000000', '#ffffff', '#007a3d'] : ['#000000', '#dd0000', '#ffce00'];
        colors.forEach((color, i) => { c.fillStyle = color; c.fillRect(0, i * h / 3, w, h / 3 + 1); });
        if (country === 'jordan') {
            c.fillStyle = '#ce1126'; c.beginPath(); c.moveTo(0, 0); c.lineTo(w / 2, h / 2); c.lineTo(0, h); c.closePath(); c.fill();
            // Seven outer points; diameter L/14, at the intersection of angle bisectors.
            const centerX = (w / 2) * h / (h + 2 * Math.hypot(w / 2, h / 2));
            const radius = w / 28; c.fillStyle = '#ffffff'; c.beginPath();
            for (let i = 0; i < 14; i++) {
                const angle = -Math.PI / 2 + i * Math.PI / 7, r = i % 2 ? radius * .45 : radius;
                const x = centerX + Math.cos(angle) * r, y = h / 2 + Math.sin(angle) * r;
                if (i === 0) c.moveTo(x, y); else c.lineTo(x, y);
            }
            c.closePath(); c.fill();
        }
        const texture = new THREE.CanvasTexture(canvas); texture.colorSpace = THREE.SRGBColorSpace; texture.anisotropy = 4;
        return texture;
    }
    const poles = group('flagpoles');
    for (const [country, x] of [['jordan', -3.2], ['germany', 1.55]]) {
        cylinder(poles, country + '-pole', .045, 8.5, [x, 4.25, -1.35]);
        cylinder(poles, country + '-base', .22, .12, [x, .06, -1.35]);
        const finial = new THREE.Mesh(new THREE.SphereGeometry(.075, 12, 8), metal); finial.name = country + '-finial'; finial.position.set(x, 8.54, -1.35); poles.add(finial);
        const width = 2.85, height = country === 'jordan' ? width / 2 : width * 3 / 5;
        const geometry = new THREE.PlaneGeometry(width, height, 24, 14);
        const flag = new THREE.Mesh(geometry, new THREE.MeshStandardMaterial({ map: flagTexture(country), side: THREE.DoubleSide, roughness: .9, metalness: 0 }));
        flag.name = country + '-flag'; flag.position.set(x + width / 2 + .055, 8.25 - height / 2, -1.35);
        flag.castShadow = true; root.add(flag); parts.set(flag.name, flag);
        flags.push({ mesh: flag, country, starPoints: country === 'jordan' ? 7 : 0, rest: geometry.attributes.position.array.slice(), width, height, phase: country === 'jordan' ? 0 : .6 });
    }
    function updateCloth(time, amplitude = 1) {
        for (const flag of flags) {
            const attr = flag.mesh.geometry.attributes.position;
            for (let i = 0; i < attr.count; i++) {
                const k = i * 3, x = flag.rest[k], y = flag.rest[k + 1], fraction = (x + flag.width / 2) / flag.width, v = y / flag.height;
                const u = fraction < .00001 ? 0 : fraction;
                attr.array[k] = x - .05 * u * u;
                attr.array[k + 1] = y - .1 * u * u + amplitude * .018 * u * Math.sin(time * 1.1 - u * 4 + v * 2 + flag.phase);
                attr.array[k + 2] = amplitude * u * (.12 * Math.sin(time * 1.25 - u * 4.8 + v * 1.4 + flag.phase) + .035 * Math.sin(time * 2 - u * 8 + v * 2));
            }
            attr.needsUpdate = true; flag.mesh.geometry.computeVertexNormals();
        }
    }
    updateCloth(0);
    root.userData.sculptRuntime = { parts, flags, pivots: { flagpoles: poles }, approximateDimensions: true };
    return { root, parts, flags, updateCloth };
}
