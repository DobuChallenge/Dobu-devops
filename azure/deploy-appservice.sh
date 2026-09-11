#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Uso:
  ./azure/deploy-appservice.sh <resource-group> <location> <app-name-unico> <db-admin>

Exemplo:
  ./azure/deploy-appservice.sh rg-dobu brazilsouth dobu-sprint3-grupo01 dobuadmin

Variáveis opcionais:
  CLIENT_IP
      IP público da máquina que executará o psql.
      Se informado, o script cria uma regra de firewall limitada a esse IP.

  DB_PASSWORD
      Senha do administrador PostgreSQL.
      Se não for definida, o script solicita a senha sem exibi-la no terminal.

  JWT_KEY
      Chave utilizada para assinatura dos tokens JWT.
      Se não for definida, o script solicita a chave sem exibi-la no terminal.
USAGE
}

if [[ $# -ne 4 ]]; then
  usage
  exit 1
fi

for command_name in az; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Erro: comando obrigatório não encontrado: $command_name" >&2
    exit 1
  fi
done

RG="$1"
LOCATION="$2"
APP="$3"
DBADMIN="$4"

PLAN="${APP}-plan"
DB="${APP}-pg"
DBNAME="dobu"

if [[ ! "$APP" =~ ^[a-z0-9][a-z0-9-]{2,53}[a-z0-9]$ ]]; then
  echo "Erro: o nome do App Service deve usar apenas letras minúsculas, números e hífens, com 4 a 55 caracteres." >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "Erro: faça login primeiro com 'az login' e selecione a assinatura correta." >&2
  exit 1
fi

if [[ -z "${DB_PASSWORD:-}" ]]; then
  read -r -s -p "Senha do administrador PostgreSQL: " DB_PASSWORD
  echo
fi

if [[ ${#DB_PASSWORD} -lt 8 ]]; then
  echo "Erro: use uma senha PostgreSQL forte com pelo menos 8 caracteres." >&2
  exit 1
fi

if [[ -z "${JWT_KEY:-}" ]]; then
  read -r -s -p "Chave JWT (mínimo 32 caracteres): " JWT_KEY
  echo
fi

if [[ ${#JWT_KEY} -lt 32 ]]; then
  echo "Erro: JWT_KEY deve possuir pelo menos 32 caracteres." >&2
  exit 1
fi

CONN="Host=${DB}.postgres.database.azure.com;Port=5432;Database=${DBNAME};Username=${DBADMIN};Password=${DB_PASSWORD};SSL Mode=Require;Trust Server Certificate=true"

echo "[1/8] Criando/atualizando Resource Group..."

az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --output table

echo "[2/8] Criando Azure Database for PostgreSQL Flexible Server..."

az postgres flexible-server create \
  --resource-group "$RG" \
  --name "$DB" \
  --location "$LOCATION" \
  --admin-user "$DBADMIN" \
  --admin-password "$DB_PASSWORD" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 16 \
  --public-access 0.0.0.0 \
  --output table

echo "[3/8] Criando banco lógico '${DBNAME}'..."

az postgres flexible-server db create \
  --resource-group "$RG" \
  --server-name "$DB" \
  --database-name "$DBNAME" \
  --output table

if [[ -n "${CLIENT_IP:-}" ]]; then

  if [[ ! "$CLIENT_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Erro: CLIENT_IP deve conter um endereço IPv4 válido." >&2
    exit 1
  fi

  echo "[4/8] Liberando o IP do apresentador para os SELECTs via psql..."

  az postgres flexible-server firewall-rule create \
    --resource-group "$RG" \
    --name "$DB" \
    --rule-name AllowPresenterIp \
    --start-ip-address "$CLIENT_IP" \
    --end-ip-address "$CLIENT_IP" \
    --output table

else

  echo "[4/8] CLIENT_IP não informado; nenhuma regra local foi criada."
  echo "      O acesso do App Service continuará utilizando a configuração de acesso público do servidor."

fi

echo "[5/8] Criando App Service Plan Linux B1..."

az appservice plan create \
  --resource-group "$RG" \
  --name "$PLAN" \
  --location "$LOCATION" \
  --is-linux \
  --sku B1 \
  --output table

echo "[6/8] Criando Azure App Service com runtime .NET 9..."

az webapp create \
  --resource-group "$RG" \
  --plan "$PLAN" \
  --name "$APP" \
  --runtime "DOTNETCORE:9.0" \
  --output table

echo "[7/8] Configurando conexão, JWT e ambiente de produção..."

az webapp config appsettings set \
  --resource-group "$RG" \
  --name "$APP" \
  --settings \
    Database__Provider=Postgres \
    ConnectionStrings__DobuPostgres="$CONN" \
    Jwt__Key="$JWT_KEY" \
    ASPNETCORE_ENVIRONMENT=Production \
  --output none

az webapp config set \
  --resource-group "$RG" \
  --name "$APP" \
  --always-on true \
  --http20-enabled true \
  --min-tls-version 1.2 \
  --ftps-state Disabled \
  --output none

az webapp update \
  --resource-group "$RG" \
  --name "$APP" \
  --https-only true \
  --output none

echo "[8/8] Provisionamento concluído."

echo
echo "Recursos:"
echo "  Resource Group  : $RG"
echo "  App Service Plan : $PLAN"
echo "  App Service      : $APP"
echo "  PostgreSQL       : $DB"
echo "  Banco            : $DBNAME"

echo
echo "Próximos passos:"
echo "  1. Execute script_bd.sql com psql (consulte o README.md)."
echo "  2. Publique a API com: ./azure/deploy-code.sh '$RG' '$APP'"
echo "  3. Acesse: https://${APP}.azurewebsites.net/swagger"
