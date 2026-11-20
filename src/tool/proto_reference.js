// Runs the prototype's data/logic code in Node and prints reference numbers
// used by test/fixtures/reference_data.dart.  usage: node tool/proto_reference.js ../prototype/index.html
const fs = require('fs');
const html = fs.readFileSync(process.argv[2], 'utf8');
const js = html.slice(html.indexOf('<script>') + 8, html.indexOf('/* ================= renderers'));
const localStorage = { getItem: () => null, setItem: () => {} };
const ctx = new Function('localStorage', 'document', 'html', js + `
; syncCats();
const r2 = n => Math.round(n * 100) / 100;
const out = {};
out.txCount = state.tx.length;
out.txSum = r2(state.tx.reduce((a, x) => a + x.amount, 0));
for (const ym of ['2026-11', '2026-10']) {
  const m = inMonth(ym);
  out['inc_' + ym] = r2(sum(m, 'income'));
  out['exp_' + ym] = r2(sum(m, 'expense'));
}
const f = forecast(3);
out.fc_varAvg = r2(f.varAvg);
out.fc = f.months.map(x => ({ m: x.m, fixed: r2(x.fixed), ev: r2(x.evExp), evs: x.evs, total: r2(x.total), inc: r2(x.inc), high: x.high }));
const f0 = (() => { const saved = predict; return null; })();
out.mem_spent = Object.fromEntries([1,2,3,4,null].map(id => [String(id), r2(memSpent(id, '2026-11'))]));
for (const id of ['ramadan', 'eid_adha', 'eid_fitr', 'school']) {
  const p = predict(id);
  out['pred_' + id] = { total: r2(p.total), last: p.last && r2(p.last.total), g: r2(p.g), hist: p.hist.map(h => [h.date, r2(h.total)]) };
}
const sgSrc = html.slice(html.indexOf('function suggestEv'), html.indexOf('let evTouched'));
const suggestEv2 = new Function('evIds','evDates','addDays','EVENTS','daysBetween','nearestOcc', sgSrc + '; return suggestEv;')(evIds, evDates, addDays, EVENTS, daysBetween, nearestOcc);
out.suggest = ['2026-02-10','2026-02-03','2026-03-01','2026-03-19','2026-05-20','2026-06-20','2026-09-05','2026-12-20'].map(d => [d, suggestEv2(d)]);
out.budget_nov = Object.fromEntries(Object.keys(state.budgets).map(c => [c, r2(inMonth('2026-11').filter(x => x.type === 'expense' && x.cat === c).reduce((a, x) => a + baseOf(x), 0))]));
console.log(JSON.stringify(out, null, 1));
`);
ctx(localStorage, {}, html);
