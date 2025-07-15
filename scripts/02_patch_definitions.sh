#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_DIR="${SCRIPT_DIR}/ecs_task_definitions"
OUTPUT_DIR="${SCRIPT_DIR}/ecs_task_definitions_output"
mkdir -p "$OUTPUT_DIR"
docker pull trendmicrocloudone/ecs-taskdef-patcher:2.6.9

for input_file in "$INPUT_DIR"/*.json; do

    filename=$(basename -- "$input_file")
    filename_noext="${filename%.json}"


    output_file="${filename_noext}_out.json"

    echo "Processing: $filename → $output_file"
    docker run --rm -ti \
      -v "$INPUT_DIR":/mnt/input \
      -v "$OUTPUT_DIR":/mnt/output \
      trendmicrocloudone/ecs-taskdef-patcher:2.6.4 \
      -i "/mnt/input/$filename" \
      -o "/mnt/output/$output_file"

    echo "✔ File generated: $OUTPUT_DIR/$output_file"
done

zip -r json_task.zip "$OUTPUT_DIR"

echo "✅ Process successful. JSON files available inside $OUTPUT_DIR/"
