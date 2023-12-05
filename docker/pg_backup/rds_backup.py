import os 
from subprocess import Popen, PIPE
import boto3 
import psycopg2
from dotenv import load_dotenv

# Legacy name filename
legacy_file_name = 'legacy_schema'

# Upload file to S3
def upload_to_s3(file_path, bucket_name, file_name, client):
	# Upload the file
    try:
        client.upload_file(file_path, bucket_name, file_name)
        print("Upload Successful!")
        return True
    except FileNotFoundError:
        print("The file was not found")
        return False

# Download S3 file
def download_s3(file_name, bucket_name, s3_file, client):
	# Upload the file
	object = client.get_object(Bucket=bucket_name, Key=s3_file)
	print("Download backup successful!")

	# Check if the response status is 200 (OK) before writing to file
	if object['ResponseMetadata']['HTTPStatusCode'] == 200:
		with open(file_name, 'wb') as f:
			f.write(object['Body'].read())
		print(f"Object downloaded and saved to: {file_name}")
	else:
		print(f"Failed to download object. Response status code: {object['ResponseMetadata']['HTTPStatusCode']}")

# Retrieve schema name from postgres
def schema_name(cursor):
	# Execute a query to fetch schema names
	cursor.execute("SELECT schema_name FROM information_schema.schemata")

	# Fetch all rows from the result set
	schemas = cursor.fetchall()

	# Write the schema names that start with 'Legacy:' to the file
	with open(legacy_file_name, 'w') as file:
		for schema in schemas:
			schema_name = schema[0]
			if schema_name.startswith('t:legacy'):
				file.write(schema_name)

# Get legacy name from the schema file
def schema():
	with open(legacy_file_name, 'r') as file:
		content = file.read()

	return(content)

# Create an aurora DB backup and store it on S3
def pg_backup(db_name, db_user, db_password, backup_name, s3_client, bucket_name):

	url=f'postgresql://{db_user}:{db_password}@localhost/{db_name}'

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
		# Extracting schema name
		schema_name(cursor)

		print("Creating Backup")
		pg_db_create = f"pg_dump -v -Fc -Z 9 '{url}' > {backup_name}"
		process = Popen(pg_db_create, shell=True, stdout=PIPE, stderr=PIPE)
			
		stdout, stderr = process.communicate()

		if process.returncode == 0:
			print("Backup successful!")
			# Upload backup to S3
			upload_to_s3(backup_name, bucket_name, f"{db_name}/{backup_name}", s3_client)
			# Upload schema name to S3
			upload_to_s3(legacy_file_name, bucket_name, f"{db_name}/{legacy_file_name}", s3_client)
		else:
			error_message = f"Backup failed. Error: {stderr.decode('utf-8')}"
			print(error_message)
	
	except Exception as e:
		print(f"Error: {e}")

	finally:
		# Close the database connection
		if connection:
			connection.close()

# Restore DB from a backup stored in S3
def pg_restore(db_host, db_port, db_name, db_user, db_password, backup_name, s3_client, bucket_name):

	url=f'postgresql://{db_user}:{db_password}@localhost/{db_name}'

	# Download backup
	download_s3(backup_name, bucket_name, f"{db_name}/{backup_name}", s3_client)
	# Download legacy_file_name
	download_s3(legacy_file_name, bucket_name, f"{db_name}/{legacy_file_name}", s3_client)
	legacy_schema_name = schema()

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

		pg_db_create = f"pg_dump -v -Fc -Z 9 '{url}' > {backup_name}"

		# Schemas restore
		pg_db_restore_schema = f"pg_restore -v -s -h {db_host} -p 5432 -d {db_name} -U {db_user} {backup_name}"
		process_schema = Popen(pg_db_restore_schema, shell=True, stdout=PIPE, stderr=PIPE)
		stdout_schema, stderr_schema = process_schema.communicate()

		if process_schema.returncode == 0:
			print("Schemas restore successful!")
		else:
			print(f"Schemas restore failed. Error: {stderr_schema.decode('utf-8')}")

		# Data restore
		pg_db_restore_data = f"pg_restore -v -a -h {db_host} -p 5432 -d {db_name} -U {db_user} {backup_name}"
		process_data = Popen(pg_db_restore_data, shell=True, stdout=PIPE, stderr=PIPE)
		stdout_data, stderr_data = process_data.communicate()

		if process_data.returncode == 0:
			print("Data restore successful!")
		else:
			print(f"Data restore failed. Error: {stderr_data.decode('utf-8')}")

	except Exception as e:
		print(f"Error: {e}")

	finally:
		# Close the database connection
		if connection:
			connection.close()


if __name__ == "__main__":
	load_dotenv()
	# Retrieve environental variables
	db_host=os.environ["DB_HOST"]
	db_port=os.environ["DB_PORT"]
	db_name=os.environ["DB_NAME"]
	db_user=os.environ["DB_USER"]
	db_password=os.environ["PGPASSWORD"]
	strategy=os.environ["STRATEGY"]
	bucket_name=os.environ["S3_BUCKET"]

	# Creating an S3 client
	s3 = boto3.client('s3')

	backup_name = "backup.dump"
	
	if(strategy == 'backup'):
		pg_backup(db_name, db_user, db_password, backup_name, s3, bucket_name)
	elif(strategy == 'restore'):
		pg_restore(db_host, db_port, db_name, db_user, db_password, backup_name, s3, bucket_name)
	else: 
		print("Error")
	
