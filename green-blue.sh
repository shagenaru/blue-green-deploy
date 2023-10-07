  GNU nano 4.8                                                                                         docker.sh                                                                                                   
#!/bin/bash

running_containers() {
  if [[ $(docker ps --format "{{.Names}}") == *'blue'* && $(docker ps --format "{{.Names}}") == *'green'* ]]; then
    echo 'both'
  elif [[ $(docker ps --format "{{.Names}}") == *'green'* ]]; then
    echo 'green'
  else
    echo 'blue'
  fi
}

run_green() {
docker-compose up -d --force-recreate green_backend
docker_name=$(docker inspect -f '{{.Name}}' $(docker-compose ps -q green_backend) | cut -c2-)
sleep 10
if [[ $(docker inspect -f "{{.State.Health.Status}}" $docker_name) == 'starting' ]]; then
  docker-compose stop blue_backend
else
  docker-compose stop green_backend
fi
}

run_blue() {
docker-compose up -d --force-recreate blue_backend
docker_name=$(docker inspect -f '{{.Name}}' $(docker-compose ps -q blue_backend) | cut -c2-)
sleep 10
if [[ $(docker inspect -f "{{.State.Health.Status}}" $docker_name) == 'starting' ]]; then
  docker-compose stop green_backend
else
  docker-compose stop blue_backend
fi
}

run_container() {

  if [ $(running_containers) == 'blue' ] || [ $(running_containers) == 'both' ]; then
    run_green
  else [ $(running_containers) == 'green' ]
    run_blue
  fi
}

run_container
