local lfs = require("lfs");

local fs = {};

function fs.fileExists(path)
    assert(path, "[FS] No file path provided!");
    local file_attributes = lfs.attributes(path);

    return file_attributes and file_attributes.mode == "file";
end

function fs:readFile(path)
    assert(path, "[FS] No file path provided!");
    assert(self.fileExists(path), ("[FS] Invalid file path: " .. path));

    local file, err = io.open(path, "r");
    if not file then
        print("Error opening file: " .. err);
        return
    end

    local content = file:read("*a")
    file:close()
    return content;
end

function fs:writeFile(path, content)
    assert(path, "[FS] No file path provided!")
    assert(content, "[FS] No content provided!")

    -- Create nested directories if they don't exist
    local dir = path:match("(.*/)")
    if dir then
        local currentDir = ""
        for folder in dir:gmatch("([^/]+)/") do
            currentDir = currentDir .. folder .. "/"
            lfs.mkdir(currentDir)
        end
    end

    -- Write content to file
    local file, err = io.open(path, "w")
    if not file then
        print("Error opening file: " .. err)
        return
    end

    file:write(content)
    file:close()
end

function fs.onFileUpdate(path, callback)
    local file_mod_times = {}

    -- Function to scan directory and detect changes
    local function scan_directory()
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local file_path = path .. "/" .. file
                local attr = lfs.attributes(file_path)
    
                if attr and attr.mode == "file" then
                    local last_mod = attr.modification
    
                    if file_mod_times[file] and file_mod_times[file] ~= last_mod then
                        callback();
                    end
    
                    file_mod_times[file] = last_mod
                end
            end
        end
    end

    local function wait(seconds)
        if package.config:sub(1,1) == "\\" then
            -- Windows
            os.execute("timeout /nobreak " .. seconds .. " >nul")
        else
            -- Unix (Linux/macOS)
            os.execute("sleep " .. seconds)
        end
    end

    while true do
        scan_directory();
        wait(1);
    end
end

return fs;