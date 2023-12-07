# MySQL + Flask Boilerplate Capital Quest Project
## Set up:
**Important** - you need Docker Desktop installed

1. Clone this repository.  
1. Create a file named `db_root_password.txt` in the `secrets/` folder and put inside of it the root password for MySQL. 
1. Create a file named `db_password.txt` in the `secrets/` folder and put inside of it the password you want to use for the a non-root user named webapp. 
1. In a terminal or command prompt, navigate to the folder with the `docker-compose.yml` file.
1. Uncomment Appsmith section in `docker-compose.yml`
1. Build the images with `docker compose build`
1. Start the containers with `docker compose up`.  To run in detached mode, run `docker compose up -d`. 
1. Make sure to check connection to database with Datagrip.
1. Access appsmith UI with localhost:8080
1. (you can test json with localhost:8001 and use the routing, as seen on src/routes folder and `__init__.py`

## Link to video: https://youtu.be/tZFMb9LrWw8




