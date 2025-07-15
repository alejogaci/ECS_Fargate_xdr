#!/bin/bash

# List all ECS Clusters
clusters=$(aws ecs list-clusters --query "clusterArns[]" --output text)

mkdir -p ecs_task_definitions
for cluster_arn in $clusters; do
    echo "Processing cluster: $cluster_arn"

    # List cluster services with fargate
    services=$(aws ecs list-services --cluster "$cluster_arn" --query "serviceArns[]" --output text)

    for service_arn in $services; do
        launchType=$(aws ecs describe-services --cluster "$cluster_arn" --services "$service_arn" \
            --query "services[0].launchType" --output text)

        if [[ "$launchType" == "FARGATE" ]]; then
            echo "  → Fargate service: $service_arn"

            task_def_arn=$(aws ecs describe-services --cluster "$cluster_arn" --services "$service_arn" \
                --query "services[0].taskDefinition" --output text)

            if [[ -z "$task_def_arn" || "$task_def_arn" == "None" ]]; then
                echo "    ⚠ No valid service found"
                continue
            fi

            task_def_name=$(echo "$task_def_arn" | awk -F'[:/]' '{print $(NF-1)}')

            # Validar que se extrajo correctamente el nombre
            if [[ -z "$task_def_name" ]]; then
                echo "    ⚠ Error found in the tas definition."
                continue
            fi

            aws ecs describe-task-definition --task-definition "$task_def_name" \
                --query "taskDefinition" --output json > "ecs_task_definitions/${task_def_name}.json"

            echo "    ✔ JSON file saved in ecs_task_definitions/${task_def_name}.json"
        fi
    done
done

echo "✅ Process successful. JSON files available inside ecs_task_definitions/"
