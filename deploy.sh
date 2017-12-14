# deploy.sh
#! /bin/bash

SHA1=$1

# Push image to ECR
$(aws ecr get-login --region eu-west-2)
docker push 916652753946.dkr.ecr.eu-west-2.amazonaws.com/sorting-visualiser:$SHA1

# Create new Elastic Beanstalk version
EB_BUCKET=sorting-visualiser1-deploy-bucket
DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE --region eu-west-2
aws elasticbeanstalk create-application-version --application-name sorting-visualiser1 \
    --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE \
    --region eu-west-2

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name sorting-visualiser1-env \
    --version-label $SHA1 \
    --region eu-west-2
