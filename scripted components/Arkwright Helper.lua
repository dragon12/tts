
characterLimit = 14
importerIndex = 5

function onload(saved_data)
    players = {}
    createButton(buttons.initPlayer)
end

function printAllButtons()
    allButtons = self.getButtons()

    for i, t in pairs(allButtons) do
        print ("button, i=",i,", t=", t)
        for k,v in pairs(t) do
            print("    k=", k, ", v=", v)
        end
    end
end

function addSubtractAppeal1(_obj, _color, _alt)
    addSubtractAppeal(_obj, _color, _alt, 1)
end

function addSubtractAppeal2(_obj, _color, _alt)
    addSubtractAppeal(_obj, _color, _alt, 2)
end

function addSubtractAppeal3(_obj, _color, _alt)
    addSubtractAppeal(_obj, _color, _alt, 3)
end

function addSubtractAppeal4(_obj, _color, _alt)
    addSubtractAppeal(_obj, _color, _alt, 4)
end

function addSubtractAppeal5(_obj, _color, _alt)
    -- special case for importer, keep both in sync
    addSubtractAppeal(_obj, _color, _alt, 5)
    addSubtractGoods(_obj, _color, _alt, 5)
end

function addSubtractAppeal(_obj, _color, _alt, playerIndex)
    relevantButton = playerAppealButtons[playerIndex]
    addSubtractButton(_obj, _color, _alt, relevantButton)
end

function addSubtractGoods1(_obj, _color, _alt)
    addSubtractGoods(_obj, _color, _alt, 1)
end

function addSubtractGoods2(_obj, _color, _alt)
    addSubtractGoods(_obj, _color, _alt, 2)
end

function addSubtractGoods3(_obj, _color, _alt)
    addSubtractGoods(_obj, _color, _alt, 3)
end

function addSubtractGoods4(_obj, _color, _alt)
    addSubtractGoods(_obj, _color, _alt, 4)
end

function addSubtractGoods5(_obj, _color, _alt)
    -- special case for the importer - if we click one we click the other
    addSubtractAppeal(_obj, _color, _alt, 5)
    addSubtractGoods(_obj, _color, _alt, 5)
end

function addSubtractGoods(_obj, _color, _alt, playerIndex)
    relevantButton = playerGoodsButtons[playerIndex]
    addSubtractButton(_obj, _color, _alt, relevantButton)
end

function addSubtractDemand(_obj, _color, _alt)
    relevantButton = buttons.demand
    addSubtractButton(_obj, _color, _alt, relevantButton)
end

function addSubtractButton(_obj, _color, _alt, button)
    mod = _alt and -1 or 1
    newValue = tonumber(relevantButton.label) + mod
    newValue = math.max(0, newValue)
    relevantButton.label = tostring(newValue)
    _obj.editButton({index=relevantButton.index,label=relevantButton.label})
end

seatedColors = {}

function initHelper(obj, color)
    obj.removeButton(buttons.initPlayer.index)

    currIndex=0

    -- spawn each row of player buttons
    seatedColors = getSeatedPlayers()
    --seatedColors = {'White', 'Purple', 'Blue', 'Green'} -- For debugging, fakes players at table

    if #seatedColors == 0 then
        printToAll('Players must be seated in order for this tool to be used.', {1,0.5,0.5})
        return
    end

    for index, playerColor in pairs(seatedColors) do
        players[index] = {
            color = playerColor,
            name = string.sub(getPlayerName(playerColor), 1, characterLimit)
        }
    end

    createPlayerRows()

    -- and create the final two rows
    createImporterRow()
    createDistributeRow()
end

function createPlayerRows()
    for i, v in pairs(players) do
        playerNameButtons[i].label = v.name
        createButton(playerNameButtons[i])
        createButton(playerAppealButtons[i])
        createButton(playerGoodsButtons[i])
        createButton(playerResultsButtons[i])
    end
end

function createImporterRow()
    createButton(playerNameButtons[5])
    createButton(playerAppealButtons[5])
    createButton(playerGoodsButtons[5])
    createButton(playerResultsButtons[5])
end

function createDistributeRow()
    createButton(buttons.reset)
    createButton(buttons.demandLabel)
    createButton(buttons.demand)
    createButton(buttons.distribute)
end


function getPlayerName(color)
    playerName = Player[color].steam_name
    if playerName == nil then
        return color
    else
        return playerName
    end
end

currIndex = 0

