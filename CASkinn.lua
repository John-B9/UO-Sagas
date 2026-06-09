----------------------------------------------------------------------
--- Combat Assistant (CA) Skinn
--- Author: JohnB9
---
--- Mentions: OmgArturo  - Base script
---
--- Version: 1.0.0  - 
---
--- Description: Auto skinner functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')
local iusci = Import('IUScissors')
local iuski = Import('IUSkinn')

-----------------
--- Variables ---
-----------------

SkinnConfig = {
    Enable = false,
    NoisyMode = true,       --- To Log XOR Say when dropping or keeping a resource
    LeatherHuesToKeep = {
        --- 0x0000,         --- Regular
        --- 0x0973,         --- Dull Copper
        --- 0x0966,         --- Shadow Iron
        --- 0x096D,         --- Copper
        0x0972,             --- Bronze
        0x08A5,             --- Gold
        0x0979,             --- Agapite
        0x089F,             --- Verite
        0x08AB              --- Valorite
    }
}

local SkinnStaticConfig = {
    CorpseFilter = {
        graphics = {0x2006},
        onground = true,
        rangemin = 0,
        rangemax = 2
    },
    CorpsesToSkip = {
        400,            --- Human
        401,            --- Female
    },
    WarningPauseTime = 10000
}

local SkinnState = {
    lastOverHeadTime = 0
}

-----------------
--- Accessors ---
-----------------

local function setEnable_(val)
    SkinnConfig.Enable = val
end

local function setNoisyMode_(val)
    SkinnConfig.NoisyMode = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setNoisyMode_(config.NoisyMode)
    SkinnConfig.LeatherHuesToKeep = config.LeatherHuesToKeep
end

-----------------
--- Functions ---
-----------------

local function announceFoundHide_(hide, keep)
    local msgPrefix = keep and "+ " or "- "
    local msgSufix = keep and " +" or " -"
    if SkinnConfig.NoisyMode then
        Player.Say(msgPrefix .. hide.Name .. msgSufix, 48)
    else
        cal.mainInfo(msgPrefix .. hide.Name .. " " .. msgSufix)
    end
end

local processedCorpses = {}

function HasProcessedCorpse(serial)
    return processedCorpses[serial] == true
end

function MarkCorpseProcessed(serial)
    processedCorpses[serial] = true
end

function skinn_()

    if not SkinnConfig.Enable then
        return
    end

    local corpses = Items.FindByFilter(SkinnStaticConfig.CorpseFilter)
    for _, corpse in ipairs(corpses) do

        local hides = nil
        if HasProcessedCorpse(corpse.Serial) then                                                       --- Already processed?
            cal.debug("Skipping corpse: " .. (corpse.Name or "Unknown") .. "(already processed)")
            goto skip_corpse
        end

        if bl.tableContains(SkinnStaticConfig.CorpsesToSkip, corpse.Amount) then                        --- Skip corpse type?
            cal.debug("Skipping corpse: " .. (corpse.Name or "Unknown"))
            goto skip_corpse
        end
        
        Pause(1.5 * cat.getActionWaitTime())                                                                  --- Pause a bit to let the client catch up
                                                                                                        --- with the new corpse and avoid targeting errors

        if not iuski.useSkinningKnife(nil, false) then                                                                                  --- Skin the corpse
            if cat.exceedsDuration(SkinnState.lastOverHeadTime, cat.getCurrentTickTime(), SkinnStaticConfig.WarningPauseTime) then
                cal.error("Failed to use skinning knife: " .. (corpse.Name or "Unknown") .. "...")
                SkinnState.lastOverHeadTime = cat.getCurrentTickTime()
            end
            goto skip_corpse
        end
        cal.info("Skinning corpse: " .. (corpse.Name or "Unknown"))
        Target.WaitForTarget(0.5 * cat.getActionWaitTime(), false)
        Target.TargetSerial(corpse.Serial)
        Pause(0.5 * cat.getActionWaitTime())

        Player.UseObject(corpse.Serial)                                                                 --- Open the corpse
        Pause(0.5 * cat.getActionWaitTime())

        hides = Items.FindByFilter({                                                                    --- For all hides
            graphics = {0x1079},
            onground = false
        })
        for _, hide in ipairs(hides) do

            if hide.RootContainer ~= Player.Serial then
                goto skip_hide
            end

            local keepHide = bl.tableContains(SkinnConfig.LeatherHuesToKeep, hide.Hue)                  --- Are we keeping these hides?
            if not keepHide then

                announceFoundHide_(hide, false)
                Player.PickUp(hide.Serial, hide.Amount)                                                 --- From inventory to ground
                Player.DropOnGround()
                Pause(0.5 * cat.getActionWaitTime())
            else

                announceFoundHide_(hide, true)
                if not iusci.useScissors(nil, false) then                                                                                   --- Cut the hides
                    if cat.exceedsDuration(SkinnState.lastOverHeadTime, cat.getCurrentTickTime(), SkinnStaticConfig.WarningPauseTime) then
                        cal.error("Failed to use scissors: " .. (corpse.Name or "Unknown") .. "...")
                        SkinnState.lastOverHeadTime = cat.getCurrentTickTime()
                    end
                    goto skip_corpse
                end
                Target.WaitForTarget(3000)
                Target.TargetSerial(hide.Serial)
                Pause(0.5 * cat.getActionWaitTime())
            end

            :: skip_hide ::
        end

        :: skip_corpse ::
        MarkCorpseProcessed(corpse.Serial)                                                              --- Mark corpse processed so it never repeats
    end
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_,
    skinn = skinn_
}

return Obj