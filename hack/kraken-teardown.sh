#!/bin/sh

# NOTE: TODO: remove this comment after acceptance.
# This script is currently in the proposal stage. 
#   Goal: provide a means of tearing down Kraken clusters *without* access to
#     the configuration files that generated them. 
#   Means:
#     Requires a cluster name as first and only argument.
#     Queries AWS API, based on the `KubernetesCluster` tag whereever possible.
#     Generates DELETE (equivalent) API calls in the correct order, to remove
#       the cluster from AWS.
#     Should tolerate partially removed clusters in some cases, insofar as 
#       querying their associated elements will simply produce empty sets.
#
#   Limitations:
#     The identification of IAM roles to delete is predicated upon their 
#       reference within the ASG Launch Configurations. If not found, they will 
#       not be removed.
#     The actual DELETE effects are masked by `echo` statements below.
#       TODO: upon acceptance, remove the `echo` statements masking DELETE ops.
# 

AWS_REGION=${AWS_REGION:-us-east-2}
AWS_COMMON_ARGS="--region=${AWS_REGION} --output=text"

info() {
  [ "${VERBOSE:-0}" -gt 0 ] && echo "$@" >&2 || return 0
}

delete_asg () {
  info "Deleting ASG: $1"  
  echo aws ${AWS_COMMON_ARGS} autoscaling delete-auto-scaling-group --auto-scaling-group-name $1
}

delete_launchconfig () {
  info "Deleting Launch Configuration: $1"
  echo aws ${AWS_COMMON_ARGS} autoscaling delete-launch-configuration --launch-configuration-name $1
}

delete_keypair () {
  info "Deleting Key Pair: $1"
  echo aws ${AWS_COMMON_ARGS} ec2 delete-key-pair --key-name $1
}

delete_instances () {
  info "Terminating Instances: $@"
  echo aws ${AWS_COMMON_ARGS} ec2 terminate-instances  --instance-ids "$@" 
}

delete_elb (){ 
  info "Deleting LoadBalancer: $1"
  echo aws ${AWS_COMMON_ARGS} elb delete-load-balancer --load-balancer-name "$1"
}

delete_vpc () {
  info "Deleting VPC: $1"
  echo aws ${AWS_COMMON_ARGS} vpc delete-vpc --vpc-id $1
}

delete_iam_profile () {
  info "Deleting IAM Profile: $1"
  echo aws iam delete-instance-profile --instance-profile-name $1
}

delete_iam_role () {
  info "Deleting IAM Role: $1"
  echo aws iam delete-role --role-name $1
}

delete_route53_zone () {
  info "Deleting Route53 zone: $1"
  echo aws route53 delete-hosted-zone --id $1
}

describe_cluster_instances () {
  aws ${AWS_COMMON_ARGS} ec2 describe-instances \
    --filter="Name=tag:KubernetesCluster, Values=$1" \
    --query="Reservations[*].Instances[*].{a:InstanceId, b:Tags[?Key=='Name']|[0].Value}"
}

describe_launchconfig () {
  aws ${AWS_COMMON_ARGS} autoscaling describe-launch-configurations \
    --launch-configuration-name $1 \
    --query "LaunchConfigurations[*].{a:LaunchConfigurationName, b:KeyName, c:IamInstanceProfile}"
}

describe_asg () {
  # Produce fields in specific order: GroupName, ARN
  # Columns are ordered alphabetically to their aliases (a and b, here)
  aws ${AWS_COMMON_ARGS} autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names $@ \
    --query 'AutoScalingGroups[*].{a:AutoScalingGroupName, b:AutoScalingGroupARN, c:LaunchConfigurationName}' 
}

list_elb_all () {
  aws ${AWS_COMMON_ARGS} elb describe-load-balancers \
    --query="LoadBalancerDescriptions[*].{a:LoadBalancerName}"
}

list_elb_cluster_tags () {
  aws ${AWS_COMMON_ARGS} elb describe-tags --load-balancer-names $@  \
    --query="TagDescriptions[*].{a:LoadBalancerName, b:Tags[?Key=='KubernetesCluster']|[0].Value}"
}

list_elb_by_cluster_tag (){ 
  list_elb_cluster_tags $(list_elb_all) | awk "{ if(\$2 == \"$1\"){ print \$1 } }"
}

list_asg_by_cluster_tag () {
  aws ${AWS_COMMON_ARGS} autoscaling describe-tags \
    --filters "Name=Key, Values=KubernetesCluster" "Name=Value, Values=$1" \
    --query "Tags[*].{a:Value, b:ResourceId, c:ResourceType}" \
      | awk "{ if(\$3 == \"auto-scaling-group\") { print \$2 } }"
}

list_vpc_by_cluster_tag () {
  aws ${AWS_COMMON_ARGS} ec2 describe-vpcs \
    --filter "Name=tag:KubernetesCluster, Values=$1" \
    --query="Vpcs[*].{a:VpcId, b:Tags[?Key=='Name']|[0].Value}"
}

list_iam_roles_for_profile () {
  aws ${AWS_COMMON_ARGS} iam get-instance-profile  --instance-profile-name "$1" \
    --query "InstanceProfile.{a:Roles[*]|[0].RoleName, b:InstanceProfileName}"
}

list_route53_zones_by_name () {
  aws ${AWS_COMMON_ARGS} route53 list-hosted-zones \
    --query="HostedZones[*].{b:Id, a:Name}" --max-items=10000  \
      | awk "{ if(\$1 == \"$1\") { print \$2 }}"
}


delete_cluster_artifacts () {
  # Expects first argument to be the cluster name.

  roles_to_delete=`mktemp /tmp/delete_roles.XXXXX`
  keys_to_delete=`mktemp /tmp/delete_keys.XXXXX`

  # Iterate through autoscaling groups for this cluster.
  list_asg_by_cluster_tag "$1" | while read asgname; do

    describe_asg ${asgname} | while read asgname arn lcn; do
        describe_launchconfig $lcn | while read lcn kpn iamprofile; do
        
          # Queue keypair for deletion (if exists)
          echo "${kpn}" >> $keys_to_delete
          
          # Queue IAM role  for deletion (if exists)
          echo "${iamprofile}" >> $roles_to_delete
        done
        
        # Remove launch configuration
        delete_launchconfig ${lcn}
    
    done 

    # Remove the autoscaling group
    delete_asg ${asgname}
  done  
  
  sort $keys_to_delete | uniq | while read kpn; do
    delete_keypair ${kpn}
  done

  # Remove remaining EC2 instances
  delete_instances `describe_cluster_instances $1 | awk '{ print $1 }'`

  # Remove associated load balancers
  list_elb_by_cluster_tag "$1" | while read elb; do
    delete_elb $elb
  done

  # TODO: Remove associated network interfaces

  # Remove associated VPC
  list_vpc_by_cluster_tag "$1" | while read vpcid vpcName; do
    delete_vpc $vpcid
  done

  # Remove associated IAM roles
  sort $roles_to_delete | uniq | while read iamprofile; do
    list_iam_roles_for_profile $iamprofile | while read role profile; do
      delete_iam_profile $profile
      delete_iam_role $role
    done
  done

  # Remove zones associated with the cluster
  list_route53_zones_by_name "$1.internal." | while read zone; do
    delete_route53_zone $zone
  done

  rm -v $roles_to_delete $keys_to_delete
}




main () {
  set -e
  delete_cluster_artifacts "${1:-$CLUSTER_NAME}"
  set +e
}


main "${@}"
