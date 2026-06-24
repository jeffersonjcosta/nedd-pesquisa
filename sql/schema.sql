-- ============================================================
-- NEDD/UFF — Schema do Banco de Dados
-- Supabase / PostgreSQL
-- Execute no SQL Editor do Supabase (supabase.com/dashboard)
-- ============================================================

-- ── Pesquisadores ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pesquisadores (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome          TEXT NOT NULL,
  email         TEXT UNIQUE,
  nivel         TEXT,
  area          TEXT,
  lattes_url    TEXT,
  orientador    TEXT,
  ativo         BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ── Estudos / Protocolos ──────────────────────────────────
CREATE TABLE IF NOT EXISTS estudos (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo              TEXT NOT NULL,
  tipo                TEXT,
  responsavel_id      UUID REFERENCES pesquisadores(id),
  caae                TEXT,
  data_inicio         DATE,
  data_prevista_fim   DATE,
  n_previsto          INTEGER,
  status              TEXT DEFAULT 'Em andamento',
  objetivo            TEXT,
  criterios_inclusao  TEXT,
  criterios_exclusao  TEXT,
  formularios         TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ── Anamnese Fonoaudiológica ──────────────────────────────
CREATE TABLE IF NOT EXISTS anamnese (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_participante       TEXT NOT NULL,
  data_avaliacao            DATE,
  pesquisador_id            UUID REFERENCES pesquisadores(id),
  estudo_id                 UUID REFERENCES estudos(id),
  -- Dados sociodemográficos
  nome_iniciais             TEXT,
  data_nascimento           DATE,
  idade                     INTEGER,
  sexo                      TEXT,
  escolaridade              TEXT,
  estado_civil              TEXT,
  municipio                 TEXT,
  -- História clínica
  diagnostico_principal     TEXT,
  cid10                     TEXT,
  comorbidades              TEXT,
  medicamentos              TEXT,
  tempo_diagnostico         TEXT,
  internacoes_previas       TEXT,
  -- Sintomas de disfagia
  sintomas_disfagia         TEXT,   -- separados por |
  tempo_sintomas            TEXT,
  -- Alimentação atual
  via_alimentacao           TEXT,
  consistencia_alimentos    TEXT,
  consistencia_liquidos     TEXT,
  uso_espessante            TEXT,
  volume_por_refeicao       TEXT,
  numero_refeicoes          TEXT,
  perda_peso                TEXT,
  observacoes               TEXT,
  created_at                TIMESTAMPTZ DEFAULT NOW()
);

-- ── Avaliação Clínica da Deglutição ──────────────────────
CREATE TABLE IF NOT EXISTS avaliacao_degluticao (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_participante       TEXT NOT NULL,
  data_avaliacao            DATE,
  pesquisador_id            UUID REFERENCES pesquisadores(id),
  estudo_id                 UUID REFERENCES estudos(id),
  -- Estruturas orofaciais
  labios                    TEXT,
  lingua                    TEXT,
  palato_mole               TEXT,
  mandibula                 TEXT,
  reflexo_nauseoso          TEXT,
  sensibilidade_oral        TEXT,
  -- Deglutição de saliva
  deglut_saliva             TEXT,
  residuo_oral_saliva       TEXT,
  elevacao_laringe          TEXT,
  -- Oferta IDDSI
  iddsi_0_volume            TEXT,
  iddsi_0_eficiencia        TEXT,
  iddsi_0_seguranca         TEXT,
  iddsi_0_spo2_antes        NUMERIC,
  iddsi_0_spo2_apos         NUMERIC,
  iddsi_2_volume            TEXT,
  iddsi_2_eficiencia        TEXT,
  iddsi_2_seguranca         TEXT,
  iddsi_2_spo2_antes        NUMERIC,
  iddsi_2_spo2_apos         NUMERIC,
  iddsi_3_volume            TEXT,
  iddsi_3_eficiencia        TEXT,
  iddsi_3_seguranca         TEXT,
  iddsi_3_spo2_antes        NUMERIC,
  iddsi_3_spo2_apos         NUMERIC,
  iddsi_4_volume            TEXT,
  iddsi_4_eficiencia        TEXT,
  iddsi_4_seguranca         TEXT,
  iddsi_4_spo2_antes        NUMERIC,
  iddsi_4_spo2_apos         NUMERIC,
  iddsi_6_volume            TEXT,
  iddsi_6_eficiencia        TEXT,
  iddsi_6_seguranca         TEXT,
  iddsi_6_spo2_antes        NUMERIC,
  iddsi_6_spo2_apos         NUMERIC,
  -- SpO2 consolidado (melhor preencher pelo form)
  spo2_antes                NUMERIC,
  spo2_apos                 NUMERIC,
  -- Conclusão
  classificacao_disfagia    TEXT,
  fase_afetada              TEXT,
  via_recomendada           TEXT,
  consistencia_recomendada  TEXT,
  encaminhamentos           TEXT,
  observacoes               TEXT,
  created_at                TIMESTAMPTZ DEFAULT NOW()
);

-- ── SWAL-QOL ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS swal_qol (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_participante TEXT NOT NULL,
  data_avaliacao      DATE,
  pesquisador_id      UUID REFERENCES pesquisadores(id),
  estudo_id           UUID REFERENCES estudos(id),
  aplicacao           TEXT DEFAULT 'Inicial',
  -- Itens (1–5 cada)
  q1                  INTEGER, q2  INTEGER, q3  INTEGER,
  q4                  INTEGER, q5  INTEGER, q6  INTEGER,
  q7                  INTEGER, q8  INTEGER, q9  INTEGER,
  q10                 INTEGER,
  -- Scores calculados
  pontuacao_total     INTEGER,
  pontuacao_maxima    INTEGER DEFAULT 50,
  pontuacao_pct       NUMERIC(5,1),
  observacoes         TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ── Follow-up / Seguimento ────────────────────────────────
CREATE TABLE IF NOT EXISTS follow_up (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo_participante   TEXT NOT NULL,
  data_avaliacao        DATE,
  pesquisador_id        UUID REFERENCES pesquisadores(id),
  ponto_seguimento      TEXT,
  -- Evolução clínica
  evolucao_geral        TEXT,
  via_alimentacao_atual TEXT,
  mudanca_via           TEXT,
  consistencia_liquidos TEXT,
  sintomas_atuais       TEXT,   -- separados por |
  -- Intervenção
  realizou_terapia      TEXT,
  n_sessoes             INTEGER,
  tecnicas              TEXT,
  conduta_proxima       TEXT,
  observacoes           TEXT,
  created_at            TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Row Level Security (RLS)
-- ============================================================
ALTER TABLE pesquisadores        ENABLE ROW LEVEL SECURITY;
ALTER TABLE estudos              ENABLE ROW LEVEL SECURITY;
ALTER TABLE anamnese             ENABLE ROW LEVEL SECURITY;
ALTER TABLE avaliacao_degluticao ENABLE ROW LEVEL SECURITY;
ALTER TABLE swal_qol             ENABLE ROW LEVEL SECURITY;
ALTER TABLE follow_up            ENABLE ROW LEVEL SECURITY;

-- Qualquer pessoa pode inserir (coleta de dados via formulário público)
CREATE POLICY "anon_insert_pesquisadores"        ON pesquisadores        FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "anon_insert_estudos"              ON estudos              FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "anon_insert_anamnese"             ON anamnese             FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "anon_insert_avaliacao_degluticao" ON avaliacao_degluticao FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "anon_insert_swal_qol"             ON swal_qol             FOR INSERT TO anon WITH CHECK (TRUE);
CREATE POLICY "anon_insert_follow_up"            ON follow_up            FOR INSERT TO anon WITH CHECK (TRUE);

-- Leitura de pesquisadores e estudos: anon pode ler (necessário para preencher selects nos formulários)
CREATE POLICY "anon_select_pesquisadores" ON pesquisadores FOR SELECT TO anon USING (TRUE);
CREATE POLICY "anon_select_estudos"       ON estudos       FOR SELECT TO anon USING (TRUE);

-- Leitura de dados clínicos: apenas usuários autenticados (admin)
CREATE POLICY "auth_select_anamnese"             ON anamnese             FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "auth_select_avaliacao_degluticao" ON avaliacao_degluticao FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "auth_select_swal_qol"             ON swal_qol             FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "auth_select_follow_up"            ON follow_up            FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "auth_select_pesquisadores"        ON pesquisadores        FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "auth_select_estudos"              ON estudos              FOR SELECT TO authenticated USING (TRUE);
