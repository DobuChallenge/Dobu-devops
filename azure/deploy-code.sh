#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Uso: ./azure/deploy-code.sh <resource-group> <app-name>" >&2
  exit 1
fi

for command_name in az dotnet zip; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Erro: comando obrigatório não encontrado: $command_name" >&2
    exit 1
  fi
done

RG="$1"
APP="$2"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKDIR="$(mktemp -d)"
PUBLISH_DIR="$WORKDIR/publish"
ZIP_PATH="$WORKDIR/dobu-app.zip"
trap 'rm -rf "$WORKDIR"' EXIT

echo "[1/3] Publicando a API em modo Release..."
dotnet publish "$ROOT/DOBU/Dobu.Api/Dobu.Api.csproj" \
  --configuration Release \
  --output "$PUBLISH_DIR"

echo "[2/3] Gerando pacote ZIP com os arquivos publicados na raiz..."
(
  cd "$PUBLISH_DIR"
  zip -qr "$ZIP_PATH" .
)

echo "[3/3] Enviando pacote ao Azure App Service via Azure CLI..."
az webapp deploy \
  --resource-group "$RG" \
  --name "$APP" \
  --src-path "$ZIP_PATH" \
  --type zip \
  --output table

echo
echo "Deploy concluído."
echo "Swagger: https://${APP}.azurewebsites.net/swagger"
echo "Health : https://${APP}.azurewebsites.net/health/ready"
