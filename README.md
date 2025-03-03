Lunar is a basic, highly customizable, tool that will bundle a bunch of lua script into a singular one.
This repository is a template for a lunar application. 

# Quick Start Guide:
## Requirements:
- luarocks
- luajit
- MinGW-W64

## Clone the project
```bash
git clone https://github.com/joaompds/lunar
```

## Install Luarocks dependencies
Install lua rock dependencies with:
```bash
luarocks install --only-deps lunar-release-1.rockspec
```

## Next steps:
- you can start to code your app using the "src" directory and creating a "index.lua" file there.
- you can start your app up by running `./lunar run`

# CLI
There are three main commands, which are both under the "lunar.bat" script:
- To build your project you use:
 ```bash
 ./lunar build --config=<config>
 ```
- To run your project you use:
 ```bash
 ./lunar run --config=<config>
 ```
- To listen for changes:
 ```bash
 ./lunar dev --config=<config>
 ```

In both of this commands you can pass the `--config` parameter, which is just the path to your configuratio file. If not provided it will default to `lunar.conf.json`.

# Configuration
The configuration of your project is a json file under the alias "lunar.conf.json".
It must have the following structure:
```json
{
    "build": {
        "outputDir": "the path to the directory where the build file will be outputed to",
        "fileFormat": "the file name of the built script (you can use %PROJECT_NAME%, %PROJECT_VERSION%", %DATE_NOW% and %DATE_NOW_ISO%)
        "include": ["an array of match expressions of lua files that will be included in the build"]
    },

    "project": {
        "name": "the project name",
        "version": "the project current version",
        "sourceDirectory": "where all the code is located and will be parsed",
        "main": "the index of the project (main lua file)"
    },

    "transformers": [
        "all of the enabled transformers"
    ]
}
```

# Transformers
You can modify the behavior of the compiler by using "transfomers".
To create a transformer you can add a file to the `lunar/transformers` directory with the name "<name>.lua".
The file must be a lua module that exports a function: `parse`.
The parse function must take 3 parameters: 
- source: the source before being transformed
- path: the path of the script that is being transformed
- config: the configuration of the project

The function must then change the source as mutch as it wants and then return it.

## Enabling a transformer
To enable a transformer, you must add it's name to the `transformers` array in the project settings.
