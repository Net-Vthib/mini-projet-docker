# mini-projet-docker

#Ennoncé sur ce repo
https://github.com/eazytraining/bootcamp-project-update/tree/main/mini-projet-docker




#Création du dockerfile
FROM amazoncorretto:17-alpine
LABEL maintainer="netvthib@gmail.com"
WORKDIR /app
COPY target/paymybuddy.jar /app/paymybuddy.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/paymybuddy.jar"]

#Création de l'image 
docker build -t paymybuddy-backend:v1 .

#Création du docker-compose.yml
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

  
#Création du .env
MYSQL_DATABASE=db_paymybuddy
MYSQL_ROOT_PASSWORD=password
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/db_paymybuddy?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=password
SERVER_PORT=8080

#Modification du create.sql initdb en ajoutant IF NOT EXISTS

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
        
#Création du registre privé pour stocker les images, fait sur play docker eazytraining
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

#Tag et push des images depuis ma VM distante vers mon registre privé 

docker tag paymybuddy-backend:v1 ip10-0-48-4-d3d71hu57ed000eubmk0-5000.direct.docker.labs.eazytraining.fr/paymubbuddy:remote
docker push  ip10-0-48-4-d3d71hu57ed000eubmk0-5000.direct.docker.labs.eazytraining.fr/paymubbuddy:remote

docker tag mysql:8.0.43 ip10-0-48-4-d3d71hu57ed000eubmk0-5000.direct.docker.labs.eazytraining.fr/mysql:remote
docker push ip10-0-48-4-d3d71hu57ed000eubmk0-5000.direct.docker.labs.eazytraining.fr/mysql:remote

  

  