function createButton(params)
    params.index = currIndex
    params.created = true
    self.createButton(params)
    currIndex = currIndex + 1
    return params.index
end

function noop()
end

function resetCounters()

    function doReset(button)
        button.label = button.defaultLabel
        self.editButton({index = button.index, label=button.label})
    end

    for _, button in pairs(playerAppealButtons) do
        if button.created then
            doReset(button)
        end
    end

    for _, button in pairs(playerGoodsButtons) do
        if button.created then
            doReset(button)
        end
    end

    for _, button in pairs(playerResultsButtons) do
        if button.created then
            doReset(button)
        end
    end

    doReset(buttons.demand)
end

-- where the magic happens
function distribute()
    -- seatedColors are the players we're going to allocate for
    -- the labels on playerAppealButtons and playerGoodsButtons tell us the value for each player
    function getPlayerDetails(i)
        local appeal = tonumber(playerAppealButtons[i].label)
        local goods = tonumber(playerGoodsButtons[i].label)
        local importer = false
        if i == importerIndex then
            importer=true
        end
        return {playerIndex=i, appeal=appeal, goods=goods, allocatedGoods=0, isImporter=importer}
    end

    -- create playerDetails elements - playerIndex, appeal, goods
    local playerDetails = {}
    for index, playerColor in pairs(seatedColors) do
        table.insert(playerDetails, getPlayerDetails(index))
    end
    -- and the importer
    table.insert(playerDetails, getPlayerDetails(importerIndex))

    local maxAppeal = 0
    local totalGoodsRemaining = 0;
    local remainingDemand = tonumber(buttons.demand.label)

    for _, details in pairs(playerDetails) do
        maxAppeal = math.max(maxAppeal, details.appeal)
        totalGoodsRemaining = totalGoodsRemaining + details.goods
    end

    --print("maxAppeal=",maxAppeal,", totalGoods=",totalGoodsRemaining, ", remainingDemand=", remainingDemand)

    function sortByAppealDescendingImporterLast(a, b)
        if a.isImporter then return false end
        if b.isImporter then return true end
        return b.appeal < a.appeal
    end

    table.sort(playerDetails, sortByAppealDescendingImporterLast)

    for _, details in pairs(playerDetails) do
        --print("playerIndex=",details.playerIndex,", appeal=",details.appeal, "goods=", details.goods)
    end

    local currentAppeal = maxAppeal

    local allocatedThisRound = {}
    local overAllocated = 0

    while( totalGoodsRemaining > 0 and remainingDemand > 0 and currentAppeal > 0 ) do

        allocatedThisRound = {}
        lastAllocatedPlayerAppeal = 0

        --print(string.format(" Evaluating appeal level %d, goods remaining %d, demand remaining %d", currentAppeal, totalGoodsRemaining, remainingDemand ))

        -- evaluating this round - we give goods to all players with remaining to get on this level
        -- if we're in an overallocation scenario the importer doesn't get one
        for sortedIndex, details in pairs(playerDetails) do

            --print(string.format("checking player %d with appeal %d, lastAllocatedPlayerAppeal %d",
                    --details.playerIndex, details.appeal, lastAllocatedPlayerAppeal))

            -- this is to keep track of who has received potential overallocations
            if lastAllocatedPlayerAppeal != 0 and lastAllocatedPlayerAppeal != details.appeal then
                if overAllocated > 0 then
                    --print("moved to next appeal level, overallocated, breaking out")
                    break
                end
                allocatedThisRound = {}
            end

            -- shortcut
            if totalGoodsRemaining == 0 then
                --print("no goods remaining")
                break
            end

            -- not elegible; we have to keep processing because the importer is at the end, though
            if details.appeal < currentAppeal then
                --print(" skipping, appeal ", details.appeal, " less than currentAppeal ", currentAppeal)
            elseif details.allocatedGoods == details.appeal or details.goods == 0 then
                --print(" skipping, max goods allocated")
            else
                -- if remainingDemand is 0 we carry on allocating only if this player's appeal is the same as the last allocated
                if remainingDemand == 0 and lastAllocatedPlayerAppeal != details.appeal then
                    --print("Stopping allocation, no remaining demand and this player has worse appeal than before(", details.appeal, "!= ", lastAllocatedPlayerAppeal,")")
                    break
                end

                --print("Allocating good to player ", details.playerIndex)
                lastAllocatedPlayerAppeal = details.appeal
                allocatedThisRound[details.playerIndex] = sortedIndex

                details.allocatedGoods = details.allocatedGoods + 1
                details.goods = details.goods - 1
                totalGoodsRemaining = totalGoodsRemaining - 1

                if remainingDemand == 0 then
                    -- this must be the final round of allocation; allocate to all on this demand level, with an asterisk
                    --print(" (this is an overallocation)")
                    overAllocated = overAllocated + 1
                else
                    remainingDemand = remainingDemand - 1
                end
            end
        end

        currentAppeal = currentAppeal - 1
    end

    -- handle the importer
    if overAllocated > 0 and allocatedThisRound[importerIndex] ~= nil then
        overAllocated = overAllocated - 1

        local sortedIndex = allocatedThisRound[importerIndex];
        playerDetails[sortedIndex].allocatedGoods = playerDetails[sortedIndex].allocatedGoods - 1
        allocatedThisRound[importerIndex] = nil
        --print("Tie break: removed one from importer")
    end

    -- now iterate the details and set the results
    if overAllocated > 0 then
        --print("we have overallocated by ", overAllocated, " goods")
    end

    for _, details in pairs(playerDetails) do
        idx = details.playerIndex

        result = details.allocatedGoods
        if overAllocated > 0 and allocatedThisRound[idx] ~= nil then
            result = result..'*'
        end

        resultsButton = playerResultsButtons[idx]
        resultsButton.label = result

        self.editButton({index=resultsButton.index, label=resultsButton.label})
    end

