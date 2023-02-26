# Check the file is exists or not
# DEPLOYMENT_DIRECTORY_NAME="/deployments/test/31337"
# DEPLOYMENT_DIRECTORY_NAME="deployments"

echo "$DEPLOYMENT_DIRECTORY_NAME logged"
if [ -n $DEPLOYMENT_DIRECTORY_NAME ]; then
   rm -r $DEPLOYMENT_DIRECTORY_NAME
   echo "$DEPLOYMENT_DIRECTORY_NAME is removed"
else
   echo "directory is not provided or filename does not exist"
fi