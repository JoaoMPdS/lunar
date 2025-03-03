
local lfs = require("lfs");
local fs = require("lunar/lib/fs");
local build = {};

function build:buildProject(config)
    local fstr = [[
-- Compiled by Lunar

local MODULES;

local function import(path)
    local module = MODULES[path];
    assert(module, "[RT/Import] Module not found: " .. path);
    return module();
end

MODULES = {
    ]];

    local files = {};
    local function load(path)
        for item in lfs.dir(path) do 
            if item == "." or item == ".." then goto continue end
            
            local fullPath = path .. "/" .. item;
            local attributes = lfs.attributes(fullPath);

            if attributes.mode == "directory" then
                load(fullPath);
            else
                local matches = false;
                for _, matchExp in pairs(config.build.include) do 
                    if item:match(matchExp) then matches = true end
                end
                if not matches then goto continue end

                files[fullPath] = self:parse(fs:readFile(fullPath), fullPath, config);
            end

            ::continue::
        end
    end
    load(config.project.sourceDirectory);

    for path, source in pairs(files) do
       fstr = fstr .. '\n\t["' .. path .. '"] = function()\n' .. source .. '\n\tend,';
    end

    fstr = fstr .. [[
}
import("]] .. config.project.main .. [[")
    ]];

    return fstr;
end

function build:parse(source, path, config)
    for _, transformer in ipairs(config.transformers) do
        local module = require("lunar/transformers/" .. transformer);
        if module["parse"] then 
            source = module["parse"](source, path , config);
        end
    end

    return source;
end

return build;