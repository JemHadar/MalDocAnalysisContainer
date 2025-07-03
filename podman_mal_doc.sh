#!/bin/bash

# Define the container engine command and image name
CONTAINER_CMD="podman"
IMAGE_NAME="maldoc-tools"
CONTAINER_WORKDIR="/home/maldoc" # Where the input files will be extracted inside the container
CONTAINER_TAR_PATH="$CONTAINER_WORKDIR/input_files.tar" # Path for the tarball inside the container

# --- Pre-Checks ---
# Ensure at least one file argument is provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <file1> [<file2> ...]"
    echo "       Launches a container and copies specified files for manual analysis."
    exit 1
fi

# Ensure all provided arguments are existing files
for file_arg in "$@"; do
    if [ ! -f "$file_arg" ]; then
        echo "Error: File not found: '$file_arg'"
        exit 1
    fi
done

# --- Build the image (only if it doesn't exist or if forced rebuild) ---
echo "Building $IMAGE_NAME Podman image..."
# Adding --pull to ensure latest base image, --no-cache if you want a fresh build every time
$CONTAINER_CMD build -t "$IMAGE_NAME" .

if [ $? -ne 0 ]; then
    echo "Error: Image build failed. Exiting."
    exit 1
fi

# --- Create a temporary tar file on the host for the specified input files ---
TEMP_HOST_TAR_FILE=$(mktemp -t maldoc_input_XXXXXX.tar)
echo "Creating temporary tarball on host: $TEMP_HOST_TAR_TAR_FILE"

# The '-C .' ensures files are added to the archive with paths relative to the current directory
tar -cf "$TEMP_HOST_TAR_FILE" -C . "$@"

if [ $? -ne 0 ]; then
    echo "Error: Failed to create tar file. Exiting."
    rm -f "$TEMP_HOST_TAR_FILE"
    exit 1
fi

# --- Run the container in detached mode ---
# We give it a specific name for easier targeting with 'podman cp' and 'podman exec'.
# It will run 'sleep infinity' to keep it alive in the background.
CONTAINER_NAME="maldoc-analysis-$(date +%s)" # Unique name for the container
echo "Starting container: $CONTAINER_NAME"

CONTAINER_ID=$($CONTAINER_CMD run --detach --name "$CONTAINER_NAME" "$IMAGE_NAME" /bin/bash -c "sleep infinity")

if [ $? -ne 0 ]; then
    echo "Error: Failed to start container. Exiting."
    rm -f "$TEMP_HOST_TAR_FILE"
    exit 1
fi

echo "Container $CONTAINER_NAME (ID: $CONTAINER_ID) started in background."

# --- Copy the tar file into the container ---
echo "Copying input files tarball to container..."
$CONTAINER_CMD cp "$TEMP_HOST_TAR_FILE" "$CONTAINER_NAME:$CONTAINER_TAR_PATH"

if [ $? -ne 0 ]; then
    echo "Error: Failed to copy tarball to container. Stopping and cleaning up container."
    $CONTAINER_CMD stop "$CONTAINER_NAME" >/dev/null 2>&1
    rm -f "$TEMP_HOST_TAR_FILE"
    exit 1
fi

# --- Extract files inside the container ---
echo "Extracting files inside container at $CONTAINER_WORKDIR..."
$CONTAINER_CMD exec "$CONTAINER_NAME" /bin/bash -c " \
    mkdir -p $CONTAINER_WORKDIR && \
    tar -xf $CONTAINER_TAR_PATH -C $CONTAINER_WORKDIR && \
    rm $CONTAINER_TAR_PATH && \
    echo '--- Files successfully copied and extracted ---' && \
    ls -l $CONTAINER_WORKDIR && \
    echo '---------------------------------------------'"

if [ $? -ne 0 ]; then
    echo "Error: Failed to extract files in container. Stopping and cleaning up container."
    $CONTAINER_CMD stop "$CONTAINER_NAME" >/dev/null 2>&1
    rm -f "$TEMP_HOST_TAR_FILE"
    exit 1
fi

# --- Attach to an interactive shell inside the container ---
echo ""
echo "Entering interactive shell in container $CONTAINER_NAME."
echo "Your files are in: $CONTAINER_WORKDIR"
echo "You can now manually invoke tools like (assuming softlinks are in Dockerfile):"
echo "  pdf-parser <switches>  my_file.pdf"
echo "  pdfid -n another_file.doc"
echo "  oledump some_file.ole"
echo "  rtfobj some_file.rtf"
echo "Type 'exit' to leave the container and trigger cleanup."
echo ""

# The change: Instead of 'podman attach', we use 'podman exec -it /bin/bash'
# This explicitly creates a new interactive shell session.
$CONTAINER_CMD exec -it "$CONTAINER_NAME" /bin/bash

# --- Cleanup after exiting the interactive shell ---
# This block runs AFTER you exit the interactive shell within the container.
echo ""
echo "Exited container $CONTAINER_NAME."
echo "Stopping and removing container..."
$CONTAINER_CMD stop "$CONTAINER_NAME" >/dev/null 2>&1
$CONTAINER_CMD rm "$CONTAINER_NAME" >/dev/null 2>&1 # Explicit rm for clarity/redundancy

echo "Container $CONTAINER_NAME was shut down and removed."

# --- Remove created temporary tar file ---
echo "Removing temporary host tar file: $TEMP_HOST_TAR_FILE"
rm -f "$TEMP_HOST_TAR_FILE"

echo "Script finished."
