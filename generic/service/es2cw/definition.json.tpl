[
  {
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "name": "${name}",
    "networkMode": "awsvpc",
    "environment": ${environment},
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${container_port}
      }
    ]
  }
]
