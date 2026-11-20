// Ports prototype I18N (plus new keys) into Flutter ARB files.
// usage: node gen_arb.js <prototype/index.html> <new_keys.json> <outDir>
const fs = require('fs');
const [,, protoPath, newKeysPath, outDir] = process.argv;
const html = fs.readFileSync(protoPath, 'utf8');
const start = html.indexOf('const I18N = {');
const end = html.indexOf('}};', start) + 3;
const I18N = new Function(html.slice(start, end).replace('const I18N =', 'return') )();
const extra = JSON.parse(fs.readFileSync(newKeysPath, 'utf8'));

// Dart identifiers: snake_case -> camelCase.
const camel = k => k.replace(/_([a-zA-Z0-9])/g, (_, c) => c.toUpperCase());
const reserved = new Set(['of', 'in', 'is', 'new', 'default', 'switch', 'class', 'this', 'super', 'null', 'true', 'false', 'void', 'var', 'final', 'const', 'return', 'if', 'else', 'for', 'while', 'do', 'try', 'catch', 'with', 'enum', 'extends', 'import', 'export', 'part', 'library', 'show', 'hide', 'on', 'as', 'get', 'set', 'operator', 'factory', 'static', 'abstract', 'dynamic', 'external', 'late', 'required', 'covariant', 'typedef', 'mixin', 'interface', 'base', 'sealed', 'when']);
const ident = k => { let c = camel(k); if (reserved.has(c) || /^[0-9]/.test(c)) c = 'k' + c[0].toUpperCase() + c.slice(1); return c; };

const keyMap = {};
function build(lang) {
  const src = { ...I18N[lang], ...extra[lang] };
  const out = { '@@locale': lang };
  for (const [k, v0] of Object.entries(src).sort(([a], [b]) => a.localeCompare(b))) {
    const id = ident(k); keyMap[k] = id;
    // escape ICU special chars: apostrophes are literal in our strings
    let v = String(v0).replace(/'/g, "''");
    out[id] = v;
    if (lang === 'en') {
      const ph = [...new Set([...String(v0).matchAll(/\{(\w+)\}/g)].map(m => m[1]))];
      const meta = { description: `prototype key: ${k}` };
      if (ph.length) meta.placeholders = Object.fromEntries(ph.map(p => [p, { type: 'String' }]));
      out['@' + id] = meta;
    }
  }
  return out;
}
const en = build('en'), ar = build('ar');
const missing = Object.keys(en).filter(k => !k.startsWith('@') && !(k in ar));
if (missing.length) { console.error('missing in ar:', missing); process.exit(1); }
fs.writeFileSync(`${outDir}/app_en.arb`, JSON.stringify(en, null, 2) + '\n');
fs.writeFileSync(`${outDir}/app_ar.arb`, JSON.stringify(ar, null, 2) + '\n');
fs.writeFileSync(`${outDir}/../../tool_keymap.json`, JSON.stringify(keyMap, null, 1));
console.log('keys:', Object.keys(en).filter(k => !k.startsWith('@')).length);
