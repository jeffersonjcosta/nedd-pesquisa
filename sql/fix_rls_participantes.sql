-- ============================================================
-- 1. Corrigir permissão do dropdown de pesquisadores
-- ============================================================
DROP POLICY IF EXISTS "anon_select_pesquisadores" ON pesquisadores;
CREATE POLICY "anon_select_pesquisadores" ON pesquisadores FOR SELECT TO anon USING (TRUE);

DROP POLICY IF EXISTS "anon_select_estudos" ON estudos;
CREATE POLICY "anon_select_estudos" ON estudos FOR SELECT TO anon USING (TRUE);

-- ============================================================
-- 2. Tabela de participantes (código único por paciente)
-- ============================================================
CREATE TABLE IF NOT EXISTS participantes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo        TEXT UNIQUE NOT NULL,
  iniciais      TEXT,
  data_nascimento DATE,
  sexo          TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE participantes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_insert_participantes" ON participantes FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "anon_select_participantes" ON participantes FOR SELECT TO anon USING (TRUE);
CREATE POLICY "auth_select_participantes" ON participantes FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "auth_all_participantes"    ON participantes FOR ALL    TO authenticated USING (TRUE);
