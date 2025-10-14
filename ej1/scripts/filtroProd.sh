clear
echo " "
read -p "Ingrese que tipo de productos quiere filtrar, si desea listar todos los productos digite 0 " filtro
filtro = "$filtro"
if [ $filtro -eq "0" ];then 
    echo ""
    echo "Listando todos los productos..."
    cat ../docs/productos.txt
else
    echo ""
    echo "Listando los productos filtrados por $filtro..."
    cat ../docs/productos.txt
    grep -i "$filtro" ../docs/productos.txt
fi;