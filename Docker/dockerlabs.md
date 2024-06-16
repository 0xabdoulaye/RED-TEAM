```sh
FROM kalilinux/kali-rolling
RUN apt-get update -y && apt-get install megatools -y && apt -y install kali-linux-headless

WORKDIR /root
RUN megadl Link
```


- http://www.freevpn.us/openvpn/us/

```sh
#!/bin/bash

detener_y_eliminar_contenedor() {
    IMAGE_NAME="${TAR_FILE%.tar}"
    CONTAINER_NAME="${IMAGE_NAME}_container"

    if [ "$(docker ps -a -q -f name=$CONTAINER_NAME -f status=exited)" ]; then
        
        docker rm $CONTAINER_NAME > /dev/null
    fi

    
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        
        docker stop $CONTAINER_NAME > /dev/null

        docker rm $CONTAINER_NAME > /dev/null
    fi

    if [ "$(docker images -q $IMAGE_NAME)" ]; then
        docker rmi $IMAGE_NAME > /dev/null
    fi
}

trap ctrl_c INT

function ctrl_c() {
    echo -e "\e[1mEliminando el laboratorio, espere un momento...\e[0m"
    detener_y_eliminar_contenedor
    echo -e "\nEl laboratorio ha sido eliminado por completo del sistema."
    exit 0
}

if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_tar>"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "\033[1;36m\nDocker no está instalado. Instalando Docker...\033[0m"
    sudo apt update
    sudo apt install docker.io -y
    echo -e "\033[1;36m\nEstamos habilitando el servicio de docker. Espere un momento...\033[0m"
    sleep 10
    systemctl restart docker && systemctl enable docker
    if [ $? -eq 0 ]; then
        echo "Docker ha sido instalado correctamente."
    else
        echo "Error al instalar Docker. Por favor, verifique y vuelva a intentarlo."
        exit 1
    fi
fi

TAR_FILE="$1"

echo -e "\e[1;93m\nEstamos desplegando la máquina vulnerable, espere un momento.\e[0m"
detener_y_eliminar_contenedor
docker load -i "$TAR_FILE" > /dev/null


if [ $? -eq 0 ]; then

    IMAGE_NAME=$(basename "$TAR_FILE" .tar) # Obtiene el nombre del archivo sin la extensión .tar
    CONTAINER_NAME="${IMAGE_NAME}_container"

    docker run -d --name $CONTAINER_NAME $IMAGE_NAME > /dev/null
    
    IP_ADDRESS=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
    
    echo -e "\e[1;96m\nMáquina desplegada, su dirección IP es --> \e[0m\e[1;97m$IP_ADDRESS\e[0m"

    echo -e "\e[1;91m\nPresiona Ctrl+C cuando termines con la máquina para eliminarla\e[0m"


    # Configure tun0 interface
    sudo ip tuntap add mode tun tun0
    sudo ip link set tun0 up
    sudo ip addr add 10.10.0.22/32 dev tun0
    sudo ip route add 10.10.0.21 dev tun0


else
    echo -e "\e[91m\nHa ocurrido un error al cargar el laboratorio en Docker.\e[0m"
    exit 1
fi

# Espera indefinida para que el script no termine.
while true; do
    sleep 1
done




```