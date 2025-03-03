local transformer = {};

local function formatPath(path, config, scriptPath)
    local function normalizePath(p)
        if p == "" or p == "/" then
            return ""
        end
        local parts = {}
        for part in p:gmatch("[^/\\]+") do
            if part == ".." then
                if #parts > 0 then
                    table.remove(parts)
                end
            elseif part ~= "." then
                table.insert(parts, part)
            end
        end

        local normalizedPath = table.concat(parts, "/")
        if not string.match(normalizedPath, "%.[^/]+$") then 
            return normalizedPath .. ".lua"
        end

        return normalizedPath
    end

    if path:sub(1, 1) == "@" then
        local pathAfterAt = path:sub(2):gsub("^[/\\]+", "")
        local fullPath = config.project.sourceDirectory .. "/" .. pathAfterAt
        return normalizePath(fullPath)
    elseif path:sub(1, 1) == '.' then
        if not scriptPath then
            error("scriptPath is required for relative paths")
        end

        -- Remove the script's filename from the scriptPath
        local scriptDir = scriptPath:match("(.*/)")
        local fullPath = scriptDir .. path
        return normalizePath(fullPath)
    else
        local fullPath = config.project.sourceDirectory .. "/" .. path
        return normalizePath(fullPath)
    end
end

function transformer.parse(source, path, config)
    source = source:gsub('@import%("([^"]+)"%)', function(match)
        local processed = formatPath(match, config, path)
        return 'import("' .. processed .. '")';
    end)

    return source
end

return transformer;