#!/bin/bash

cd ${HOMEDIR}

#copypasta https://github.com/Phyremaster/papermc-docker/blob/master/papermc.sh

# Set variables
URL=https://api.papermc.io/v2/projects/paper

# Check if MC_VERSION is defined, otherwise use latest version
if [ ! -z "${MC_VERSION}" ]; then
    version=${MC_VERSION}
    # Verify the version exists
    if ! wget -qO - $URL | jq -e ".versions[] | select(. == \"${version}\")" > /dev/null; then
        echo "Error: Minecraft version ${MC_VERSION} is not available for Paper"
        exit 1
    fi
else
    version=$(wget -qO - $URL | jq -r '.versions[-1]')
fi

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

  # Download latest Geyser and Floodgate
  wget https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot -O ${HOMEDIR}/plugins/Geyser-Spigot.jar
  wget https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot -O ${HOMEDIR}/plugins/floodgate-spigot.jar
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