end


-- this affects the required spacing
fontSize = 70

resultsColor={r=1,b=0,g=0}

counterButtonWidth=200
counterButtonHeigth=200


-- rows are evenly spaced
row1CoordZ = -0.8
rowCoordZDelta = 0.35
buttonZScale = 1

-- how high do all the buttons have to be
buttonYCoord = 0.2

-- cols are not evenly spaced
colCoordsX = {
    -1.5,
    -0.3,
    0.7,
    1.7
}

demandRowCoordsX = {
    -0.3,
    0.3
}

distributeRowCoordsX = {
    colCoordsX[1],
    0
}

rowCoordsZ = {
    row1CoordZ,
    row1CoordZ + (rowCoordZDelta * 1),
    row1CoordZ + (rowCoordZDelta * 2),
    row1CoordZ + (rowCoordZDelta * 3),
    row1CoordZ + (rowCoordZDelta * 4),
    row1CoordZ + (rowCoordZDelta * 5),
    row1CoordZ + (rowCoordZDelta * 6),
}

nameCoords = {
    {colCoordsX[1], buttonYCoord, rowCoordsZ[1]},
    {colCoordsX[1], buttonYCoord, rowCoordsZ[2]},
    {colCoordsX[1], buttonYCoord, rowCoordsZ[3]},
    {colCoordsX[1], buttonYCoord, rowCoordsZ[4]},
    {colCoordsX[1], buttonYCoord, rowCoordsZ[5]},
    {colCoordsX[1], buttonYCoord, rowCoordsZ[6]},
}

appealCoords = {
    {colCoordsX[2], buttonYCoord, rowCoordsZ[1]},
    {colCoordsX[2], buttonYCoord, rowCoordsZ[2]},
    {colCoordsX[2], buttonYCoord, rowCoordsZ[3]},
    {colCoordsX[2], buttonYCoord, rowCoordsZ[4]},
    {colCoordsX[2], buttonYCoord, rowCoordsZ[5]},
    {colCoordsX[2], buttonYCoord, rowCoordsZ[6]},
}

goodsCoords = {
    {colCoordsX[3], buttonYCoord, rowCoordsZ[1]},
    {colCoordsX[3], buttonYCoord, rowCoordsZ[2]},
    {colCoordsX[3], buttonYCoord, rowCoordsZ[3]},
    {colCoordsX[3], buttonYCoord, rowCoordsZ[4]},
    {colCoordsX[3], buttonYCoord, rowCoordsZ[5]},
}

resultsCoords = {
    {colCoordsX[4], buttonYCoord, rowCoordsZ[1]},
    {colCoordsX[4], buttonYCoord, rowCoordsZ[2]},
    {colCoordsX[4], buttonYCoord, rowCoordsZ[3]},
    {colCoordsX[4], buttonYCoord, rowCoordsZ[4]},
    {colCoordsX[4], buttonYCoord, rowCoordsZ[5]},
}

