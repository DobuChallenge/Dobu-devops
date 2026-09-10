
-- DOBU - SPRINT 3 | DEVOPS TOOLS & CLOUD COMPUTING
-- Banco: Azure Database for PostgreSQL Flexible Server (PostgreSQL 16)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Usuários responsáveis e veterinários vinculados ao domínio veterinário.
CREATE TABLE IF NOT EXISTS USUARIO (
    ID_USUARIO_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    NOME_USUARIO varchar(100) NOT NULL,
    DESC_EMAIL varchar(150) NOT NULL UNIQUE,
    DESC_SENHA varchar(255) NOT NULL,
    TIPO_USUARIO varchar(20) NOT NULL,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

-- Espécies atendidas pela plataforma.
CREATE TABLE IF NOT EXISTS ESPECIE (
    ID_ESPECIE_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    NOME_ESPECIE varchar(80) NOT NULL,
    DESC_ESPECIE varchar(300) NOT NULL,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

-- Raças associadas a uma espécie.
CREATE TABLE IF NOT EXISTS RACA (
    ID_RACA_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    NOME_RACA varchar(80) NOT NULL,
    TIPO_PORTE varchar(20) NOT NULL,
    NUMERO_EXPECTATIVA integer NOT NULL,
    DESC_RACA varchar(300),
    DESC_CUIDADOS varchar(500),
    ID_ESPECIE_FK uuid NOT NULL REFERENCES ESPECIE(ID_ESPECIE_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

-- CORE: animal acompanhado pela plataforma.
CREATE TABLE IF NOT EXISTS PET (
    ID_PET_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    NOME_PET varchar(80) NOT NULL,
    NUMERO_IDADE integer NOT NULL CHECK (NUMERO_IDADE >= 0),
    ID_RACA_FK uuid NOT NULL REFERENCES RACA(ID_RACA_PK) ON DELETE RESTRICT,
    ID_RESPONSAVEL_FK uuid NOT NULL REFERENCES USUARIO(ID_USUARIO_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

-- CORE: atendimento veterinário; cada consulta pertence a um PET.
CREATE TABLE IF NOT EXISTS CONSULTA (
    ID_CONSULTA_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    DATA_CONSULTA timestamptz NOT NULL,
    DESC_CONSULTA varchar(500) NOT NULL,
    VALOR_CONSULTA numeric(10,2) NOT NULL CHECK (VALOR_CONSULTA >= 0),
    ID_PET_FK uuid NOT NULL REFERENCES PET(ID_PET_PK) ON DELETE RESTRICT,
    ID_VETERINARIO_FK uuid NOT NULL REFERENCES USUARIO(ID_USUARIO_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS AGENDAMENTO (
    ID_AGENDAMENTO_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    DATA_AGENDAMENTO timestamptz NOT NULL,
    STATUS_AGENDAMENTO varchar(30) NOT NULL,
    ID_PET_FK uuid NOT NULL REFERENCES PET(ID_PET_PK) ON DELETE RESTRICT,
    ID_VETERINARIO_FK uuid NOT NULL REFERENCES USUARIO(ID_USUARIO_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS PRONTUARIO (
    ID_PRONTUARIO_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    DESC_DIAGNOSTICO varchar(500) NOT NULL,
    DESC_OBSERVACOES varchar(500),
    ID_CONSULTA_FK uuid NOT NULL UNIQUE REFERENCES CONSULTA(ID_CONSULTA_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS VACINA (
    ID_VACINA_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    NOME_VACINA varchar(100) NOT NULL,
    DATA_APLICACAO timestamptz NOT NULL,
    DATA_PROXIMA_DOSE timestamptz,
    ID_PET_FK uuid NOT NULL REFERENCES PET(ID_PET_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS PAGAMENTO (
    ID_PAGAMENTO_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    VALOR_PAGAMENTO numeric(10,2) NOT NULL,
    TIPO_FORMA_PAGAMENTO varchar(40) NOT NULL,
    DATA_PAGAMENTO timestamptz NOT NULL,
    ID_CONSULTA_FK uuid NOT NULL UNIQUE REFERENCES CONSULTA(ID_CONSULTA_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS LEMBRETE (
    ID_LEMBRETE_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    DESC_LEMBRETE varchar(300) NOT NULL,
    DATA_LEMBRETE timestamptz NOT NULL,
    STATUS_LEMBRETE varchar(30) NOT NULL,
    ID_PET_FK uuid NOT NULL REFERENCES PET(ID_PET_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS DOBUCAM (
    ID_DOBUCAM_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    DESC_LOCALIZACAO varchar(150) NOT NULL,
    STATUS_CAMERA varchar(30) NOT NULL,
    DATA_ULTIMA_MOVIMENTACAO timestamptz,
    ID_PET_FK uuid NOT NULL REFERENCES PET(ID_PET_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS ANALISE_IA (
    ID_ANALISE_IA_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    DESC_ANALISE varchar(800) NOT NULL,
    NUMERO_RISCO integer NOT NULL,
    DATA_ANALISE timestamptz NOT NULL,
    ID_PRONTUARIO_FK uuid NOT NULL UNIQUE REFERENCES PRONTUARIO(ID_PRONTUARIO_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS LOG_ERRO (
    ID_LOG_ERRO_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    NOME_PROCEDURE varchar(100) NOT NULL,
    DESC_ERRO varchar(1000) NOT NULL,
    DATA_ERRO timestamptz NOT NULL,
    ID_USUARIO_FK uuid NOT NULL REFERENCES USUARIO(ID_USUARIO_PK) ON DELETE RESTRICT,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS INFORMACAO_CUIDADO (
    ID_INFORMACAO_CUIDADO_PK uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    TITULO varchar(120) NOT NULL,
    DESCRICAO varchar(1000) NOT NULL,
    ID_PET_FK uuid NOT NULL REFERENCES PET(ID_PET_PK) ON DELETE CASCADE,
    CREATED_AT timestamptz NOT NULL DEFAULT now(),
    ACTIVE boolean NOT NULL DEFAULT true
);

-- ==========================================================================
-- COMENTÁRIOS DO DDL
-- ==========================================================================
COMMENT ON TABLE USUARIO IS 'Usuários da plataforma; nesta solução representam responsáveis e veterinários.';
COMMENT ON TABLE ESPECIE IS 'Espécies de animais atendidas pela plataforma Dobu.';
COMMENT ON TABLE RACA IS 'Raças de animais, vinculadas a uma espécie.';
COMMENT ON TABLE PET IS 'Tabela CORE: pets acompanhados pela plataforma e vinculados a raça e responsável.';
COMMENT ON TABLE CONSULTA IS 'Tabela CORE: consultas veterinárias vinculadas a um pet e a um veterinário.';
COMMENT ON TABLE AGENDAMENTO IS 'Agenda de atendimentos futuros dos pets.';
COMMENT ON TABLE PRONTUARIO IS 'Registro clínico produzido a partir de uma consulta veterinária.';
COMMENT ON TABLE VACINA IS 'Vacinas aplicadas aos pets e próximas doses previstas.';
COMMENT ON TABLE PAGAMENTO IS 'Pagamento associado a uma consulta.';
COMMENT ON TABLE LEMBRETE IS 'Lembretes de cuidados e compromissos associados ao pet.';
COMMENT ON TABLE DOBUCAM IS 'Dados de monitoramento da câmera associada ao pet.';
COMMENT ON TABLE ANALISE_IA IS 'Análise automatizada vinculada ao prontuário.';
COMMENT ON TABLE LOG_ERRO IS 'Registro técnico de erros associados a usuários da aplicação.';
COMMENT ON TABLE INFORMACAO_CUIDADO IS 'Conteúdos e orientações de cuidado associados ao pet.';

COMMENT ON COLUMN PET.ID_PET_PK IS 'Chave primária UUID do pet.';
COMMENT ON COLUMN PET.NOME_PET IS 'Nome do animal.';
COMMENT ON COLUMN PET.NUMERO_IDADE IS 'Idade do pet em anos; não pode ser negativa.';
COMMENT ON COLUMN PET.ID_RACA_FK IS 'Chave estrangeira para a raça do pet.';
COMMENT ON COLUMN PET.ID_RESPONSAVEL_FK IS 'Chave estrangeira para o usuário responsável pelo pet.';
COMMENT ON COLUMN PET.CREATED_AT IS 'Data e hora de criação do registro.';
COMMENT ON COLUMN PET.ACTIVE IS 'Indicador de registro ativo.';

COMMENT ON COLUMN CONSULTA.ID_CONSULTA_PK IS 'Chave primária UUID da consulta.';
COMMENT ON COLUMN CONSULTA.DATA_CONSULTA IS 'Data e hora do atendimento veterinário.';
COMMENT ON COLUMN CONSULTA.DESC_CONSULTA IS 'Descrição clínica/resumo da consulta.';
COMMENT ON COLUMN CONSULTA.VALOR_CONSULTA IS 'Valor monetário da consulta; não pode ser negativo.';
COMMENT ON COLUMN CONSULTA.ID_PET_FK IS 'Chave estrangeira que relaciona a consulta ao PET.';
COMMENT ON COLUMN CONSULTA.ID_VETERINARIO_FK IS 'Chave estrangeira para o usuário veterinário responsável.';
COMMENT ON COLUMN CONSULTA.CREATED_AT IS 'Data e hora de criação do registro.';
COMMENT ON COLUMN CONSULTA.ACTIVE IS 'Indicador de registro ativo.';

COMMENT ON COLUMN USUARIO.ID_USUARIO_PK IS 'Chave primária UUID do usuário.';
COMMENT ON COLUMN USUARIO.TIPO_USUARIO IS 'Perfil de domínio: RESPONSAVEL ou VETERINARIO.';
COMMENT ON COLUMN RACA.ID_RACA_PK IS 'Chave primária UUID da raça.';
COMMENT ON COLUMN RACA.ID_ESPECIE_FK IS 'Chave estrangeira para a espécie.';
COMMENT ON COLUMN ESPECIE.ID_ESPECIE_PK IS 'Chave primária UUID da espécie.';

-- DADOS SIGNIFICATIVOS PARA A DEMONSTRAÇÃO

INSERT INTO ESPECIE (
    ID_ESPECIE_PK,
    NOME_ESPECIE,
    DESC_ESPECIE
)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Cão',
    'Cachorro doméstico'
)
ON CONFLICT DO NOTHING;

INSERT INTO RACA (
    ID_RACA_PK,
    NOME_RACA,
    TIPO_PORTE,
    NUMERO_EXPECTATIVA,
    DESC_RACA,
    DESC_CUIDADOS,
    ID_ESPECIE_FK
)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    'Golden Retriever',
    'Grande',
    12,
    'Raça sociável e ativa',
    'Exercício diário e acompanhamento veterinário preventivo',
    '11111111-1111-1111-1111-111111111111'
)
ON CONFLICT DO NOTHING;

INSERT INTO USUARIO (
    ID_USUARIO_PK,
    NOME_USUARIO,
    DESC_EMAIL,
    DESC_SENHA,
    TIPO_USUARIO
)
VALUES
(
    '33333333-3333-3333-3333-333333333333',
    'Dra. Ana Martins',
    'ana.vet@dobu.com',
    'hash-de-seed-nao-utilizado-para-login',
    'VETERINARIO'
),
(
    '44444444-4444-4444-4444-444444444444',
    'Carlos Oliveira',
    'carlos.responsavel@dobu.com',
    'hash-de-seed-nao-utilizado-para-login',
    'RESPONSAVEL'
)
ON CONFLICT DO NOTHING;

-- Duas linhas significativas na tabela CORE PET.
INSERT INTO PET (
    ID_PET_PK,
    NOME_PET,
    NUMERO_IDADE,
    ID_RACA_FK,
    ID_RESPONSAVEL_FK
)
VALUES
(
    '55555555-5555-5555-5555-555555555555',
    'Luna',
    4,
    '22222222-2222-2222-2222-222222222222',
    '44444444-4444-4444-4444-444444444444'
),
(
    '66666666-6666-6666-6666-666666666666',
    'Thor',
    7,
    '22222222-2222-2222-2222-222222222222',
    '44444444-4444-4444-4444-444444444444'
)
ON CONFLICT DO NOTHING;

-- Duas linhas significativas na tabela CORE CONSULTA, relacionadas aos pets.
INSERT INTO CONSULTA (
    ID_CONSULTA_PK,
    DATA_CONSULTA,
    DESC_CONSULTA,
    VALOR_CONSULTA,
    ID_PET_FK,
    ID_VETERINARIO_FK
)
VALUES
(
    '77777777-7777-7777-7777-777777777777',
    TIMESTAMPTZ '2026-09-10 13:00:00-03',
    'Avaliação preventiva anual da Luna',
    180.00,
    '55555555-5555-5555-5555-555555555555',
    '33333333-3333-3333-3333-333333333333'
),
(
    '88888888-8888-8888-8888-888888888888',
    TIMESTAMPTZ '2026-09-11 15:30:00-03',
    'Acompanhamento dermatológico do Thor',
    220.00,
    '66666666-6666-6666-6666-666666666666',
    '33333333-3333-3333-3333-333333333333'
)
ON CONFLICT DO NOTHING;
