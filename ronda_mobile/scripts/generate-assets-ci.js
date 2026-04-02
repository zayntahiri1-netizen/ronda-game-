#!/usr/bin/env node
/**
 * generate-assets-ci.js
 * توليد الأيقونات باستخدام node-canvas (يعمل على CI وTermux)
 * بدون sharp أو libvips
 */

const { createCanvas, loadImage } = require('canvas');
const fs   = require('fs');
const path = require('path');

const ROOT   = path.resolve(__dirname, '..');
const ICONS_DIR = path.join(ROOT, 'www', 'icons');

// أحجام PWA
const SIZES = [72, 96, 128, 144, 152, 192, 384, 512];

async function generateIconsFromSVG() {
  fs.mkdirSync(ICONS_DIR, { recursive: true });

  // قراءة الـ SVG
  const svgPath = path.join(ROOT, 'assets', 'icon.svg');
  if (!fs.existsSync(svgPath)) {
    console.log('icon.svg not found, skipping...');
    return;
  }

  for (const size of SIZES) {
    const canvas = createCanvas(size, size);
    const ctx    = canvas.getContext('2d');

    // رسم خلفية بلون الأيقونة
    ctx.fillStyle = '#030508';
    const r = size * 0.2;
    ctx.beginPath();
    ctx.moveTo(r, 0);
    ctx.lineTo(size - r, 0);
    ctx.quadraticCurveTo(size, 0, size, r);
    ctx.lineTo(size, size - r);
    ctx.quadraticCurveTo(size, size, size - r, size);
    ctx.lineTo(r, size);
    ctx.quadraticCurveTo(0, size, 0, size - r);
    ctx.lineTo(0, r);
    ctx.quadraticCurveTo(0, 0, r, 0);
    ctx.closePath();
    ctx.fill();

    // كتابة "روندة" بالذهبي
    const fontSize = Math.round(size * 0.32);
    ctx.fillStyle = '#c9a227';
    ctx.font = `bold ${fontSize}px Arial`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('روندة', size / 2, size * 0.42);

    // رسوم بطاقة ♦
    ctx.fillStyle = '#cc2222';
    ctx.font = `${Math.round(size * 0.28)}px Arial`;
    ctx.fillText('♦', size / 2, size * 0.72);

    const out = path.join(ICONS_DIR, `icon-${size}.png`);
    const buf = canvas.toBuffer('image/png');
    fs.writeFileSync(out, buf);
    console.log(`✓ icon-${size}.png`);
  }
}

generateIconsFromSVG()
  .then(() => console.log('\n✅ Icons generated!'))
  .catch(e => {
    console.error('Canvas generation failed:', e.message);
    console.log('Continuing without custom icons...');
    process.exit(0); // لا نوقف البناء
  });