buttons = {
    initPlayer = {
        label='Click Once Seated\nto populate players',
        click_function='initHelper', function_owner=self,
        position={0,0.3,0}, width=500, height=500, font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    demandLabel = {
        label='Demand',
        click_function='noop', function_owner=self,
        position={demandRowCoordsX[1],buttonYCoord,rowCoordsZ[6]}, width=0, height=0, font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    demand = {
        label='0',
        defaultLabel='0',
        click_function='addSubtractDemand', function_owner=self,
        position={demandRowCoordsX[2],buttonYCoord,rowCoordsZ[6]},
        width=counterButtonWidth, height=counterButtonHeight, font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    reset = {
        label='Reset',
        click_function='resetCounters', function_owner=self,
        position={distributeRowCoordsX[1],buttonYCoord,rowCoordsZ[7]}, width=300, height=150, font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    distribute = {
        label='Distribute!',
        click_function='distribute', function_owner=self,
        position={distributeRowCoordsX[2],buttonYCoord,rowCoordsZ[7]}, width=400, height=150,
        font_size=fontSize, font_color={b=0,r=1,g=1},
        color={b=1,r=0,g=0},
        scale={1,1,buttonZScale}
    },
}

playerNameButtons = {
    {
        created=false,
        label='',
        click_function='noop', function_owner=self,
        position=nameCoords[1], width=0, height=0, font_size=fontSize -- width/height=0 means it appears non-interactive
    },
    {
        created=false,
        label='',
        click_function='noop', function_owner=self,
        position=nameCoords[2], width=0, height=0, font_size=fontSize -- width/height=0 means it appears non-interactive
    },
    {
        created=false,
        label='',
        click_function='noop', function_owner=self,
        position=nameCoords[3], width=0, height=0, font_size=fontSize -- width/height=0 means it appears non-interactive
    },
    {
        created=false,
        label='',
        click_function='noop', function_owner=self,
        position=nameCoords[4], width=0, height=0, font_size=fontSize -- width/height=0 means it appears non-interactive
    },
    {
        label='Importer',
        click_function='noop', function_owner=self,
        position=nameCoords[5], width=0, height=0, font_size=fontSize -- width/height=0 means it appears non-interactive
    },
}

playerAppealButtons = {
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractAppeal1', function_owner=self,
        position=appealCoords[1], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractAppeal2', function_owner=self,
        position=appealCoords[2], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractAppeal3', function_owner=self,
        position=appealCoords[3], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractAppeal4', function_owner=self,
        position=appealCoords[4], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractAppeal5', function_owner=self,
        position=appealCoords[5], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    }
}

playerGoodsButtons = {
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractGoods1', function_owner=self,
        position=goodsCoords[1], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractGoods2', function_owner=self,
        position=goodsCoords[2], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractGoods3', function_owner=self,
        position=goodsCoords[3], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractGoods4', function_owner=self,
        position=goodsCoords[4], width=counterButtonWidth, height=counterButtonHeight,
        font_size=fontSize,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='0',
        defaultLabel='0',
        click_function='addSubtractGoods5', function_owner=self,
        position=goodsCoords[5], width=0, height=0, -- importer, don't display the goods as editable
        font_size=fontSize,
        scale={1,1,buttonZScale}
    }
}

playerResultsButtons = {
    {
        created=false,
        label='',
        defaultLabel='',
        click_function='noop', function_owner=self,
        position=resultsCoords[1], width=0, height=0,
        font_size=fontSize,
        font_color=resultsColor,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='',
        defaultLabel='',
        click_function='noop', function_owner=self,
        position=resultsCoords[2], width=0, height=0,
        font_size=fontSize,
        font_color=resultsColor,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='',
        defaultLabel='',
        click_function='noop', function_owner=self,
        position=resultsCoords[3], width=0, height=0,
        font_size=fontSize,
        font_color=resultsColor,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        label='',
        defaultLabel='',
        click_function='noop', function_owner=self,
        position=resultsCoords[4], width=0, height=0,
        font_size=fontSize,
        font_color=resultsColor,
        scale={1,1,buttonZScale}
    },
    {
        created=false,
        defaultLabel='',
        label='',
        click_function='noop', function_owner=self,
        position=resultsCoords[5], width=0, height=0,
        font_size=fontSize,
        font_color=resultsColor,
        scale={1,1,buttonZScale}
    }
}
