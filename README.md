docker build -t pentaho:5.4 .

docker run --name pentaho -dti -p 8080:8080 -P --restart=always pentaho:5.4

docker exec -ti pentaho bash

Default login credentials: admin/password
