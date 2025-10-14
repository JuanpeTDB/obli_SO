#!/bin/bash
clear
./scripts/login.sh
op=0;
while [ $op -ne 6 ]; do
    clear
    echo " "
    echo "1) Cambiar Contrasenia"
    echo "2) Ingresar Producto"
    echo "3) Vender"
    echo "4) Filtrar Productos"
    echo "5) Crear Reporte"
    echo "6) Salir"
    read -p "Ingrese una opcion: " op
    case $op in
        "1") ./scripts/cambiarPass.sh;;
        "2") ./scripts/ingresarProd.sh;;
        "3") ./scripts/venderProd.sh;;
        "4") ./scripts/filtrarProd.sh;;
        "5") ./scripts/crearReporte.sh;;
        "6") break;;
        *) echo "Ingrese una opcion valida"
        echo " "
    esac
done