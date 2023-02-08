[
  {
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "name": "${name}",
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "${name}"
      }
    },
    "environment": ${environment},
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${container_port}
      }
    ]
  }
]
