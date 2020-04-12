
--[[   The Bank - Scripted Bank by MrStump   ]]--

--Changes the starting dollar amounts for when tool is initialized.
startingValue = 0
--Changes maximum character count for names
characterLimit = 14

--Save function, preservies "players" table, which contains color/name/$value
function onSave()
    if players then
        if #players != 0 then
            local data_to_save = players
            saved_data = JSON.encode(data_to_save)
            return saved_data
        end
    end
end

--Runs on loading
function onload(saved_data)
    --Set default values
    selectTo = 0
    selectFrom = 0

    --This decodes saved_data if it exists to a table name loaded_data
    if saved_data != nil then
        loaded_data = JSON.decode(saved_data)
    else
        loaded_data = nil
    end

    --Starts up, for if there is save data or if there is not
    if loaded_data == nil then
        players = {}
        createKeypadButtons()
    else
        players = loaded_data
        selectFrom = 0
        selectTo = 0
        buttonParameters.bfrom.label = 'FROM:\nBANK'
        buttonParameters.bto.label = 'TO:\nBANK'
        buttonParameters.bdisplay.label = 'TRANSFER:\n'
        createKeypadButtons()
        createPlayerButtons()
    end
end

--Triggers when Transfer display is clicked. Also the "initialize" button
function bpdisplay(o,c)
    local checkForNumbers = string.match(buttonParameters.bdisplay.label,"%d+")
    if #players == 0 then
        initializePlayers()
    elseif checkForNumbers != nil and selectTo != -1 and selectFrom != -1 and selectTo != selectFrom then
        transferFunds(c)
        bpclear()
    end
end

--Spawns keypad/transfer/to/from
function createKeypadButtons()
    for i, v in pairs(buttonParameters) do
        self.createButton(v)
    end
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

--Activates to get players, starting values, etc. Only done once.
--Not used if players already exists from the save function
function initializePlayers()
    log(getSeatedPlayers(), "players")
    local seatedColors = getSeatedPlayers()
    --seatedColors = {'White', 'Purple', 'Blue', 'Green', 'Red', 'Yellow', 'Brown', 'Pink'} -- For debugging, fakes players at table
    if #seatedColors == 0 then
        printToAll('Players must be seated in order for this tool to be used.', {1,0.5,0.5})
    else
        for i, v in pairs(seatedColors) do
            print ("player ", i, "=",v)
            players[i] = {
                color = v,
                name = string.sub(getPlayerName(v), 1, characterLimit),
                value = startingValue
            }
            if i == 6 then
                break
            end
        end
        buttonParameters.bdisplay.label = 'TRANSFER:\n'
        self.editButton(buttonParameters.bdisplay)
        createPlayerButtons()
    end
end

--Makes buttons with names and amounts
function createPlayerButtons()
    if #players != 0 then
        for i, v in pairs(players) do
            paramPlayers[i].label = v.name
            paramValues[i].label = tostring(v.value)
            self.createButton(paramPlayers[i])
            self.createButton(paramValues[i])
        end
    end
end

--Clicked to select who money comes from
function bpfrom()
    if selectTo != -1 and #players != 0 then
        selectFrom = -1
        buttonParameters.bfrom.label = 'SELECT WHO FROM'
        self.editButton(buttonParameters.bfrom)
    end
end

--Clicked to select who money goes to
function bpto()
    if selectFrom != -1 and #players != 0 then
        selectTo = -1
        buttonParameters.bto.label = 'SELECT WHO TO'
        self.editButton(buttonParameters.bto)
    end
end

--Clears all current stats without deleting players table or values
function bpclear()
    if #players != 0 then
        selectFrom = 0
        selectTo = 0
        buttonParameters.bfrom.label = 'FROM:\nBANK'
        buttonParameters.bto.label = 'TO:\nBANK'
        buttonParameters.bdisplay.label = 'TRANSFER:\n'
        self.editButton(buttonParameters.bfrom)
        self.editButton(buttonParameters.bto)
        self.editButton(buttonParameters.bdisplay)
    end
end

