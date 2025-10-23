#!/bin/bash
ingreso=n
while [ $ingreso != 's' ] 
do 
    clear
    echo " "
    echo "Bienvenido a Citadel"
    echo "Ingrese el numero de lo que desea hacer: "
    echo "1) Ingresar" 
    echo "2) Crear usuario"
    read -p "Ingrese una opcion: " op
    case $op in
        "1") opc=n
        while 
        [ $opc != 's' ] 
        do
            echo " "
            read -p "Ingrese nombre de usuario: " usu
            read -p "Ingrese su contrasenia: " pass
            usupass="$usu;$pass"
            cantUsu=`cat docs/usuarios.txt | grep "$usupass" | wc -l`
            if 
            [ $cantUsu -ne 1 ]; then 
                clear
                echo " "
                echo "Usuario y/o contrasenia incorrecta"
                opc=n
                read -p "Deseas volver a intentarlo? [s/n]" opc
                case $opc in
                    "s") opc=n;;
                    "n") opc=s;;
                    *) echo "Opcion invalida, redirigiendo para volver a intentar"
                    echo " ";;
                esac
            else
                opc=s
                ingreso=s
            fi
        done
        ;;
        "2") ./scripts/crearUsu.sh;;
        *) echo "Ingrese una opcion valida"
        echo " ";;
    esac
done

op=0
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
        "4") ./scripts/filtroProd.sh;;
        "5") ./scripts/crearReporte.sh;;
        "6") break;;
        *) echo "Ingrese una opcion valida"
        echo " "
    esac
done