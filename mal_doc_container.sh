#!/bin/bash

# Check file argument
if [ $# -eq 0 ]
then
  echo "Please provide a file for analysis."
  exit 1
fi

image_name="malicious-documents"
container_name="${image_name}_$(date +%s)"

# Build docker image if it doesn't exist
if [[ "$(docker images -q $image_name 2> /dev/null)" == "" ]]; then
  docker build -t $image_name .
fi

# Create a temporary tar file and add maldoc specified in the argument of the script
tar_file="$(mktemp)"
tar -cf "$tar_file" "$@"

# Run container with below options and keep it running
docker run -d --hostname maldoc --name $container_name $image_name tail -f /dev/null

# Copy the tar file to the Docker container
docker cp "$tar_file" "$container_name:/home/maldoc/files.tar"
docker exec "$container_name" tar -xf "/home/maldoc/files.tar" -C "/home/maldoc"
docker exec "$container_name" rm "/home/maldoc/files.tar"

docker exec -it $container_name /bin/bash

# After the Docker container has finished running, kill and remove it
docker kill $container_name
docker rm $container_name

# Remove the temporary tar file
rm "$tar_file"