--This is because I can't directly pass those numbers from the button presses to nameSelect
function pp1() nameSelect(1) end
function pp2() nameSelect(2) end
function pp3() nameSelect(3) end
function pp4() nameSelect(4) end
function pp5() nameSelect(5) end
function pp6() nameSelect(6) end

--Sets selectFrom or selectTo to indicate which player is selected to move funds with
function nameSelect(selected)
    if selectFrom == -1 then
        selectFrom = selected
        buttonParameters.bfrom.label = 'FROM:\n' .. players[selected].name
        self.editButton(buttonParameters.bfrom)
    elseif selectTo == -1 then
        selectTo = selected
        buttonParameters.bto.label = 'TO:\n' .. players[selected].name
        self.editButton(buttonParameters.bto)
    end
end

--Again, this is because I can't directly pass these numbers from the butotn presses, this time to numberPressed
function bp1() numberPressed('1') end
function bp2() numberPressed('2') end
function bp3() numberPressed('3') end
function bp4() numberPressed('4') end
function bp5() numberPressed('5') end
function bp6() numberPressed('6') end
function bp7() numberPressed('7') end
function bp8() numberPressed('8') end
function bp9() numberPressed('9') end
function bp0() numberPressed('0') end

--Adds #s to Transfer display
function numberPressed(newNum)
    if #players != 0 then
        local currentNum = buttonParameters.bdisplay.label
        buttonParameters.bdisplay.label = currentNum .. newNum
        self.editButton(buttonParameters.bdisplay)
    end
end

--Activated by clicking bdisplay. Xfers money and updates those "screens"
function transferFunds(requestBy)
    local newValue = string.match(buttonParameters.bdisplay.label,"%d+")
    local nameTo = 'BANK'
    local nameFrom = 'BANK'
    --selectFrom is who it is coming from
    --selectTo is who it is going to
    if selectTo != 0 then
        nameTo = players[selectTo].name
        local oldValue = players[selectTo].value
        local totalValue = oldValue + newValue
        players[selectTo].value = totalValue
        paramValues[selectTo].label = tostring(totalValue)
        self.editButton(paramValues[selectTo])
    end
    if selectFrom != 0 then
        nameFrom = players[selectFrom].name
        local oldValue = players[selectFrom].value
        local totalValue = oldValue - newValue
        players[selectFrom].value = totalValue
        paramValues[selectFrom].label = tostring(totalValue)
        self.editButton(paramValues[selectFrom])
    end

    local printString = Player[requestBy].steam_name .. ' transfered $' .. newValue .. ' from ' .. nameFrom .. ' to ' .. nameTo
    printToAll(printString, {0.8,0.8,0.8})
end

--Prints what was transfered


--Launches reset confirmation
function bpreset()
    if #players != 0 then
        for i, v in pairs(paramConfirmation) do
            self.createButton(v)
        end
    end
end

--Resets to starting functionality, to be started up fresh.
function resetConfirmed()
    self.clearButtons()
    selectTo = 0
    selectFrom = 0
    players = {}
    buttonParameters.bdisplay.label = 'Click Once All\nPlayers Are Seated'
    createKeypadButtons()
end

--Deletes the last 3 buttons spawned by bpreset
function resetCanceled()
    local currentButtons = self.getButtons()
    local startCount = #currentButtons - 3
    for i=startCount, #currentButtons do
        self.removeButton(i)
    end
end

