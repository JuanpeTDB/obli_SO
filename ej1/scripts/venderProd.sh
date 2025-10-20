#!/bin/bash
clear
echo " "
echo "A continuacion, los prodcutos disponibles ennumerados:"

awk -F' - ' '{
  if (NF>=7 && $6 ~ /^\$/)      price = $6 " " $7
  else if (match($0, /\$ *[0-9][0-9.,]*/)) price = substr($0, RSTART, RLENGTH)
  else                           price = $NF
  printf "%2d) %s - %s - %s\n", NR, $2, $3, price
}' docs/productos.txt

opc=n
while [ $opc != "s" ]; do
    read -p "Seleccione un articulo (Por su numero): " art
    read -p "Ingrese cantidad que quiere llevar: " cant

    total=`cat docs/productos.txt | wc -l`

    # validar número de producto (entero y en rango)
    if ! echo "$art" | grep -Eq '^[0-9]+$'; then
        echo "Numero de producto invalido."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case $opc in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi
    if [ "$art" -lt 1 ] || [ "$art" -gt "$total" ]; then
        echo "Numero fuera de rango (1..$total)."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case $opc in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    # obtener y validar stock de esa línea
    stock=`awk -F' - ' -v n="$art" 'NR==n{print $5}' docs/productos.txt`
    if ! echo "$stock" | grep -Eq '^[0-9]+$'; then
        echo "Stock invalido en el sistema para $art."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case $opc in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    # validar cantidad pedida (entero positivo)
    if ! echo "$cant" | grep -Eq '^[0-9]+$'; then
        echo "Cantidad invalida (debe ser entero positivo)."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case $opc in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi
    if [ "$cant" -lt 1 ]; then
        echo "La cantidad minima es 1."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case $opc in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    # no superar stock
    if [ "$cant" -gt "$stock" ]; then
        echo "No hay stock suficiente. Disponible: $stock."
        read -p "Desea volver a intentarlo? [s/n] " opc
        case $opc in
            "s") opc=m; echo " "; continue;;
            "n") opc=s; break;;
            *) echo "Ingrese una opcion valida"; echo " "; opc=m; continue;;
        esac
    fi

    echo "Cantidad valida (stock disponible: $stock)."
    opc=s   # pasar a 'salir' del bucle porque todo fue OK
done
