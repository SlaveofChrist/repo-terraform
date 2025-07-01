terraform{
   required_providers {
      docker = {
         source = "kreuzwerker/docker"
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
   keep_locally = true

}

resource "docker_image" "node" {
   name = "nodejs"
   keep_locally = true
}

resource "docker_image" "mysql"{
   name = "mysql:9.2"
}

resource "docker_container" "mysql" {
   name = "mysql"
   image = "$(docker_image.mysql.image_id)"
   networks_advanced {
      name = docker_network.internal_network.name
   }
   env = ["MYSQL_ROOT_PASSWORD=pwd"]
   
}

resource "docker_container" "mongo" {
   name  = "mongo"
   image = docker_image.mongo.image_id
   networks_advanced {
      name = docker_network.internal_network.name
   }
   env = [
   "MONGO_INITDB_DATABASE: mydatabase"
   ]
   ports {
      external = 27017
      internal = 27017
   }
}

resource "docker_container" "node" {
   name  = "node"
   image = docker_image.node.image_id
   env = [
      "MONGODB_URL=mongodb://mongo_db:27017/mydatabase",
      "PORT=8000"
   ]
   ports {
      external = 8001
      internal = 8000
   }
   restart = "always"
   depends_on = [docker_container.mongo]
}

