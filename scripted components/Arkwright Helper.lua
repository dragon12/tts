
characterLimit = 14

function onload(saved_data)
    players = {}
    print ("loading")
    print("buttons:", buttons)
    print("initPlayers=", buttons.initPlayer)
    createButton(buttons.initPlayer)
    print ("initButton index=",buttons.initPlayer.index)
end

function printAllPuttons()
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

function addSubtractButton(_obj, _color, _alt, button)
    mod = _alt and -1 or 1
    newValue = tonumber(relevantButton.label) + mod
    relevantButton.label = tostring(newValue)
    _obj.editButton({index=relevantButton.index,label=relevantButton.label})
end

function initHelper(obj, color)
    obj.removeButton(buttons.initPlayer.index)

    currIndex=0

    -- spawn each row of player buttons
    local seatedColors = getSeatedPlayers()
    seatedColors = {'White', 'Purple', 'Blue', 'Green'} -- For debugging, fakes players at table

    if #seatedColors == 0 then
        printToAll('Players must be seated in order for this tool to be used.', {1,0.5,0.5})
        return
    end

    print("allocating for ",#seatedColors, " players")
    for index, playerColor in pairs(seatedColors) do
        print("player ", index, "=",playerColor)

        players[index] = {
            color = playerColor,
            --name = string.sub(getPlayerName(playerColor), 1, characterLimit)
            name = getPlayerName(playerColor)
        }
    end
    createPlayerRows()

    -- and create the final two rows
    createImporterRow()
    createDistributeRow()
end

function createPlayerRows()
    print ("creating playerNameButton: ",playerNameButtons[1])

    for i, v in pairs(players) do
        playerNameButtons[i].label = v.name
        createButton(playerNameButtons[i])
        createButton(playerAppealButtons[i])
        createButton(playerGoodsButtons[i])
    end
end

function createImporterRow()
    print ("creating for importer")

    createButton(playerNameButtons[5])
    createButton(playerAppealButtons[5])
    createButton(playerGoodsButtons[5])
end

function createDistributeRow()
    print("creating for distribute")

    createButton(buttons.distribute)
end


function getPlayerName(color)
    playerName = Player[color].steam_name
    if playerName == nil then
        print ("returning name=",color)
        return color
    else
        print ("returning steam name for ", color)
        return playerName
    end
end

currIndex = 0

function createButton(params)
    params.index = currIndex
    self.createButton(params)
    print("createButton label ",params.label,", index ", params.index)
    currIndex = currIndex + 1
    return params.index
end

function noop()
end

-- rows are evenly spaced
row1CoordZ = -0.4
rowCoordZDelta = 0.3

-- how high do all the buttons have to be
buttonYCoord = 0.3

buttonZScale = 0.75

-- cols are not evenly spaced
colCoordsX = {
    -1.2,
    -0.25,
    0.52,
    1.5
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


buttons = {
    initPlayer = {
        label='Click Once Seated\nto populate players',
        click_function='initHelper', function_owner=self,
        position={0,0.3,0}, width=500, height=500, font_size=50,
        scale={1,1,buttonZScale}
    },
    distribute = {
        label='DISTRIBUTE',
        click_function='distribute', function_owner=self,
        position={0,0.2,-2}, width=500, height=500, font_size=50,
        scale={1,1,buttonZScale}
    },
}

playerNameButtons = {
    {
        label='',
        click_function='noop', function_owner=self,
        position=nameCoords[1], width=0, height=0, font_size=60 -- width/height=0 means it appears non-interactive
    },
    {
        label='',
        click_function='noop', function_owner=self,
        position=nameCoords[2], width=0, height=0, font_size=60 -- width/height=0 means it appears non-interactive
    },
    {
        label='',
        click_function='noop', function_owner=self,
        position=nameCoords[3], width=0, height=0, font_size=60 -- width/height=0 means it appears non-interactive
    },
    {
        label='',
        click_function='noop', function_owner=self,
        position=nameCoords[4], width=0, height=0, font_size=60 -- width/height=0 means it appears non-interactive
    },
    {
        label='Importer',
        click_function='noop', function_owner=self,
        position=nameCoords[5], width=0, height=0, font_size=60 -- width/height=0 means it appears non-interactive
    },
}

appealButtonWidth=200
appealButtonHeigth=200

playerAppealButtons = {
    {
        label='0',
        click_function='addSubtractAppeal1', function_owner=self,
        position=appealCoords[1], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    },
    {
        label='0',
        click_function='addSubtractAppeal2', function_owner=self,
        position=appealCoords[2], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    },
    {
        label='0',
        click_function='addSubtractAppeal3', function_owner=self,
        position=appealCoords[3], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    },
    {
        label='0',
        click_function='addSubtractAppeal4', function_owner=self,
        position=appealCoords[4], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    },
    {
        label='0',
        click_function='addSubtractAppeal5', function_owner=self,
        position=appealCoords[5], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    }
}

playerGoodsButtons = {
    {
        label='0',
        click_function='addSubtractGoods1', function_owner=self,
        position=goodsCoords[1], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    },
    {
        label='0',
        click_function='addSubtractGoods2', function_owner=self,
        position=goodsCoords[2], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    },
    {
        label='0',
        click_function='addSubtractGoods3', function_owner=self,
        position=goodsCoords[3], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    },
    {
        label='0',
        click_function='addSubtractGoods4', function_owner=self,
        position=goodsCoords[4], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    },
    {
        label='0',
        click_function='addSubtractGoods5', function_owner=self,
        position=goodsCoords[5], width=appealButtonWidth, height=appealButtonHeight,
        font_size=60,
        scale={1,1,buttonZScale}
    }
}
