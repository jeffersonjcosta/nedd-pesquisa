const db = () => window._supabase;

function toast(msg, type = 'success', duration = 4000) {
  const el = document.createElement('div');
  el.className = `toast ${type}`;
  el.textContent = msg;
  document.body.appendChild(el);
  setTimeout(() => el.remove(), duration);
}

function formatDate(dateStr) {
  if (!dateStr) return '—';
  const [y, m, d] = dateStr.split('-');
  return `${d}/${m}/${y}`;
}

function formatDateTime(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return d.toLocaleDateString('pt-BR') + ' ' + d.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
}

function today() {
  return new Date().toISOString().split('T')[0];
}

function generateCode() {
  const year = new Date().getFullYear();
  const rand = Math.random().toString(36).substring(2, 7).toUpperCase();
  return `NEDD-${year}-${rand}`;
}

function collectForm(formEl) {
  const data = {};
  const inputs = formEl.querySelectorAll('[name]');
  inputs.forEach(input => {
    if (input.type === 'checkbox') {
      if (!data[input.name]) data[input.name] = [];
      if (input.checked) data[input.name].push(input.value || true);
    } else if (input.type === 'radio') {
      if (input.checked) data[input.name] = input.value;
    } else {
      data[input.name] = input.value || null;
    }
  });
  formEl.querySelectorAll('.scale-btn.selected').forEach(btn => {
    data[btn.dataset.name] = parseInt(btn.dataset.value);
  });
  formEl.querySelectorAll('.radio-item.selected').forEach(item => {
    data[item.dataset.name] = item.dataset.value;
  });
  return data;
}

function validateRequired(formEl) {
  const missing = [];
  formEl.querySelectorAll('[required]').forEach(el => {
    if (!el.value || el.value.trim() === '') {
      missing.push(el.closest('.form-group')?.querySelector('label')?.textContent?.replace('*', '').trim() || el.name);
      el.style.borderColor = 'var(--danger)';
      el.addEventListener('input', () => el.style.borderColor = '', { once: true });
    }
  });
  return missing;
}

function exportCSV(data, filename) {
  if (!data.length) { toast('Nenhum dado para exportar.', 'error'); return; }
  const keys = Object.keys(data[0]);
  const csv = [
    keys.join(';'),
    ...data.map(row => keys.map(k => {
      const val = row[k] ?? '';
      const str = Array.isArray(val) ? val.join('|') : String(val);
      return str.includes(';') || str.includes('"') || str.includes('\n')
        ? `"${str.replace(/"/g, '""')}"` : str;
    }).join(';'))
  ].join('\r\n');
  const blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = filename; a.click();
  URL.revokeObjectURL(url);
  toast(`Exportado: ${filename}`);
}

document.addEventListener('click', e => {
  const item = e.target.closest('.radio-item[data-name]');
  if (!item) return;
  const group = item.dataset.name;
  document.querySelectorAll(`.radio-item[data-name="${group}"]`).forEach(i => i.classList.remove('selected'));
  item.classList.add('selected');
});

document.addEventListener('click', e => {
  const btn = e.target.closest('.scale-btn[data-name]');
  if (!btn) return;
  const name = btn.dataset.name;
  document.querySelectorAll(`.scale-btn[data-name="${name}"]`).forEach(b => b.classList.remove('selected'));
  btn.classList.add('selected');
});

async function loadParticipantes(selectId) {
  try {
    const { data } = await db().from('participantes').select('*').order('codigo');
    const sel = document.getElementById(selectId);
    if (!sel) return;
    sel.innerHTML = '<option value="">Selecione o participante...</option>';
    (data || []).forEach(p => {
      const o = document.createElement('option');
      o.value = p.codigo;
      o.textContent = `${p.codigo}${p.iniciais ? ' — ' + p.iniciais : ''}${p.sexo ? ' (' + p.sexo + ')' : ''}`;
      sel.appendChild(o);
    });
  } catch(e) {}
}

async function loadPesquisadores(selectId) {
  try {
    const { data } = await db().from('pesquisadores').select('id, nome, nivel').order('nome');
    const sel = document.getElementById(selectId);
    if (!sel) return;
    (data || []).forEach(p => {
      const o = document.createElement('option');
      o.value = p.id;
      o.textContent = `${p.nome} (${p.nivel})`;
      sel.appendChild(o);
    });
  } catch(e) {}
}

function updateProgress(formEl, barEl) {
  const all = formEl.querySelectorAll('[name]');
  let filled = 0;
  all.forEach(el => {
    if (el.type === 'checkbox') { if (el.checked) filled++; }
    else if (el.value) filled++;
  });
  const pct = Math.round((filled / all.length) * 100);
  if (barEl) barEl.style.width = pct + '%';
  return pct;
}
