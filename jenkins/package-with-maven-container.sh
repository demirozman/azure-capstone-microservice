echo 'Running Nihgtly on Petclinic Application New Tryout'
docker run --rm -v $HOME/.m2:/root/.m2 -v $WORKSPACE:/app -w /app maven:3.6-openjdk-11 mvn clean package