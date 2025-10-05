#!/bin/bash

REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

for region in $REGIONS; do
    echo "Région: $region"
    VPCS=$(aws ec2 describe-vpcs --region $region --query "Vpcs[].VpcId" --output text)
    for vpc in $VPCS; do
        echo "Suppression du VPC $vpc dans $region"

        # Detach et suppression des Internet Gateways
        IGWS=$(aws ec2 describe-internet-gateways --region $region --query "InternetGateways[?Attachments[?VpcId=='$vpc']].InternetGatewayId" --output text)
        for igw in $IGWS; do
            aws ec2 detach-internet-gateway --region $region --internet-gateway-id $igw --vpc-id $vpc
            aws ec2 delete-internet-gateway --region $region --internet-gateway-id $igw
        done

        # Suppression des Subnets
        SUBNETS=$(aws ec2 describe-subnets --region $region --query "Subnets[?VpcId=='$vpc'].SubnetId" --output text)
        for subnet in $SUBNETS; do
            aws ec2 delete-subnet --region $region --subnet-id $subnet
        done

        # Suppression du VPC
        aws ec2 delete-vpc --region $region --vpc-id $vpc
    done
done

