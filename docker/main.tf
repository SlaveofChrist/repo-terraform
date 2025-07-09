terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {}

resource "docker_network" "internal_network" {
  name = "internal-app-network"
}

resource "docker_image" "mongo" {
  name = "mongo:latest"
}

resource "docker_image" "mongo-seed" {
  name = "elielwotobe/mongo-seed-image"
}

resource "docker_image" "node" {
  name = "elielwotobe/node-server-image"
}

resource "docker_container" "mongo_db" {
  name  = "mongo-container"
  image = docker_image.mongo.image_id
  networks_advanced {
    name = docker_network.internal_network.name
  }
  env = [
    "MONGO_INITDB_DATABASE=mydatabase"
  ]
  ports {
    external = 27017
    internal = 27017
  }
}

# resource "docker_container" "mongo-seed" {
#   name  = "mongo-seed-container"
#   image = docker_image.mongo-seed.image_id
#   networks_advanced {
#     name = docker_network.internal_network.name
#   }
#   env = [
#     "MONGO_DB_HOST=${docker_container.mongo_db.network_data.0.ip_address}"
#   ]
#   depends_on = [docker_container.mongo_db]
# }

resource "docker_container" "node" {
  name  = "node-container"
  image = docker_image.node.image_id
  networks_advanced {
    name = docker_network.internal_network.name
  }
  env = [
    "MONGODB_URL=mongodb://${docker_container.mongo_db.network_data.0.ip_address}:27017/mydatabase",
    "PORT=8000"
  ]
  ports {
    external = 8000
    internal = 8000
  }
  restart    = "always"
  depends_on = [docker_container.mongo_db]
}

