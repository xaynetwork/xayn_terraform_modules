import os 
import sys
from subprocess import Popen, PIPE
import boto3 
import psycopg2
from dotenv import load_dotenv
import tarfile

legacy_file_location = '/temp/legacy_schema'
db_port = 5432
backup_name = "backup"
backup_location = "/temp"
backup = f"{backup_location}/{backup_name}"

# Upload file to S3
def upload_to_s3(local_file_path, bucket_name, file_name_s3, client):
    try:
        client.upload_file(local_file_path, bucket_name, file_name_s3)
        print("Upload Successful!")
    except FileNotFoundError:
        print("The file was not found")

# Download S3 file
def download_s3(local_file_name, bucket_name, file_name_s3, client):
	object = client.get_object(Bucket=bucket_name, Key=file_name_s3)
	print("Download backup successful!")

	# Check if the response status is 200 (OK) before writing to file
	if object['ResponseMetadata']['HTTPStatusCode'] == 200:
		with open(local_file_name, 'wb') as f:
			f.write(object['Body'].read())
		print(f"Object downloaded and saved to: {local_file_name}")
	else:
		print(f"Failed to download object. Response status code: {object['ResponseMetadata']['HTTPStatusCode']}")

# Retrieve schema name from postgres
def write_schema_name_to_disk(cursor):
	# Execute a query to fetch schema names
	cursor.execute("SELECT schema_name FROM information_schema.schemata")
	schemas = cursor.fetchall()

	# Write the schema names that start with 'Legacy:' to the file
	with open(legacy_file_location, 'w') as file:
		for schema in schemas:
			schema_name = schema[0]
			if schema_name.startswith('t:legacy'):
				file.write(schema_name)

# Get legacy name from the schema file
def get_legacy_schema_name():
	with open(legacy_file_location, 'r') as file:
		content = file.read()

	return(content)

# Get the hostname from the Aurora cluster
def get_host_name(url):
	splitted_url = url.split('@')
	
	return splitted_url[1]

# Compress file
def compress_files(name, directory):
	print("Compressing File")
	# Check if the file exists
	if not os.path.exists(directory):
		raise FileNotFoundError(f"The directory '{directory}' does not exist.")
	
	with tarfile.open(f'{name}.tar.gz', "w:gz") as tar:
		tar.add(directory, recursive=True)

# Extract file
def extract_files(file):
	try:
		print("Extracting File")
		with tarfile.open(file, "r:gz") as tar:
			tar.extractall(path="/")
	except Exception as e:
		print(f"Error extracting file '{file}': {e}")

# Create an aurora DB backup and store it on S3
def pg_backup(db_name, db_user, db_password, db_url, s3_client, bucket_name):
	# Retrieve host name and parse the url
	url = db_url
	db_host = get_host_name(url)
	parsed_url = url.replace("user",db_user).replace("password",db_password)

	# Connect to the database
	try:
		connection = psycopg2.connect(
			host=db_host,
			port=db_port,
			database=db_name,
			user=db_user,
			password=db_password
		)
		print("Connection established to Aurora")
		 # Extracting schema name
		cursor = connection.cursor()
		write_schema_name_to_disk(cursor)

		print("Creating Backup")
		pg_db_create = f"pg_dump -v -Fc -Z 9 '{parsed_url}/{db_name}' > {backup}"
		process = Popen(pg_db_create, shell=True, stdout=PIPE, stderr=PIPE)
			
		stdout, stderr = process.communicate()

		if process.returncode == 0:
			# Compress and upload files
			try:
				compress_files(backup_name, backup_location)
				upload_to_s3(f"{backup_name}.tar.gz", bucket_name, f"{db_name}/{backup_name}.tar.gz", s3_client)
			except (FileNotFoundError, Exception) as e:
				print(f"Error: {e}")
				sys.exit(1)
		else:
			error_message = f"Backup failed. Error: {stderr.decode('utf-8')}"
			print(error_message)
			sys.exit(1)
	
	except Exception as e:
		print(f"Error: {e}")

	finally:
		# Close the database connection
		if connection:
			connection.close()

# Restore DB from a backup stored in S3
def pg_restore(db_name, db_user, db_password, db_url, s3_client, bucket_name):
	# Retrieve host name
	db_host = get_host_name(db_url)

	# Download files from S3
	try:
		download_s3(f"{backup}.tar.gz", bucket_name, f"{db_name}/{backup_name}.tar.gz", s3_client)
		extract_files(f"{backup}.tar.gz")
		legacy_schema_name = get_legacy_schema_name()
	except Exception as e:
				sys.exit(1)

	# Connect to the database
	try:
		connection = psycopg2.connect(
			host=db_host,
			port=db_port,
			database=db_name,
			user=db_user,
			password=db_password
		)
		cursor = connection.cursor()
		print("Connection established to Aurora")

		# Create ROLE
		role_creation_query = f'CREATE ROLE "{legacy_schema_name}" NOINHERIT;'
		cursor.execute(role_creation_query)

		# Alter ROLE and Set search_path
		alter_role_query = f'ALTER ROLE "{legacy_schema_name}" SET search_path TO "$user";'
		cursor.execute(alter_role_query)

		# Grant permissions to the ROLE
		grant_query = f'GRANT "{legacy_schema_name}" TO "web-api-mt";'
		cursor.execute(grant_query)
		print("DB Configuration Done")
		print("Restoring Data")

		# Schemas restore
		pg_db_restore_schema = f"pg_restore -v -s -h {db_host} -p 5432 -d {db_name} -U {db_user} {backup_location}"
		process_schema = Popen(pg_db_restore_schema, shell=True, stdout=PIPE, stderr=PIPE)
		stdout_schema, stderr_schema = process_schema.communicate()

		if process_schema.returncode == 0:
			print("Schemas restore successful!")
		else:
			print(f"Schemas restore failed. Error: {stderr_schema.decode('utf-8')}")
			sys.exit(1)

		# Data restore
		pg_db_restore_data = f"pg_restore -v -a -h {db_host} -p 5432 -d {db_name} -U {db_user} {backup_location}"
		process_data = Popen(pg_db_restore_data, shell=True, stdout=PIPE, stderr=PIPE)
		stdout_data, stderr_data = process_data.communicate()

		if process_data.returncode == 0:
			print("Data restore successful!")
		else:
			print(f"Data restore failed. Error: {stderr_data.decode('utf-8')}")
			sys.exit(1)

	except Exception as e:
		print(f"Error: {e}")

	finally:
		# Close the database connection
		if connection:
			connection.close()


if __name__ == "__main__":
	load_dotenv()
	# Retrieve environental variables
	db_name=os.environ["DB_NAME"]
	db_user=os.environ["DB_USER"]
	db_password=os.environ["PGPASSWORD"]
	db_url=os.environ["DB_URL"]
	task=os.environ["TASK"]
	bucket_name=os.environ["S3_BUCKET"]

	# Creating an S3 client
	s3 = boto3.client('s3')

	try: 
		if(task.upper() == 'BACKUP'):
			pg_backup(db_name, db_user, db_password, db_url, s3, bucket_name)
		elif(task.upper() == 'RESTORE'):
			pg_restore(db_name, db_user, db_password, db_url, s3, bucket_name)
		else:
			print("Error: Invalid task specified")
			sys.exit(1)  # Exit with a non-zero status code for error
		
		print("Task completed successfully")
		sys.exit(0)  # Exit with a status code of 0 for success
		
	except Exception as e:
		print(f"Error: {e}")
		sys.exit(1)  # Exit with a non-zero status code for error
