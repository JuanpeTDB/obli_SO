#!/bin/bash
echo "Bienvenido a Citadel"
echo "Ingrese el numero de lo que desea hacer: "
while true; do
    echo "1) Ingresar" 
    echo "2) Crear usuario"
    read -p "Ingrese una opcion: " op
    case $op in
        "1") ./scripts/ingresar.sh
        break;;
        "2") ./scripts/crearUsu.sh;;
        *) echo "Ingrese una opcion valida"
        echo " ";;
    esac
done