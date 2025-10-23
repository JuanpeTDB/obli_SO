#!/bin/bash
clear
opc=s
while [ $opc != "n" ] 
do
  echo " "
  read -r -p "Ingrese qué tipo de productos quiere filtrar, Digite 0 para filtrar todos los productos: " filtro

  if [ "$filtro" == "0" ]; then
    echo ""
    echo "Listando todos los productos..."
    cat docs/productos.txt
  else
    echo ""
    echo "Listando los productos filtrados por '$filtro'..."
    # -i: case-insensitive
    grep -i -F "$filtro" docs/productos.txt
  fi

  echo " "
  read -p "Deseas hacer otra busqueda por filtro? [s/n] " opc
done
