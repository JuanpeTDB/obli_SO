#!/bin/bash
clear
echo " "
read -p "Ingrese nombre de usuario: " usu
read -p "Ingrese su contrasenia: " pass
usupass="$usu;$pass"
cantUsu=`cat docs/usuarios.txt | grep "$usupass" | wc -l`
if [ $cantUsu -eq "1" ];then 
    echo "Credenciales correctas"
    sed -i '' '/'$usupass'/d' docs/usuarios.txt                         #Elimina la linea que conttiene usupass
    read -p "Ingrese la nueva contrasenia para $usu: " passNueva
    usupass="$usu;$passNueva"
    echo " " >> docs/usuarios.txt
    echo "$usupass" >> docs/usuarios.txt
else 
    echo "Usuario y/o contrasenia incorrecta"
    opc=n
    while [ $opc != "s" ]; do
        read -p "Deseas volver a intentarlo? [s/n]" opc
        case $opc in
            "s") ./scripts/cambiarPass.sh
            break;;
            "n") break;;
            *) echo "Ingrese una opcion valida"
            echo " ";;
        esac
    done
fi