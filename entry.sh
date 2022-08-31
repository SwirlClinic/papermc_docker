#!/bin/bash

cd ${HOMEDIR}

#copypasta https://github.com/Phyremaster/papermc-docker/blob/master/papermc.sh

# Set variables
URL=https://papermc.io/api/v2/projects/paper
version=$(wget -qO - $URL | jq -r '.versions[-1]')
URL=${URL}/versions/${version}
PAPER_BUILD=$(wget -qO - $URL | jq '.builds[-1]')
JAR_NAME=paper-${version}-${PAPER_BUILD}.jar
URL=${URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}

if [ ! -e ${JAR_NAME} ]
then
  # Remove old server jar(s)
  rm -f *paper*.jar
  # Download new server jar
  wget ${URL} -O ${JAR_NAME}

  wget https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar -O ${HOMEDIR}/plugins/Geyser-Spigot.jar
  wget https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/build/libs/floodgate-spigot.jar -O ${HOMEDIR}/plugins/floodgate-spigot.jar
fi

# If this is the first run, accept the EULA
if [ ! -e ${HOMEDIR}/eula.txt ]
then
    echo "Accepting eula"
    cp ${MISC_DIR}/eula.txt ${HOMEDIR}/eula.txt
fi


# Add RAM options to Java options if necessary
if [ ! -z "${MC_RAM}" ]
then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} ${JAVA_OPTS}"
fi

echo "Starting ${JAR_NAME} with ${JAVA_OPTS}"
exec java -server ${JAVA_OPTS} -jar ${JAR_NAME} nogui