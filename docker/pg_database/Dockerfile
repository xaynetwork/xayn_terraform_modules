FROM alpine:3.20

RUN apk --no-cache add postgresql14-client bash

# Copy the script into the container
COPY create_db.sh /tmp/create_db.sh

# Make the script executable
RUN chmod +x /tmp/create_db.sh

# Set the entrypoint to the shell script
ENTRYPOINT ["/bin/bash", "/tmp/create_db.sh"]

