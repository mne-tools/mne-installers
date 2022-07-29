# %%
from pathlib import Path
from dataclasses import dataclass

import yaml
import requests
import packaging

recipes_dir = Path(__file__).parents[1] / 'recipes'
recipies = sorted([
    str(recipe) for recipe in recipes_dir.iterdir()
    if recipe.is_dir()
])
latest_recipe_dir = Path(recipies[-1])
construct_yaml_path = latest_recipe_dir / 'construct.yaml'

construct_yaml = yaml.safe_load(
    construct_yaml_path.read_text(encoding='utf-8')
)
specs = construct_yaml['specs']

@dataclass
class Package:
    name: str
    version: str | None

packages: list[Package] = []

for spec in specs:
    if ' ' in spec:
        name, version = spec.split(' ')
        version = (
            version
            .lstrip('~')
            .lstrip('=')
            .split('=')  # build number
        )[0]
    else:
        name = spec
        version = None

    packages.append(
        Package(name, version)
    )

outdated = []
not_found = []
for package in packages:
    if package.version is None:
        continue

    pypi_url = f'https://pypi.org/pypi/{package.name}/json'
    r =  requests.get(pypi_url)
    if r.status_code == 404:
        print(f'{package.name} not found on PyPI')
        not_found.append(package)
        continue

    json = r.json()
    pypi_version = json['info']['version']
    if (
        packaging.version.parse(package.version) <
        packaging.version.parse(pypi_version)
    ):
        print(f'{package.name} is outdated')
        outdated.append(package)
    else:
        print(f'{package.name} is up to date')

print(f'\n{len(not_found)} packages not found on PyPI:\n{not_found}')
print(f'\n{len(outdated)} packages are outdated:\n{outdated}')