--All parameters for button creation, each contained in tables to use in for loops
buttonParameters = {
    bdisplay = {
        index=0, label='Click Once All\nPlayers Are Seated', click_function='bpdisplay', function_owner=self,
        position={-2.2,0.1,-0.2}, width=600, height=200, font_size=60
    },
    bto = {
        index=1, label='TO:\nBANK', click_function='bpto', function_owner=self,
        position={-2,0.1,-1}, width=800, height=200, font_size=60
    },
    bfrom = {
        index=2, label='FROM:\nBANK', click_function='bpfrom', function_owner=self,
        position={-2,0.1,-0.6}, width=800, height=200, font_size=60
    },
    b1 = {
        label='1', click_function='bp1', function_owner=self,
        position={-2.6,0.1,1}, width=200, height=200, font_size=150
    },
    b2 = {
        label='2', click_function='bp2', function_owner=self,
        position={-2.2,0.1,1}, width=200, height=200, font_size=150
    },
    b3 = {
        label='3', click_function='bp3', function_owner=self,
        position={-1.8,0.1,1}, width=200, height=200, font_size=160
    },
    b4 = {
        label='4', click_function='bp4', function_owner=self,
        position={-2.6,0.1,0.6}, width=200, height=200, font_size=160
    },
    b5 = {
        label='5', click_function='bp5', function_owner=self,
        position={-2.2,0.1,0.6}, width=200, height=200, font_size=160
    },
    b6 = {
        label='6', click_function='bp6', function_owner=self,
        position={-1.8,0.1,0.6}, width=200, height=200, font_size=160
    },
    b7 = {
        label='7', click_function='bp7', function_owner=self,
        position={-2.6,0.1,0.2}, width=200, height=200, font_size=160
    },
    b8 = {
        label='8', click_function='bp8', function_owner=self,
        position={-2.2,0.1,0.2}, width=200, height=200, font_size=160
    },
    b9 = {
        label='9', click_function='bp9', function_owner=self,
        position={-1.8,0.1,0.2}, width=200, height=200, font_size=160
    },
    b0 = {
        label='0', click_function='bp0', function_owner=self,
        position={-1.4,0.1,0.8}, width=200, height=395, font_size=160
    },
    bclear = {
        label='CLR', click_function='bpclear', function_owner=self,
        position={-1.4,0.1,-0.2}, width=200, height=200, font_size=90
    },
    breset = {
        label='RESET\nALL', click_function='bpreset', function_owner=self,
        position={-1.4,0.1,0.2}, width=200, height=200, font_size=50
    }
}

paramPlayers = {
    {
        index=15, label='', click_function='pp1', function_owner=self,
        position={0.4,0.1,-1}, width=1500, height=200, font_size=130
    },
    {
        index=17, label='', click_function='pp2', function_owner=self,
        position={0.4,0.1,-0.6}, width=1500, height=200, font_size=130
    },
    {
        index=19, label='', click_function='pp3', function_owner=self,
        position={0.4,0.1,-0.2}, width=1500, height=200, font_size=130
    },
    {
        index=21, label='', click_function='pp4', function_owner=self,
        position={0.4,0.1,0.2}, width=1500, height=200, font_size=130
    },
    {
        index=23, label='', click_function='pp5', function_owner=self,
        position={0.4,0.1,0.6}, width=1500, height=200, font_size=130
    },
    {
        index=25, label='', click_function='pp6', function_owner=self,
        position={0.4,0.1,1}, width=1500, height=200, font_size=130
    }
}
paramValues = {
    {
        index=16, label='', click_function='none', function_owner=self,
        position={2.4,0.1,-1}, width=400, height=200, font_size=130
    },
    {
        index=18, label='', click_function='none', function_owner=self,
        position={2.4,0.1,-0.6}, width=400, height=200, font_size=130
    },
    {
        index=20, label='', click_function='none', function_owner=self,
        position={2.4,0.1,-0.2}, width=400, height=200, font_size=130
    },
    {
        index=22, label='', click_function='none', function_owner=self,
        position={2.4,0.1,0.2}, width=400, height=200, font_size=130
    },
    {
        index=24, label='', click_function='none', function_owner=self,
        position={2.4,0.1,0.6}, width=400, height=200, font_size=130
    },
    {
        index=26, label='', click_function='none', function_owner=self,
        position={2.4,0.1,1}, width=400, height=200, font_size=130
    }
}
paramConfirmation = {
    check = {
        label='Reset?', click_function='none', function_owner=self,
        position={-2.3,0.1,1.5}, width=390, height=200, font_size=120
    },
    yes = {
        label='YES', click_function='resetConfirmed', function_owner=self,
        position={-1.7,0.1,1.5}, width=200, height=200, font_size=100
    },
    no = {
        label='NO', click_function='resetCanceled', function_owner=self,
        position={-1.3,0.1,1.5}, width=200, height=200, font_size=100
    }
}
