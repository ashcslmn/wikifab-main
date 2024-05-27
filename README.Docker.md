### Running Locally with Docker

When you're ready, start your application by running:

`docker compose up --build`.

Your application will be available at http://localhost:8080. 


### Deploying to a cloud provider | ec2 or gcp ubuntu instance

Prerequsite to have already a web service like apache2 or nginx running on the instance. The we will be proxying the requests to the docker container. 

Sample configuration for apache2

```bash
<VirtualHost *:80>
    ServerAdmin ashley@outsoar.ph
    ServerName wikifab.outsoar.ph

    ProxyRequests Off
    ProxyPreserveHost On
    AllowEncodedSlashes NoDecode

    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"


    <Proxy http://localhost:8081/*>
      Order deny,allow
      Allow from all
    </Proxy>

    ProxyPass / http://localhost:8081/ nocanon
    ProxyPassReverse / http://localhost:8081/
    ProxyPassReverse / http://wikifab.outsoar.ph/
RewriteEngine on
RewriteCond %{SERVER_NAME} =wikifab.outsoar.ph
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
```

1. SSH into your instance

2. install docker and docker-compose
   
   ```bash
   sudo apt-get update
   sudo apt-get install docker.io
   sudo apt-get install docker-compose
   ```

3. Clone the repository

   ```bash
    git clone https://github.com/ashcslmn/wikifab-main.git
    ```

4. Navigate to the project directory
   
   ```bash
   cd wikifab-main

   docker-compose up --build
   ```

5. Your application will be available at http://localhost:8080.

6. To run the application in the background, use the `-d` flag

   ```bash
   docker-compose up -d
   ```

