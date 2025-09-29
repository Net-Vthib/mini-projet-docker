# mini-projet-docker

## Énoncé  
[Énoncé du projet](https://github.com/eazytraining/bootcamp-project-update/tree/main/mini-projet-docker)

---

## Création du Dockerfile
'''
FROM amazoncorretto:17-alpine
LABEL maintainer="netvthib@gmail.com"
WORKDIR /app
COPY target/paymybuddy.jar /app/paymybuddy.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/paymybuddy.jar"]
Construction de l'image
'''
## Création de l'image
docker build -t paymybuddy-backend:v1 .

## Création du docker-compose
services:
  mysql:
    image: mysql:8.0.43
    restart: always
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
      - ./initdb:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -p${MYSQL_ROOT_PASSWORD} || exit 1"]
      interval: 5s
      timeout: 3s
      retries: 30
      start_period: 20s

  backend:
    image: paymybuddy-backend:v1
    restart: always
    depends_on:
      mysql:
        condition: service_healthy
    ports:
      - "8080:8080"
    environment:
      SPRING_APPLICATION_JSON: >
        {
          "server.port": ${SERVER_PORT},
          "spring.datasource.url": "${SPRING_DATASOURCE_URL}",
          "spring.datasource.username": "${SPRING_DATASOURCE_USERNAME}",
          "spring.datasource.password": "${SPRING_DATASOURCE_PASSWORD}",
          "spring.jpa.database-platform": "org.hibernate.dialect.MySQL8Dialect"
        }

volumes:
  db_data:


## Création du fichier .env
MYSQL_DATABASE=db_paymybuddy
MYSQL_ROOT_PASSWORD=password
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/db_paymybuddy?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=password
SERVER_PORT=8080


## Modification create.sql de initdb
Ajout de IF NOT EXISTS :

CREATE DATABASE IF NOT EXISTS db_paymybuddy;
USE db_paymybuddy;

CREATE TABLE IF NOT EXISTS `user` (
    user_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    balance DECIMAL(10, 2) NOT NULL DEFAULT 0.0
);

CREATE TABLE IF NOT EXISTS `bank_account` (
    account_id INT NOT NULL AUTO_INCREMENT,
    fk_user_id INT NOT NULL,
    bank_name VARCHAR(100) DEFAULT NULL,
    iban VARCHAR(34) DEFAULT NULL,
    balance DECIMAL(20,2) NOT NULL DEFAULT 0.0,
    PRIMARY KEY (account_id, fk_user_id),
    FOREIGN KEY (fk_user_id)
        REFERENCES user (user_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `connection` (
    connection_id INT NOT NULL AUTO_INCREMENT,
    fk_initializer_id INT NOT NULL,
    fk_receiver_id INT NOT NULL,
    starting_date DATETIME NOT NULL,
    FOREIGN KEY (fk_initializer_id)
        REFERENCES user (user_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (fk_receiver_id)
        REFERENCES user (user_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    PRIMARY KEY (connection_id, fk_initializer_id, fk_receiver_id)
);

CREATE TABLE IF NOT EXISTS `transaction` (
    transaction_id INT NOT NULL AUTO_INCREMENT,
    fk_issuer_id INT NOT NULL,
    fk_payee_id INT NOT NULL,
    date DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    description VARCHAR(140),
    FOREIGN KEY (fk_issuer_id)
        REFERENCES user (user_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (fk_payee_id)
        REFERENCES user (user_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    PRIMARY KEY (transaction_id, fk_issuer_id, fk_payee_id)
);

INSERT INTO `user` (`email`, `password`, `firstname`, `lastname`, `balance`) VALUES
        ('security@mail.com', '$2a$10$vpDkNfBtWg.ebbkL8VwaG.BrmlIlqRCd0RqoyOIb6hgRZRMfJ51xa', 'Security', 'User', 0.00),
        ('hayley@mymail.com', '$2a$10$1NDocQWD9pl52dv/cY7mmOuCYbIVTzCd6ahb5EUDQxwkDMkg1Q54y', 'Hayley', 'James', 10.00),
        ('clara@mail.com', '$2a$10$41nUyaddehEi9Slu/4kFWeedO3YrLnGCu5nZqYySX3CH7uyHMrclu', 'Clara', 'Tarazi', 133.56),
        ('smith@mail.com', '$2a$10$3TU.lRztZJgEueboxsP2b.AV6TeBsKK.qyyCYGYJXKeozeahFVTuu', 'Smith', 'Sam', 8.00),
        ('lambda@mail.com', '$2a$10$prOZuMO22K.itqO3CKrEGuVf2KUxdWOB9fGQh8DvWHPHWIiiR6iZy', 'Lambda', 'User', 96.91);

INSERT INTO `bank_account` (`fk_user_id`, `bank_name`, `iban`, `balance`) VALUES
    (5, 'Banque de France', 'FR7630001007941234567890185', 1590.00),
    (2, 'BNP Paribas', 'FR7630004000031234567890143', 352.68),
    (3, 'Crédit Agricole', 'FR7630006000011234567890189', 20.00),
    (4, 'Banque Populaire', 'FR7610107001011234567890129', 0.00);

INSERT INTO `connection` (`fk_initializer_id`, `fk_receiver_id`, `starting_date`) VALUES
        (1, 2, '2022-10-24 17:37:33'),
        (1, 3, '2022-10-24 17:37:41'),
        (3, 4, '2022-10-24 17:38:01'),
        (3, 5, '2022-10-24 17:38:08'),
        (5, 2, '2022-10-24 17:38:29'),
        (5, 4, '2022-10-24 17:38:39');

INSERT INTO `transaction` (`fk_issuer_id`, `fk_payee_id`, `date`, `amount`, `description`) VALUES
        (5, 4, '2022-10-24 17:39:55', 8.00, 'Movie tickets'),
        (3, 5, '2022-10-24 17:41:03', 25.00, 'Trip money'),
        (5, 2, '2022-10-24 17:41:40', 10.00, 'Restaurant bill share');



## Création d’un registre privé (Play Docker Eazytraining)
docker network create eazy

docker run -d \
  -p 5000:5000 \
  --net eazy \
  --name registry-eazy \
  registry:2.8.1

docker run -d \
  -p 8090:80 \
  --net eazy \
  -e NGINX_PROXY_PASS_URL=http://registry-eazy:5000 \
  -e DELETE_IMAGES=true \
  -e REGISTRY_TITLE=eazytraining \
  --name frontend-eazy \
  joxit/docker-registry-ui:2


## Tag et push des images vers le registre privé
docker tag paymybuddy-backend:v1 ip10-0-48-4-d3d71hu57ed000eubmk0-5000.direct.docker.labs.eazytraining.fr/paymubbuddy:remote
docker push  ip10-0-48-4-d3d71hu57ed000eubmk0-5000.direct.docker.labs.eazytraining.fr/paymubbuddy:remote

docker tag mysql:8.0.43 ip10-0-48-4-d3d71hu57ed000eubmk0-5000.direct.docker.labs.eazytraining.fr/mysql:remote
docker push ip10-0-48-4-d3d71hu57ed000eubmk0-5000.direct.docker.labs.eazytraining.fr/mysql:remote
yaml






=======

# PayMyBuddy - Financial Transaction Application

This repository contains the *PayMyBuddy* application, which allows users to manage financial transactions. It includes a Spring Boot backend and MySQL database.

**![PayMyBuddy Overview](https://lh7-rt.googleusercontent.com/docsz/AD_4nXf0fGeMjotdY0KzJL13cmGhXad3GM_kn7OSXZJ4CCSQ89zZTlrhBVVi91QjRMgVeszmUMAMAgyavzr4VyQ9YOAUiWmL2sF6aVQYiJPLZfztxv7ERNsIra2O_2SYIX5ZFY5eOARMeI2qnOwrIymuyJnvtuYs?key=mLqAl_ccMoG4hHcRzSYKpw)**

---

## Objectives

This POC demonstrates the deployment of the *PayMyBuddy* app using Docker containers, with a focus on:

- Improving deployment processes
- Versioning infrastructure releases
- Implementing best practices for Docker
- Using Infrastructure as Code

### Key Themes:

- Dockerization of the backend and database
- Orchestration with Docker Compose
- Securing the deployment process
- Deploying and managing Docker images via Docker Registry

---

## Context

*PayMyBuddy* is an application for managing financial transactions between friends. The current infrastructure is tightly coupled and manually deployed, resulting in inefficiencies. We aim to improve scalability and streamline the deployment process using Docker and container orchestration.

---

## Infrastructure

The infrastructure will run on a Docker-enabled server with **Ubuntu 20.04**. This proof-of-concept (POC) includes containerizing the Spring Boot backend and MySQL database and automating deployment using Docker Compose.

### Components:

- **Backend (Spring Boot):** Manages user data and transactions
- **Database (MySQL):** Stores users, transactions, and account details
- **Orchestration:** Uses Docker Compose to manage the entire application stack

---

## Application

*PayMyBuddy* is divided into two main services:

1. **Backend Service (Spring Boot):**
   - Exposes an API to handle transactions and user interactions
   - Connects to a MySQL database for persistent storage

2. **Database Service (MySQL):**
   - Stores user and transaction data
   - Exposed on port 3306 for the backend to connect

### Build and Test (7 Points)

You will build and deploy the backend and MySQL database in Docker containers.

#### Database Initialization
The database schema is initialized using the initdb directory, which contains SQL scripts to set up the required tables and initial data. These scripts are automatically executed when the MySQL container starts.

#### Extra Challenges (Optional)
Secure Sensitive Information: Avoid hardcoding sensitive data such as database credentials directly in your Dockerfile. Instead, use Docker secrets or .env files to manage them securely. These environment variables can be set dynamically at runtime to protect sensitive information:

```bash
# Environment variables for database connection
# Do not hardcode credentials; use secrets or environment files instead.

# ENV SPRING_DATASOURCE_USERNAME  # Database username
# ENV SPRING_DATASOURCE_PASSWORD  # Database password
# ENV SPRING_DATASOURCE_URL       # Database connection URL
```

User Authentication: Add user authentication to the backend to restrict access to the API and transactions.

1. **Backend Dockerfile:**
   - Base image: `amazoncorretto:17-alpine`
   - Copy backend JAR file and expose port 8080
   - CMD: Run the backend service
   
2. **Database Setup:**
   - Use MySQL as a Docker service, mounting the data to a persistent volume
   - Expose port 3306

### Orchestration with Docker Compose (5 Points)

The `docker-compose.yml` will deploy both services:
- **paymybuddy-backend:** Runs the Spring Boot application.
- **paymybuddy-db:** MySQL database to handle user data and transactions.

Key features:
- Services depend on each other for smooth orchestration
- Volumes for persistent storage
- Environment variables for secure configuration

---

## Docker Registry (4 Points)

You need to push your built images to a private Docker registry and deploy the images using Docker Compose.

### Steps:
1. Build the images for both backend and MySQL.
2. Deploy a private Docker registry.
3. Push your images to the registry and use them in `docker-compose.yml`.

---

## Delivery (4 Points)

For your delivery, provide the following in your repository:

- **README** with screenshots and explanations.
- **Dockerfile** and **docker-compose.yml**.
- **Screenshots** showing the application running.
  
Your delivery will be evaluated based on:
- Quality of explanations and screenshots
- Repository structure and clarity

**Good luck!**

**![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXc-CjKFk4NY9yXiR1oheHsFR4YYn4HcD_0A6fgd11tHcT3p1U2RKXvIs6HflkvuLOOUzFxzxYCjDno2f1p6_q31dDE9AaUoEx1pi0Fs9ApJG2czL-88xrx3XO-oEP5ZXXsyXw0GKjA2W0A5q1Bk979SB1M?key=mLqAl_ccMoG4hHcRzSYKpw)**
>>>>>>> 9d0984e (Initial import from local subfolder)

