FROM nginx:latest

# Custom nginx conf
COPY default.conf /tmp/default_temp.conf

# Copy the entrypoint script to the container
COPY entrypoint.sh /docker-entrypoint.d/

RUN chmod +x /docker-entrypoint.d/entrypoint.sh
