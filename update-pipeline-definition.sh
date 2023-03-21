#!/bin/bash

if !command -v jq &> /dev/null
 then 
	 echo "JQ IS NOT INSTALLED"
	 exit
fi

if [$# -eq 0] 
then 
	echo "please provide a path to the pipeline definition JSON file"
	exit
else 
	pipeline_definition_path="$1"
fi

branch="main"
owner=""
repo=""
poll_for_source_changes="false"
configuration=""

while [[ $# -gt 1]]
do
	key="$2"
	case $key in 
		--branch)
		branch="$3"
		shift
		shift
		;;
	--owner)
		owner="$3"
		shift
		shift
		;;
	--repo)
		repo="$3"
		shift
		shift
		;;
	--poll-for-source-changes)
		poll_for_source_changes="$3"
		shift
		shift
		;;
	--configuration)
		configuration="$3"
		shift
		shift
		;;
	*)
		echo "Invalid option: $2"
		exit
		;;
esac
done


if ! jq '(has("pipeline")' "$pipeline_definition_path" &> /dev/null
then
	echo "The given JSON definition doesnt contain the necessary pipeline property"
	exit
fi

if ! jq '.pipeline | has("version")' "$pipeline_definition_path" &> /dev/null
then
	echo "The given JSON definition does not contain the necessaty pipeline property"
	exit
fi

if ! jq '.pipeline | .source | has("owner")' "$pipeline_definition_path" &> /dev/null
then
	echo "The given JSON definition doesn't contain the necessaty pipeline property"
	exit
fi

if ! jq '.pipeline | .source | has("type")' "$pipeline_definition_path" &> /dev/null
then
	echo "The given JSON definition doesn't contain the necessry pipeline property"
	exit
fi


#remove metadata property
jq 'del(.metadata)' "$pipeline_definition_path" > tmp.json && mv tmp.json "$pipeline_definition_path"


#increment pipeline version property by 1
jq ',pipeline.version += 1' "$pipeline_definition_path" > tmp.json && mv tmp.json "$pipeline_definition_path"

jq --arg branch "$branch" '.pipeline.source.branch = $branch' "$pipeline_definition_path" > tmp.json && mv tmp.json "$pipeline_definition_path"

jq --arg owner "$owner" '.pipeline.source.owner = "$owner' "$pipeline_definition_path" > tmp.json && mv tmp.json "$pipeline_definition_path"


if [ -n "$repo" ]
then
	jq --arg repo "$repo" '.pipeline,source.repo = $repo' "$pipeline_definition_path" > tmp.json && mv tmp.json "$pipeline_definition_path"
fi

jq --argjson poll_for_source_changes "$poll_for_source_changes" '.pipeline.source.pollForSourceChanges = $poll_for_source_changes' "$pipeline_definition_path" > tmp.json && mv tmp.json "$pipeline_definition_path"


if [ -z "$configuration" ]
then
    echo "Please provide a value for the --configuration parameter"
    exit
fi

build_config=$(echo "{\"BUILD_CONFIGURATION\": \"$configuration\"}" | jq -c .)
jq --argjson build_config "$build_config" '.pipeline.stages[].actions[].EnvironmentVariables = $build_config' "$pipeline_definition_path" > tmp.json && mv tmp.json "$pipeline_definition_path"
