----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Logic Base
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: Base functions for handling UI logic
----------------------------------------------------------------------

local cal = Import('CALog')

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

-----------------
--- Functions ---
-----------------

local function getColorOptions_()
    return ColorOptions
end

local function setLabelColor_(label, colorOption)
    local colorValues = ColorValues[colorOption]
    label:SetColor(colorValues[1], colorValues[2], colorValues[3], colorValues[4])
end

local function logButtonPressEvent_(buttonEventLogStr, currentStateStr, newStateStr)
    cal.debug(buttonEventLogStr..' button pressed: '..currentStateStr..' -> '..newStateStr)
end

local function onConfigMenuButtonPressed_(currentState, configB, configW, buttonEventLogStr, configBClosedStr, configBOpenStr)
    local newState = not currentState
    logButtonPressEvent_(buttonEventLogStr, tostring(currentState), tostring(newState))
    if newState then
        configB:SetText(configBClosedStr or '+')
        configW:Hide()
    else
        configB:SetText(configBOpenStr or '-')
        configW:Show()
    end
    return newState
end

local function onEnumStateButtonPressed_(currentState, lastValue, enumStrings, button, buttonEventLogStr)
    local newState  = (currentState == lastValue and 1) or currentState+1
    logButtonPressEvent_(buttonEventLogStr, enumStrings[currentState], enumStrings[newState])
    button:SetText(enumStrings[newState])
    return newState
end

local function onLabeledBooleanButtonPressed_(currentState, label, buttonEventLogStr, trueStateVals, falseStateVals)
    local newState = not currentState
    logButtonPressEvent_(buttonEventLogStr, tostring(currentState), tostring(newState))
    local text = (newState and trueStateVals[1]) or falseStateVals[1]
    local colorOption = (newState and trueStateVals[2]) or falseStateVals[2]
    label:SetText(text)
    setLabelColor_(label, colorOption)
    return newState
end

local function onEnabledDisabledButtonPressed_(currentState, label, buttonEventLogStr)
    return onLabeledBooleanButtonPressed_(currentState, label, buttonEventLogStr, { 'Enabled', ColorOptions.Green }, { 'Disabled', ColorOptions.Red })
end

local function getBoonleanButtonStateDisplayStr_(state, buttonDescriptionStr)
    return buttonDescriptionStr .. ((state and ' (Y)') or ' (N)')
end

local function onBooleanButtonPressed_(currentState, button, buttonDescriptionStr, buttonEventLogStr)
    local newState = not currentState
    logButtonPressEvent_(buttonEventLogStr or buttonDescriptionStr, tostring(currentState), tostring(newState))
    local text = getBoonleanButtonStateDisplayStr_(newState, buttonDescriptionStr)
    button:SetText(text)
    return newState
end

--------------
--- Export ---
--------------

local Obj = {
    getColorOptions = getColorOptions_,
    setLabelColor = setLabelColor_,
    onConfigMenuButtonPressed = onConfigMenuButtonPressed_,
    onEnumStateButtonPressed = onEnumStateButtonPressed_,
    onLabeledBooleanButtonPressed = onLabeledBooleanButtonPressed_,
    onEnabledDisabledButtonPressed = onEnabledDisabledButtonPressed_,
    getBoonleanButtonStateDisplayStr = getBoonleanButtonStateDisplayStr_,
    onBooleanButtonPressed = onBooleanButtonPressed_
}

return Obj