# ECS Task Definition Automation for XDR Enablement

This repository contains a set of three Bash scripts designed to **automate the enablement of the XDR (Extended Detection and Response) module** for containers deployed in AWS ECS using Fargate.

The automation follows three main steps:
1. **Extract** the task definitions currently used by Fargate services.
2. **Patch** those definitions with the necessary XDR configuration using the Trend Micro patcher container.
3. **Register** the patched definitions as new revisions in ECS.

---

## 📁 Folder Structure

- `ecs_task_definitions/`: Stores the original task definitions (extracted).
- `ecs_task_definitions_output/`: Stores the patched task definitions.
- `json_task.zip`: (Optional) A ZIP archive containing all patched task definitions.

---

## 🔧 Script Descriptions

### 1. `01_extract_definitions.sh`

- Lists all ECS clusters and services.
- Filters for services using the `FARGATE` launch type.
- Extracts their current task definitions using the AWS CLI.
- Saves each task definition as a JSON file in `ecs_task_definitions/`.

**Output:**
- Files like `ecs_task_definitions/my-task.json`

---

### 2. `02_patch_definitions.sh`

- Pulls the Docker image: `trendmicrocloudone/ecs-taskdef-patcher:2.6.4`.
- Loops over all JSON files in `ecs_task_definitions/`.
- Runs the patcher container for each file to inject XDR configuration.
- Outputs patched versions into `ecs_task_definitions_output/`.
- Creates a ZIP archive (`json_task.zip`) with all patched files.

**Output:**
- Files like `ecs_task_definitions_output/my-task_out.json`
- `json_task.zip` containing all patched files.

---

### 3. `03_register_definitions.sh`

- For each original task definition:
  - Extracts the `taskDefinitionArn`.
  - Identifies the corresponding patched JSON file.
  - Registers the new revision using the AWS CLI.

**Output:**
- A message indicating whether each task definition was successfully registered as a new revision.

---

## 🚀 How to Use

Make sure the following tools are installed and configured on your system:

- ✅ [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- ✅ Docker
- ✅ [`jq`](https://stedolan.github.io/jq/) for JSON parsing

---

### 📌 Step-by-step

#### 1. Extract ECS Task Definitions

```bash

./01_extract_definitions.sh
```

This will populate the ecs_task_definitions/ folder with the original task definition JSONs.

#### 2. Patch Definitions for XDR Enablement  

```bash 
./02_patch_definitions.sh

```
This uses the Trend Micro patcher Docker container to add the required XDR configuration. Results are stored in ecs_task_definitions_output/.

3. Register the New Revisions  

 ```bash 
./03_register_definitions.sh
```

Each patched file is registered as a new task definition revision in ECS.

✅ Validation  
After each step, check:

✔️ Files are created in the correct output folders.

✔️ The terminal shows success messages for each processed task.

✔️ New revisions are visible in the ECS Console (optional).

Note: This automation only registers new revisions — it does not update the running ECS services. You must manually update the service to use the new revision if needed.

📫 Feedback  
If you encounter issues or have suggestions for improvement, feel free to open an issue or submit a pull request.

