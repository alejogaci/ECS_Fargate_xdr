#!/bin/bash
INPUT_DIR="ecs_task_definitions"
OUTPUT_DIR="ecs_task_definitions_output"

for file in "$INPUT_DIR"/*.json; do
    [ -e "$file" ] || continue
    arn=$(jq -r '.taskDefinitionArn' "$file")
    task_name=$(echo "$arn" | awk -F'/' '{print $2}' | awk -F':' '{print $1}')
    output_file="$OUTPUT_DIR/${task_name}_out.json"

    if [[ -f "$output_file" ]]; then
        echo "📌 Registering new revision for $task_name..."
        
        # Register new revision
        aws ecs register-task-definition --cli-input-json file://"$output_file"
        if [[ $? -eq 0 ]]; then
            echo "✅ New revision created for $task_name"
        else
            echo "❌ Error registering $task_name"
        fi
    else
        echo "⚠ No file found for $task_name"
    fi
done
