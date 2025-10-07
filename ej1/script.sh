#!/bin/bash
./login.sh
op=0;
while [ $op -ne 6 ]; do
    echo "1) Cambiar Contrasenia"
    echo "2) Ingresar Producto"
    echo "3) Vender"
    echo "4) Filtrar Productos"
    echo "5) Crear Reporte"
    echo "6) Salir"
    read -p "Ingrese una opcion: " op
    case $op in
        "1") ./cambiarPass.sh;;
        "2") ./ingresarProd.sh;;
        "3") ./vender.sh;;
        "4") ./filtrarProd.sh;;
        "5") ./crearReporte.sh;;
        "6") break;;
        *) echo "Ingrese una opcion valida"
        echo " "
    esac
done