#!/bin/bash
echo " "
opc=n
while [ $opc != "s" ]; do
    read -p "Ingrese un nombre de usuario: " usu
    cantUsu=`cat docs/usuarios.txt | cut -d';' -f1 | grep "$usu" | wc -l`
    if [ $cantUsu -eq "1" ];then 
        echo " "
        echo "Usuario $usu ya existente"
        read -p "Desea volver a intentarlo? [s/n]" opc
        case $opc in
            "s") opc=m;;
            "n") opc=s 
            break;;
            *) echo "Ingrese una opcion valida"
            echo " ";;
        esac
        echo " "
    else 
        read -p "Ingrese una contrasenia: " pass
        usupass="$usu;$pass"
        echo "$usupass" >> docs/usuarios.txt
        opc=s
    fi
done