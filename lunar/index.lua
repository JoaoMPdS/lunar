local VERSION = "dev-1";

local lunajson = require("lunajson");
local fs = require("lunar/lib/fs");
local build = require("lunar/lib/build");

function string.split(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end

function string.startswith(String,Start)
    return string.sub(String,1,string.len(Start)) == Start
end

function table.includes(table, match)
    for i, v in ipairs(table) do
        if v == match then return i end
    end

    return false;
end

local function decodeArgs(args)
    local decoded = {
        params = {},
        args = {}
    };

    for _, v in ipairs(args) do 
        if  string.startswith(v, "--") then 
            v = string.sub(v, 3, -1);
            local split = string.split(v, "=");

            if string.find(v, "=") then
                decoded.params[split[1]] = split[2];
            else
                decoded.params[split[1]] = true;
            end
        else
            table.insert(decoded.args, v);
        end
    end

    return decoded;
end

local function loadConfig(args)
    local configPath = args.params["config"] or "lunar.conf.json"
    local data = fs:readFile(configPath);
    local decoded = lunajson.decode(data);
    
    return decoded;
end

local function formatString(str, config)
    local repls = {
        ["%%PROJECT_NAME%%"] = config.project.name,
        ["%%PROJECT_VERSION%%"] = config.project.version,
        ["%%DATE_NOW%%"] = tostring(os.time()),
        ["%%DATE_NOW_ISO%%"] = os.date("%Y-%m-%d %H:%M:%S"),
    };

    for match, repl in pairs(repls) do
        str = str:gsub(match, repl);
    end

    return str;
end

local function validateConfig(config)
    local schema = {
        build = {
            outputDir = "string",
            fileFormat = "string",
            include = {},
        },
        project = {
            name = "string",
            version = "string",
            sourceDirectory = "string",
            main = "file",
        },

        transformers = {}
    }

    local function validate(t, s)
        for key, expectedType in pairs(s) do
            if t[key] == nil then
                return string.format("Missing required field: %s", key)
            end

            if type(expectedType) == "table" then
                if type(t[key]) ~= "table" then
                    return string.format("Invalid field %s: Expected table, got %s", key, type(t[key]))
                end

                local validationResult = validate(t[key], expectedType)
                if validationResult ~= true then
                    return validationResult
                end
            else
                if expectedType == "file" then
                    if type(t[key]) ~= "string" then
                        return string.format("Invalid field %s: Expected file path (string), got %s", key, type(t[key]))
                    end
                    if not fs.fileExists(t[key]) then
                        return string.format("Invalid field %s: File does not exist: %s", key, t[key])
                    end
                elseif type(t[key]) ~= expectedType then
                    return string.format("Invalid field %s: Expected %s, got %s", key, expectedType, type(t[key]))
                end
            end
        end

        return true
    end

    return validate(config, schema)
end

local args = decodeArgs(arg);
local config = loadConfig(args);
assert(config, "[Config] No configuration was provided.");
local isConfigValid = validateConfig(config);
if isConfigValid ~= true then error("[Config] An invalid configuration was provided: " .. isConfigValid) end

local usage;

local actions = {
    build = function ()
        local final = build:buildProject(config);
        fs:writeFile(config.build.outputDir .. "/" .. formatString(config.build.fileFormat, config) .. ".lua", final);
    end,
    
    run = function ()
        local final = build:buildProject(config);
        local f = load(final);
        assert(f, "[RUN] Failed to load compiled project.");
        f();
    end,

    dev = function ()
        local function get_time_ms()
            return os.time() * 1000 + math.floor(os.clock() * 1000)
        end

        local function run()
            local startTime = get_time_ms();
            if package.config:sub(1,1) == "\\" then
                -- Windows
                os.execute("cls");
            else
                -- Unix (Linux/macOS)
                os.execute("clear");
            end

            print("[DEV] Building project...");
            local final = build:buildProject(config);
            local f = load(final);
            assert(f, "[RUN] Failed to load compiled project.");
            f();
            print("[DEV] Ran project in " .. (get_time_ms() - startTime) .. "ms.");
        end
        print("[DEV] Watching for changes...");
        fs.onFileUpdate(config.project.sourceDirectory, run);
    end,

    version = function() 
        print("Lunar version " .. VERSION);
    end,

    help = function ()
        print(usage:sub(2, -1));
    end
};

usage = "\nUsage:";
for action, _ in pairs(actions) do usage = usage .. "\n- " .. action end

assert(actions[args.args[1]], ("[Args] Invalid argument 1: " .. (args.args[1] or "NULL") .. usage));

actions[args.args[1]]();