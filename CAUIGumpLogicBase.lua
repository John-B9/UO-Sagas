----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Logic Base
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: Base functions for handling UI logic
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Constants ---
-----------------

local ColorOptions = {
    Green = 1,
    Orange = 2,
    Red = 3
}

local ColorValues = {
    { 0,   1, 0, 1 },
    { 1, 0.5, 0, 1 },
    { 1,   0, 0, 1 }
}

CAUIGumpLogicBaseState = {
    SharedVisibilityConfigWindowsCloseFunctions = {},
    LastWindowPosition = {
        X = nil,
        Y = nil
    },
    LastConfigWindowOpenTime = nil,
    WindowAutoCloseTime = 4000,
    CloseWindowCallback = nil
}

-----------------
--- Functions ---
-----------------

local function getColorOptions_()
    return ColorOptions
end

local function registerSharedVisibilityConfigWindowsCloseFunction_(closeFunction)
    table.insert(CAUIGumpLogicBaseState.SharedVisibilityConfigWindowsCloseFunctions, closeFunction)
end

local function setWindowAutoCloseTime_(timeout)
    if CAUIGumpLogicBaseState.WindowAutoCloseTime ~= timeout then
        if timeout then
            cal.debug('Setting config window close timer to: '..timeout..'(s)...')
        else
            cal.debug('Disabling config window close timer...')
        end
        CAUIGumpLogicBaseState.WindowAutoCloseTime = timeout
        if CAUIGumpLogicBaseState.WindowAutoCloseTime ~= nil then
            local currentTickTime = cat.getCurrentTime()
            CAUIGumpLogicBaseState.LastConfigWindowOpenTime = currentTickTime
        else
            CAUIGumpLogicBaseState.LastConfigWindowOpenTime = nil
        end
    end
end

local function clearConfigWindowCloseState_()
    cal.debug("Clearing timer to close config window...")
    CAUIGumpLogicBaseState.LastConfigWindowOpenTime = nil
    CAUIGumpLogicBaseState.CloseWindowCallback = nil
end

local function setConfigWindowCloseState_(closeWindowCallback)
    if CAUIGumpLogicBaseState.WindowAutoCloseTime ~= nil then
        cal.debug("Setting timer to close config window...")
        local currentTickTime = cat.getCurrentTime()
        CAUIGumpLogicBaseState.LastConfigWindowOpenTime = currentTickTime
        CAUIGumpLogicBaseState.CloseWindowCallback = closeWindowCallback
    end
end

local function checkResetConfigWindowCloseTimer_()
    if CAUIGumpLogicBaseState.WindowAutoCloseTime ~= nil and CAUIGumpLogicBaseState.LastConfigWindowOpenTime ~= nil then
        cal.debug("Re-setting timer to close config window...")
        local currentTickTime = cat.getCurrentTime()
        CAUIGumpLogicBaseState.LastConfigWindowOpenTime = currentTickTime
    end
end

local function checkAndCloseOpenConfigWindow_()
    if CAUIGumpLogicBaseState.WindowAutoCloseTime == nil or CAUIGumpLogicBaseState.LastConfigWindowOpenTime == nil then
        return
    end
    local currentTickTime = cat.getCurrentTime()
    if not cat.exceedsDuration(CAUIGumpLogicBaseState.LastConfigWindowOpenTime, currentTickTime, CAUIGumpLogicBaseState.WindowAutoCloseTime) then
        cal.debug("Close window timmer running...")
        return
    end
    cal.debug("Timer expired: closing config window...")
    CAUIGumpLogicBaseState.CloseWindowCallback()
    clearConfigWindowCloseState_()
end

local function setLabelColor_(label, colorOption)
    local colorValues = ColorValues[colorOption]
    label:SetColor(colorValues[1], colorValues[2], colorValues[3], colorValues[4])
end

local function logButtonPressEvent_(buttonEventLogStr, currentStateStr, newStateStr)
    cal.debug(buttonEventLogStr..' button pressed: '..currentStateStr..' -> '..newStateStr)
end

