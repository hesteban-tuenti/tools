#!/usr/bin/env python3
import os
import argparse
import json

WORKDIR = "<your_workdir>"

# user args parse to read the feature file
parser = argparse.ArgumentParser()

parser.add_argument("new", help="new feature file to add")
parser.add_argument("-a", "--after", help="feature file to add it after")
parser.add_argument("-d", "--directory", help="directory to restrict the search for runners")
parser.add_argument("-k", "--key", help="key to find json files")

args = parser.parse_args()



def find_json_files(directory, key=None):
    """
    Find all json files in the directory and use the key to filter the files if provided
    """
    json_files = []
    for root, dirs, files in os.walk(directory):
        for basename in files:
            if basename.endswith('.json'):
                filename = os.path.join(root, basename)
                if key and key not in filename:
                    continue
                json_files.append(filename)
    return json_files


def find_feature_in_json_files(json_files, feature):
    """
    Find the feature in the json files and return the files into a list
    """
    result = []
    for file in json_files:
        with open(file, 'r') as f:
            for line in f:
                if feature in line:
                    result.append(file)
    if not result:
        print(f"Feature '{feature}' not found in any json files")
        exit(1)
    return result


def add_feature_to_json(**kwargs):
    """
    Add the feature to the json files
    """
    print("Writing to json files:")
    print('\n'.join(file.replace(WORKDIR,'') for file in kwargs['json_files']))
    # Input user for confirmation
    print("Do you want to continue? (y/n)")
    if input() != 'y':
        print("Canceled!!")
        exit(1)
    for file in kwargs['json_files']:
        with open(file, 'r') as f:
            data = json.load(f)
            if kwargs['feature'] in data[0]['behave_features']:
                print(f"    - Canceled!!- feature already exists in {file}")
                continue
            if kwargs.get('after'):
                index = data[0]['behave_features'].index(kwargs['after'])
                data[0]['behave_features'].insert(index+1, kwargs['feature'])
            else:
                data[0]['behave_features'].append(kwargs['feature'])
        
        with open(file, 'w') as f:
            print(f"    - {file.replace(WORKDIR,'')}")
            json.dump(data, f, indent=2)

if __name__ == '__main__':
    path = f"{WORKDIR}/novum-tests/acceptance/settings"
    if args.directory:
        path = path + "/" + args.directory

    print(path)

    all_json_files = find_json_files(path) if not args.key else find_json_files(path, args.key)

    if args.after:
        # find json files which the after feature file:
        result_json_files = find_feature_in_json_files(all_json_files, args.after)
        add_feature_to_json(json_files=result_json_files, feature=args.new, after=args.after)
    else:
        result_json_files = all_json_files
        add_feature_to_json(json_files=result_json_files, feature=args.new)