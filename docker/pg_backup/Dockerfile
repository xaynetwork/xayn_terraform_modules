FROM python:3.12

# Set destination for COPY
WORKDIR /app

# Create the /temp directory for creating backups
RUN mkdir /temp

# Download Python file 
ADD ./rds_backup.py requirements.txt /app/

# Install pip librarires
RUN pip install -r requirements.txt

# Install PostgreSQL client tools
RUN apt-get update && apt-get install -y postgresql-client

# Run
ENTRYPOINT ["python", "rds_backup.py"]
