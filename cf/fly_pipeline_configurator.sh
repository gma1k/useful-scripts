set -e

echo "Please enter the target name. This is a name that you choose to identify your concourse instance."
read target_name
echo "Please enter the concourse url. This is the web address of your concourse instance, such as http://localhost:8080."
read concourse_url
echo "Please enter the pipeline name. This is a name that you choose to identify your pipeline."
read pipeline_name
echo "Please enter the pipeline file. This is the path to the YAML file that defines your pipeline configuration."
read pipeline_file

# Log in
fly login -t $target_name -c $concourse_url || { echo "Failed to log in to $target_name. Please check your credentials and url."; exit 1; }

# Set pipeline
fly set-pipeline -t $target_name -p $pipeline_name -c $pipeline_file || { echo "Failed to set pipeline $pipeline_name. Please check your pipeline file."; exit 1; }

# Unpause pipeline
fly unpause-pipeline -t $target_name -p $pipeline_name || { echo "Failed to unpause pipeline $pipeline_name."; exit 1; }

# Trigger the first job
first_job=$(fly jobs -t $target_name -p $pipeline_name | awk 'NR==2 {print $1}')
fly trigger-job -t $target_name -j $pipeline_name/$first_job || { echo "Failed to trigger job $first_job."; exit 1; }

echo "Pipeline $pipeline_name is set and triggered successfully."
