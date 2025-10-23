#!/bin/bash

#SE UTILIZO CHATGPT PARA EL FORMATEO DEL ARCHIVO CSV

set -e

# --- Config básica (sin parámetros) ---
FILTRO="pintura"   # dejá vacío "" si querés exportar TODO

# Ubicaciones relativas al repo (script principal en la raíz, este en scripts/)
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
BASE_DIR="$SCRIPT_DIR/.."
PROD_FILE="$BASE_DIR/docs/productos.txt"
OUT_DIR="$BASE_DIR/Datos"
OUT_FILE="$OUT_DIR/datos.CSV"

# Verifs
[ -f "$PROD_FILE" ] || { echo "No se encontró $PROD_FILE"; exit 1; }
mkdir -p "$OUT_DIR"

# Generar CSV
awk -F' - ' -v filtro="$FILTRO" '
  BEGIN{
    OFS=","
    print "codigo,tipo,modelo,categoria,stock,precio"
  }

  # Convierte a minúsculas de forma segura
  function lower(s){ s2=s; gsub(/[ÁÀÂÄ]/,"a",s2); gsub(/[ÉÈÊË]/,"e",s2);
                     gsub(/[ÍÌÎÏ]/,"i",s2); gsub(/[ÓÒÔÖ]/,"o",s2);
                     gsub(/[ÚÙÛÜ]/,"u",s2); gsub(/Ñ/,"ñ",s2);
                     return tolower(s2) }

  # CSV: escapa comillas y envuelve en ""
  function csv(s){ gsub(/"/,"\"\"",s); return "\"" s "\"" }

  # Normaliza precio: quita $/espacios y arma punto decimal
  function normalizar_precio(s, p){
    p = s
    gsub(/[[:space:]\$]/, "", p)       # quita $ y espacios
    if (index(p, ",")>0 && index(p, ".")>0) {
      gsub(/,/, "", p)                 # 1.234,56 -> 1234.56
    } else if (index(p, ",")>0) {
      gsub(/\./, "", p); gsub(/,/, ".", p)   # 1.234 -> 1234 ; 1234,56 -> 1234.56
    } else {
      gsub(/,/, "", p)                 # 1,234.56 -> 1234.56
    }
    return p
  }

  # Saca el precio desde $6/$7 o buscando $ en la línea; si no, usa $NF
  function extraer_precio(p_raw){
    p_raw = ""
    if (NF>=7 && $6 ~ /^\$/)               p_raw=$7
    else if (match($0, /\$ *[0-9][0-9.,]*/)) p_raw=substr($0, RSTART, RLENGTH)
    else                                     p_raw=$NF
    return normalizar_precio(p_raw)
  }

  {
    # Filtro (si filtro=="", exporta todo)
    t = lower($2); c = lower($4)
    if (filtro=="" || t ~ filtro || c ~ filtro) {
      codigo    = $1
      tipo      = $2
      modelo    = $3
      categoria = $4
      stock     = $5
      if (stock !~ /^[0-9]+$/) stock = ""

      precio = extraer_precio()

      # Imprimir fila CSV (quote por seguridad)
      print csv(codigo), csv(tipo), csv(modelo), csv(categoria), stock, precio
    }
  }
' "$PROD_FILE" > "$OUT_FILE"

