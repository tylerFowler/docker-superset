SERVICE_NAME=superset
BRANCH=${2:-$(git rev-parse --abbrev-ref HEAD)}
VERSION=${BRANCH}-${3:-latest}

docker -H $1 build \
    --no-cache \
    --pull \
    --rm \
    --build-arg JAR_FILE="$(cat ./JAR_FILE)" \
    --build-arg JAR_PATH="$(cat ./JAR_PATH)" \
    -t docker.amz.relateiq.com/relateiq/${SERVICE_NAME}:$VERSION .

docker -H $1 tag docker.amz.relateiq.com/relateiq/${SERVICE_NAME}:$VERSION docker.amz.relateiq.com/relateiq/${SERVICE_NAME}:latest

docker -H $1 push docker.amz.relateiq.com/relateiq/${SERVICE_NAME}:$VERSION

docker -H $1 push docker.amz.relateiq.com/relateiq/${SERVICE_NAME}:latest

echo $VERSION > VERSION
