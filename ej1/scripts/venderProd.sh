#!/bin/bash
clear
echo " "
echo "A continuacion, los prodcutos disponibles ennumerados:"
awk -F' - ' '{                                                                          #HECHO CON CHATGPT
  # Detecta el precio de forma robusta:
  # si viene como "... - $ - 1500" => $6="$" y $7="1500"
  # si viene como "... - $ 1500"   => todo queda en $6
  if (NF>=7 && $6 ~ /^\$/)      price = $6 " " $7
  else if (match($0, /\$ *[0-9][0-9.,]*/)) price = substr($0, RSTART, RLENGTH)
  else                           price = $NF

  printf "%2d) %s - %s - %s\n", NR, $2, $3, price
}' docs/productos.txt
read -p "Seleccione un articulo (Por su numero): " art