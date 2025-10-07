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
        read -p "Deseas volver a intentarlo? [s/n]" opc
        case $opc in
            "s") ./scripts/ingresar.sh
            break;;
            "n") ./login.sh
            break;;
            *) echo "Ingrese una opcion valida"
            echo " ";;
        esac
    done
fi