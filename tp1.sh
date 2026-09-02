#!/bin/bash

carpeta_base="$(dirname "$(realpath "$0")")" 

carpeta_origen="$carpeta_base/EPNro1/entrada"
carpeta_destino="$carpeta_base/EPNro1/salida/FILENAME.txt"
carpeta_intermedia="$carpeta_base/EPNro1/procesado"
archivo_script="$carpeta_base/tp1.sh"
archivo_consolidar="$carpeta_base/EPNro1/consolidar.sh"
archivo_log="$carpeta_base/EPNro1/procesado.log"


# Parametro optativo -d (limpieza)

if [ "$1" = "-d" ]; then
        if pgrep -f "$archivo_consolidar" > /dev/null #pgrep busca el proceso en ejecución, -f busca por el nombre del archivo.
        then
                pkill -f "$archivo_consolidar" #mata el proceso en ejecución
                echo -e "\nProceso se ha detenido\n"
        else
                echo -e "\nProceso no esta activo\n"
        fi

        rm -rf "$carpeta_base/EPNro1"
        echo "Entorno borrado con exito."
    exit 0 
fi 

#dirname obtiene la ruta del directorio donde se encuentra el script, realpath obtiene la ruta absoluta del script.

printf "\n"
echo "1- Crear el entorno"
echo "2- Correr el proceso background"
echo "3- mostrar listado de alumnos ordenados por número de padrón."
echo "4- Mostrar los 10 alumnos con nota mas alta"
echo "5- Buscar el numero de padron"
echo "6- Visualizar el log"
echo "7- Salir"
printf "\n"
read -p "Opcion: " opcion

case $opcion in 
        1) mkdir -p "$carpeta_base/EPNro1" #-p crea el directorio y si no existe lo crea, si existe no hace nada
        cd "$carpeta_base/EPNro1"  #estoy en EPNro1
        mkdir -p entrada salida procesado
        cd salida #salida
        touch FILENAME.txt
        cd .. #vuelvo a EPNro1
        if [ -f "$archivo_consolidar" ]; then
            echo -e "\nEl archivo consolidar.sh ya existe\n"
        else
        cat > "$archivo_consolidar" << EOF
        
#!/bin/bash

carpeta_base="\$(dirname "\$(realpath "\$0")")" 

carpeta_origen="\$carpeta_base/EPNro1/entrada"
carpeta_destino="\$carpeta_base/EPNro1/salida/FILENAME.txt"
carpeta_intermedia="\$carpeta_base/EPNro1/procesado"
archivo_log="\$carpeta_base/EPNro1/procesado.log"

while :
do
        if [ -f "\$carpeta_destino" ] # -f comprueba si el archivo existe
        then
                for archivo in "\$carpeta_origen"/*.txt 
                do
                        [ -e "\$archivo" ] #-e comprueba si el archivo existe, si no existe continua con el siguiente archivo
                        nom=\$(basename "\$archivo")
                        fecha_hora=\$(date +'%d/%m/%Y %H:%M:%S')
                        echo "\$fecha_hora - Procesado archivo \$nom" >> "\$archivo_log"

                        cat "\$archivo" >> "\$carpeta_destino"
                        mv "\$archivo" "\$carpeta_intermedia"
                done
        else
                echo -e "\nno existe filename\n"
        fi

        sleep 15
done

EOF
        chmod +x "$archivo_consolidar"
        fi
        echo "Se ha creado el entorno"
        cd .. #vuelvo a Tps

        bash "$archivo_script" 
        ;;

        2)
        if pgrep -f "$archivo_consolidar" > /dev/null #pgrep busca el proceso en ejecución, -f busca por el nombre del archivo.
        then
                echo -e "\nEl proceso ya está activo\n"
        else
                bash "$archivo_consolidar" & #ejecuta el script en segundo plano
                echo -e "\nProceso se ha activado\n"
        fi

        bash "$archivo_script"
        ;;
        3) if [ -f "$carpeta_destino" ]; then #-f comprueba si el archivo existe
                printf "\n"
                if [ -s "$carpeta_destino" ]; then #-s comprueba si el archivo no está vacío
                        sort -t " " -k1n "$carpeta_destino" #-t indica el delimitador, -k1 indica que se ordene por la primera columna
                else
                        echo -e "\nEl archivo FILENAME.txt está vacío\n"
                fi
        else
                echo -e "\nEl archivo FILENAME.txt no existe\n"
        fi
        bash "$archivo_script"
        ;;

        4) if [ -f "$carpeta_destino" ]; then
                printf "\n"
                if [ -s "$carpeta_destino" ]; then #-s comprueba si el archivo no está vacío
                sort -t " " -k5nr "$carpeta_destino" | head -n 10 #-r es para reversa, -n es numerico
                else
                        echo -e "\nEl archivo FILENAME.txt está vacío\n"
                fi
        else 
                echo -e "\nEl archivo FILENAME.txt no existe\n"
        fi
        bash "$archivo_script"
        ;;

        5) if [ -f "$carpeta_destino" ]; then
                if [ -s "$carpeta_destino" ]; then
                        printf "\n"
                        read -p "Ingrese su numero de padron, ingrese "E" para salir: "  buscar
                        
                        resultado=$(awk -v num="$buscar" '$1 == num' "$carpeta_destino") #-v guarda en una variable, awk busca en el archivo la primera columna que sea igual a num y lo guarda en resultado

                        while [ -z "$resultado" ] && [ ! "$buscar" == "E" ]
                        do
                                echo -e "\nNo existe el numero de padron $buscar\n"
                                read -p "Ingrese su numero de padron, ingrese "E" para salir: "  buscar
                                resultado=$(awk -v num="$buscar" '$1 == num' "$carpeta_destino") #awk busca en el archivo la primera columna que sea igual a num y lo guarda en resultado
                        done
                        echo "$resultado"
                else
                        echo -e "\nEl archivo FILENAME.txt está vacío\n"
                fi

        else
                echo -e "\nEl archivo FILENAME.txt no existe\n"
        fi

        bash "$archivo_script"
        ;;

         6) if [ -f "$archivo_log" ]; then #-f comprueba si el archivo existe
               printf "\n"
               if [ -s "$archivo_log" ]; then #-s comprueba si el archivo log no esta vacio 
               cat "$archivo_log" #cat imprime y muestra el archivo en pantalla 
               else
                        echo -e "\nEl archivo procesado.log esta vacio\n"
               fi
        else
               echo -e "\nEl archivo procesado.log no existe\n"
        fi 
        
        bash "$archivo_script"
        ;;

        7)
        echo -e "\nSaliendo del programa\n"
        exit 0
        ;;
        
        *) echo "Opcion no valida"
        bash "$archivo_script"
        ;;

esac


