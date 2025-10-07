#!/bin/bash
echo " "
read -p "Ingrese nombre de usuario: " usu
read -p "Ingrese su contrasenia: " pass
usupass="$usu;$pass"
cantUsu=`cat docs/usuarios.txt | grep "$usupass" | wc -l`
if [ $cantUsu -eq "1" ];then 
    echo " "
    echo "Iniciando sesion..."
    echo " "
    echo "Bienvenido $usu"
    echo " "
else 
    echo "Usuario y/o contrasenia incorrecta"
    opc=n
    while [ $opc != "s" ]; do
        read -p "Desea volver para atras? [s/n]" opc
        case $opc in
            "s") break;;
            "n") ./scripts/ingresar.sh
            break;;
            *) echo "Ingrese una opcion valida"
            break;;
        esac
    done
fi