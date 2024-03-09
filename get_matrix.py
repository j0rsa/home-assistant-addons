import os
import yaml
import subprocess
import argparse
import json

class MatrixGenerator:
    def __init__(self, directory = '.', from_changes:bool = False, previous: bool = False):
        if from_changes:
            if previous:
                print("Getting git changes from HEAD")
                self.directories = self.__get_changed_directories(directory, "HEAD~1")
            else:
                print("Getting uncommitted git changes from working directory")
                self.directories = self.__get_changed_directories(directory)
        else:
            print("Using the current directory")
            self.directories = [directory]
    
    def __get_changed_directories(self, directory, hash = '') -> list:
        git_command = ['git', 'diff', '--name-only']
        if hash:
            git_command.append(hash)
        output = subprocess.check_output(git_command, cwd=directory, universal_newlines=True)
        changed_files = output.strip().split('\n')
        print(f"Changed files: {changed_files}")
        changed_directories = set()
        for file in changed_files:
            directory_name = os.path.dirname(file)
            changed_directories.add(directory_name)
        return list(changed_directories)

    def __find_module_architectures(self) -> dict:
        result = {}
        for directory in self.directories:
            for root, dirs, files in os.walk(directory):
                for file in files:
                    if file == 'config.yaml':
                        file_path = os.path.join(root, file)
                        with open(file_path, 'r') as f:
                            config = f.read()
                            # Assuming the architecture is specified in the config.yaml file
                            architecture = self.extract_architecture(config)
                            directory_name = os.path.basename(root)
                            result[directory_name] = architecture
        return result

    def extract_architecture(self, config) -> list:
        config_data = yaml.safe_load(config)
        architecture = config_data.get('arch')
        return architecture

    def get_matrix(self, architectures = None) -> dict:
        if architectures is None:
            architectures = self.__find_module_architectures()
        result = []
        for target, architecture in architectures.items():
            platforms = " ". join(["--" + platform for platform in architecture])
            result.append({'target': target, 'platforms': platforms})
        return {'include': result}
    
    def get_json_matrix(self, architectures = None) -> str:
        matrix = self.get_matrix(architectures)
        return json.dumps(matrix)


parser = argparse.ArgumentParser()
parser.add_argument('--from-changes', action='store_true', help='Generate matrix from changed directories')
parser.add_argument('--previous', action='store_true', help='Use previous commit to generate matrix')
args = parser.parse_args()

converter = MatrixGenerator(from_changes=True, previous=True)
# converter = MatrixGenerator(from_changes=args.from_changes, previous=args.previous)

matrix = converter.get_matrix()
with open('matrix-count.txt', 'w') as f:
    f.write(str(len(matrix['include'])))

json_matrix = converter.get_json_matrix()
print(json_matrix)
with open('matrix.txt', 'w') as f:
    f.write(json_matrix)