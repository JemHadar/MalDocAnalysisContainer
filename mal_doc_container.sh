#!/bin/bash

# Check file argument
if [ $# -eq 0 ]
then
  echo "Please provide a file for analysis."
  exit 1
fi

# Name the image and container
image_name="malicious-files"
container_name="${image_name}_$(date +%s)"

# Build docker image if it doesn't exist
if [[ "$(docker images -q $image_name 2> /dev/null)" == "" ]]; then
  docker build -t $image_name .
fi

# Create a temporary tar file and add maldoc specified in the argument of the script via @
tar_file="$(mktemp)"
tar -cf "$tar_file" "$@"

# Run container with below options and keep it running
docker run -d --hostname maldoc --name $container_name $image_name tail -f /dev/null

# Copy the tar file to the Docker container
docker cp "$tar_file" "$container_name:/home/maldoc/files.tar"
docker exec "$container_name" tar -xf "/home/maldoc/files.tar" -C "/home/maldoc"
docker exec "$container_name" rm "/home/maldoc/files.tar"

# Running the container to an interactive shell
docker exec -it $container_name /bin/bash

# When exiting the container, the script will kill and remove it
docker kill $container_name
docker rm $container_name
echo "The container was shutdown and removed"

# Remove created tar temp file
rm "$tar_file"

