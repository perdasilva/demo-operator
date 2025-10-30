FROM scratch

# Copy FBC root into image at /configs and pre-populate serve cache
ADD catalog/.indexignore /configs/.indexignore
ADD catalog/catalog.json /configs/catalog.json

# Set FBC-specific label for the location of the FBC root directory
# in the image
LABEL operators.operatorframework.io.index.configs.v1=/configs
