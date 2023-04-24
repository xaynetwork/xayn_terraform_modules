[
  {
    "image": "${es_exporter_image}",
    "name": "${es_exporter_name}",
    "networkMode": "awsvpc",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${es_exporter_log_group}",
        "awslogs-region": "${log_aws_region}",
        "awslogs-stream-prefix": "${es_exporter_name}"
      }
    },
    "environment": ${es_exporter_environment},
    "secrets": ${es_exporter_secrets},
    "command": ${es_exporter_args},
    "portMappings": [
      {
        "containerPort": ${es_exporter_container_port},
        "hostPort": ${es_exporter_container_port}
      }
    ]
  },
  {
    "image": "${pc_exporter_image}",
    "name": "${pc_exporter_name}",
    "networkMode": "awsvpc",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${pc_exporter_log_group}",
        "awslogs-region": "${log_aws_region}",
        "awslogs-stream-prefix": "${pc_exporter_name}"
      }
    },
    "environment": ${pc_exporter_environment},
    "dependsOn": [
      {
        "containerName": "${es_exporter_name}",
        "condition": "START"
      }
    ]
  }
]