local function updateConfigWindowPosition_(configW)
    local currentWindowX = configW.x
    local currentWindowY = configW.y
    cal.info('Window surrent position: ('..currentWindowX..', '..currentWindowY..')')
    if CAUIGumpLogicBaseState.LastWindowPosition.X ~= currentWindowX and CAUIGumpLogicBaseState.LastWindowPosition.Y ~= currentWindowY then
        cal.info('Updating window position')
        configW:SetPosition(currentWindowX, currentWindowY)
    end
    CAUIGumpLogicBaseState.LastWindowPosition.X = currentWindowX
    CAUIGumpLogicBaseState.LastWindowPosition.Y = currentWindowY
end

local function onConfigMenuButtonPressed_(currentState, configB, configW, buttonEventLogStr, closeOtherCWs, closeWindowCallback, configBClosedStr, configBOpenStr)
    local newState = not currentState
    logButtonPressEvent_(buttonEventLogStr, tostring(currentState), tostring(newState))
    if newState then
        --- Closing the currently openned config window
        configB:SetText(configBClosedStr or '+')
        configW:Hide()
        if closeOtherCWs then
            clearConfigWindowCloseState_()
        end
    else
        --- Openning a config window
        if closeOtherCWs then
            for _, closeFunction in ipairs(CAUIGumpLogicBaseState.SharedVisibilityConfigWindowsCloseFunctions) do
                closeFunction()
            end
        end
        configB:SetText(configBOpenStr or '-')
        configW:Show()
        setConfigWindowCloseState_(closeWindowCallback)
    end
    ---updateConfigWindowPosition_(configW)
    return newState
end

local function onEnumStateButtonPressed_(currentState, lastValue, enumStrings, button, buttonEventLogStr)
    local newState  = (currentState == lastValue and 1) or currentState+1
    logButtonPressEvent_(buttonEventLogStr, enumStrings[currentState], enumStrings[newState])
    button:SetText(enumStrings[newState])
    checkResetConfigWindowCloseTimer_()
    return newState
end

local function onLabeledBooleanButtonPressed_(currentState, label, buttonEventLogStr, trueStateVals, falseStateVals)
    local newState = not currentState
    logButtonPressEvent_(buttonEventLogStr, tostring(currentState), tostring(newState))
    local text = (newState and trueStateVals[1]) or falseStateVals[1]
    local colorOption = (newState and trueStateVals[2]) or falseStateVals[2]
    label:SetText(text)
    setLabelColor_(label, colorOption)
    checkResetConfigWindowCloseTimer_()
    return newState
end

local function onEnabledDisabledButtonPressed_(currentState, label, buttonEventLogStr)
    return onLabeledBooleanButtonPressed_(currentState, label, buttonEventLogStr, { 'Enabled', ColorOptions.Green }, { 'Disabled', ColorOptions.Red })
end

local function getBoonleanButtonStateDisplayStr_(state, buttonDescriptionStr)
    return buttonDescriptionStr .. ((state and ' (Y)') or ' (N)')
end

local function onBooleanButtonPressed_(currentState, button, buttonDescriptionStr, forced, buttonEventLogStr)
    local newState = not currentState
    logButtonPressEvent_(buttonEventLogStr or buttonDescriptionStr, tostring(currentState), tostring(newState))
    local text = getBoonleanButtonStateDisplayStr_(newState, buttonDescriptionStr)
    button:SetText(text)
    if not forced then
        checkResetConfigWindowCloseTimer_()
    end
    return newState
end

--------------
--- Export ---
--------------

local Obj = {
    getColorOptions = getColorOptions_,
    registerSharedVisibilityConfigWindowsCloseFunction = registerSharedVisibilityConfigWindowsCloseFunction_,
    setWindowAutoCloseTime = setWindowAutoCloseTime_,
    checkAndCloseOpenConfigWindow = checkAndCloseOpenConfigWindow_,
    setLabelColor = setLabelColor_,
    onConfigMenuButtonPressed = onConfigMenuButtonPressed_,
    onEnumStateButtonPressed = onEnumStateButtonPressed_,
    onLabeledBooleanButtonPressed = onLabeledBooleanButtonPressed_,
    onEnabledDisabledButtonPressed = onEnabledDisabledButtonPressed_,
    getBoonleanButtonStateDisplayStr = getBoonleanButtonStateDisplayStr_,
    onBooleanButtonPressed = onBooleanButtonPressed_
}

return Obj