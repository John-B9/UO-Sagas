----------------------------------------------------------------------
--- Combat Assistant (CA) Log
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---                   Reworked for Messages interface change
---
--- Description: Logging functions
----------------------------------------------------------------------

-----------------
--- Variables ---
-----------------

LogConfig = {
    EnableDebugLog = false,
    DebugLogTick = 60,
    EnableDebugTick = false, -- Overrides MainLoopTick in debug mode (script will run much slower)
    DebugTick = 500,
    EnableOverheadMessages = false -- Enables overhead messages, if false then messages will be printed in journal
}

local LogStaticConfig = {
    DatePattern = "%H:%M:%S",
    InfoTextColor    = 88,
    WarningTextColor = 34,
    ErrorTextColor   = 53,
    DebugTextColor   = 1153,
}

---------------
--- Setters ---
---------------

local function setEnableDebugLog_(val)
    LogConfig.EnableDebugLog = val
end

local function setDebugLogTick_(val)
    LogConfig.DebugLogTick = val
end

local function setEnableDebugTick_(val)
    LogConfig.EnableDebugTick = val
end

local function setDebugTick_(val)
    LogConfig.DebugTick = val
end

local function setEnableOverheadMessages_(val)
    LogConfig.EnableOverheadMessages = val
end

local function setConfig_(config)
    setEnableDebugLog_(config.EnableDebugLog)
    setDebugLogTick_(config.DebugLogTick)
    setEnableDebugTick_(config.EnableDebugTick)
    setDebugTick_(config.DebugTick)
    setEnableOverheadMessages_(config.EnableOverheadMessages)
end

-----------------
--- Functions ---
-----------------

local function adjustText_(text)
    if not text or (type(text) ~= "string" and type(text) ~= "table") then
        text = "Variabel message to print needs to be a string or table"
    end
    if type(text) == "table" then
        text = table.concat(text, ", ")
    end
    return text
end

local function adjustColor_(color)
    if not color or type(color) ~= "number" then
        color = LogStaticConfig.InfoTextColor
    end
    return color
end

local function overheadInternal_(text, color)
    Messages.OverheadMobile(Player.Serial, adjustText_(text), adjustColor_(color))
end

local function print_(text, color)
    Messages.Print(adjustText_(text), adjustColor_(color))
end

local function overhead_(text, color, force)
    if force or LogConfig.EnableOverheadMessages then
        overheadInternal_(text, color)
    else
        print_(text, color)
    end
end

local function mainInfo_(text)
    overhead_(text, LogStaticConfig.InfoTextColor, true)
end

local function info_(text)
    overhead_(text, LogStaticConfig.InfoTextColor, false)
end

local function warning_(text)
    overhead_(text, LogStaticConfig.WarningTextColor, false)
end

---@diagnostic disable-next-line: unused-local, unused-function
local function error_(text)
    overhead_(text, LogStaticConfig.ErrorTextColor, false)
end

local function debug_(text)
    
    if not LogConfig.EnableDebugLog then
        return
    end

    local ok, timestamp = pcall(function()
        return os.date(LogStaticConfig.DatePattern, os.time()) .. "." .. string.format("%03d", os.time() * 1000 % 1000)
    end)

    if not ok then
        timestamp = os.time()
    end

    if LogConfig.EnableDebugTick and LogConfig.DebugTick > LogConfig.DebugLogTick then
        Pause(LogConfig.DebugTick - LogConfig.DebugLogTick)
    end

    Console.log("[" .. timestamp .. "] " .. text, LogStaticConfig.DebugTextColor)
end

--------------
--- Export ---
--------------

local Obj = {
    setEnableDebugLog = setEnableDebugLog_,
    setDebugLogTick = setDebugLogTick_,
    setEnableDebugTick = setEnableDebugTick_,
    setDebugTick = setDebugTick_,
    setEnableOverheadMessages = setEnableOverheadMessages_,
    setConfig = setConfig_,
    mainInfo = mainInfo_,
    info = info_,
    warning = warning_,
    error = error_,
    debug = debug_
}

return Obj