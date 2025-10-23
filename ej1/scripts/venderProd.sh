#!/bin/bash
# SE UTILIZO CHATGPT PARA FORMATEAR COMO MOSTRAR EN PANTALLA 
# LOS PRODUCTOS DISPONIBLES Y PARA ELIMINAR DEL STOCK LA CANTIDAD DE CADA PRODUCTO VENDIDO
clear
touch carrito.txt
RESTAS_FILE=$(mktemp)

# borrar temporales al salir, pase lo que pase
trap 'rm -f "$RESTAS_FILE" carrito.txt' EXIT

opc=n
while [ "$opc" != "s" ]; do
    echo " "
    # Verificar archivo de productos
    if [ ! -f docs/productos.txt ]; then
        echo "No existe docs/productos.txt"; break
    fi

    echo "A continuacion, los productos disponibles enumerados:"

    awk -F' - ' '{
      if (NF>=7 && $6 ~ /^\$/)      price = $6 " " $7
      else if (match($0, /\$ *[0-9][0-9.,]*/)) price = substr($0, RSTART, RLENGTH)
      else                           price = $NF
      printf "%2d) %s - %s - %s\n", NR, $2, $3, price
    }' docs/productos.txt

    total=$(wc -l < docs/productos.txt)
    if [ "$total" -eq 0 ]; then
        echo "No hay productos cargados."; break
    fi

    read -p "Ingrese el numero de articulo que quiere agregar: " art

    # --- art: validar que sea entero >=1 ---
    echo "$art" | grep -Eq '^[1-9][0-9]*$'
    es_num_art=$?
    if [ $es_num_art -ne 0 ]; then
        echo "Numero de producto invalido (debe ser entero >= 1)."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case "$opc" in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    # --- art: validar rango 1..total ---
    if [ "$art" -gt "$total" ]; then
        echo "Numero fuera de rango (1..$total)."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case "$opc" in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    # Obtener tipo, modelo y precio NUMÉRICO (sin símbolo) de la línea $art
    info=$(awk -F' - ' -v n="$art" '
    NR==n{
      # Precio bruto
      if (NF>=7 && $6 ~ /^\$/)                 p_raw=$7;
      else if (match($0, /\$ *[0-9][0-9.,]*/)) p_raw=substr($0, RSTART, RLENGTH);
      else                                     p_raw=$NF;

      # Normalizar: "1.500,75" -> 1500.75 ; "1,500.75" -> 1500.75
      p=p_raw;
      gsub(/[[:space:]\$]/,"",p);
      if (index(p,",")>0 && index(p,".")>0)      gsub(/,/, "", p);
      else if (index(p,",")>0) { gsub(/\./,"",p); gsub(/,/, ".", p) }
      else                                       gsub(/,/, "", p);

      printf "%s\t%s\t%s\n", $2, $3, p; exit
    }' docs/productos.txt)

    # Si no se pudo extraer (no debería pasar tras validar rango), volver al inicio
    if [ -z "$info" ]; then
        echo "No se pudo leer el articulo seleccionado."
        opc=m; continue
    fi

    IFS=$'\t' read -r tipo modelo precio <<< "$info"   # precio = número puro
    echo "Precio :$precio"

    # --- obtener y validar stock (entero >=0) ---
    stock=$(awk -F' - ' -v n="$art" 'NR==n{print $5}' docs/productos.txt)
    echo "$stock" | grep -Eq '^[0-9]+$'
    es_num_stock=$?
    if [ $es_num_stock -ne 0 ]; then
        echo "Stock invalido en el sistema para $art."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case "$opc" in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    # Total (usa awk para decimales)
    read -p "Ingrese cantidad que quiere llevar: " cant

    # --- cant: validar entero >=1 ---
    echo "$cant" | grep -Eq '^[1-9][0-9]*$'
    es_num_cant=$?
    if [ $es_num_cant -ne 0 ]; then
        echo "Cantidad invalida (debe ser entero >= 1)."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case "$opc" in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    # --- no superar stock ---
    if [ "$cant" -gt "$stock" ]; then
        echo "No hay stock suficiente. Disponible: $stock."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case "$opc" in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    precioProd=$(awk -v c="$cant" -v p="$precio" 'BEGIN{printf "%.2f", c*p}')
    

    echo "Cantidad valida."
    # imprimir $ literal: usá \$
    echo "$tipo - $modelo - $cant - \$ $precioProd" >> carrito.txt
    echo "$art;$cant" >> "$RESTAS_FILE"
    echo "Venta hasta el momento: "
    cat carrito.txt

    read -p "Deseas finalizar la venta? [s/n]: " opc
    if [ "$opc" = "s" ]; then
        PROD_FILE="docs/productos.txt"
tmpf=$(mktemp)

awk -F' - ' 'BEGIN{OFS=" - "}
  # 1) Leer RESTAS_FILE (formato "linea;cantidad") sin depender de FS:
  FNR==NR { split($0,a,";"); dec[a[1]] += (a[2]+0); next }

  # 2) En productos, tocar solo $5 y luego imprimir la línea entera
  {
    ln = FNR
    if (ln in dec) {
      $5 = $5 - dec[ln]
      if ($5 < 0) $5 = 0
    }
    print  # <<-- imprime exactamente la cantidad original de campos, sin guiones extra
  }
' "$RESTAS_FILE" "$PROD_FILE" > "$tmpf" && mv "$tmpf" "$PROD_FILE"


        # opc ya es "s": el while terminará al reevaluarse
    else
        opc=m
        echo " "
    fi
done
