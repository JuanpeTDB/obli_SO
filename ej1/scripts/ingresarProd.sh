#!/bin/bash
clear
echo " "
echo "Vamos a ingresar un nuevo producto, por favor ingrse los siguientes datos:"
read -p "Ingrese el codigo del producto: " cod
read -p "Ingrese el tipo del producto: " tipo
read -p "Ingrese el modelo del producto: " modelo
read -p "Ingrese la descripcion del producto: " desc
read -p "Ingrese la cantidad del producto: " cant
read -p "Ingrese el precio del producto: " precio
echo " "
producto="$cod - $tipo - $modelo - $desc - $cant - $ $precio"
echo "Producto ingresado con exito"
echo "$producto"
echo "$producto" >> docs/productos.txt