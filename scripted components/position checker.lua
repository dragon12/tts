self.setName("The Position Checker")
self.setDescription("Use this checker to find the cordinates on the table")

button_parameters = {}
button_parameters.click_function = 'Check_Possition'
button_parameters.function_owner = self
button_parameters.label = 'Check'
button_parameters.position = {0,0.23,0}
button_parameters.rotation = {0,0,0}
button_parameters.width = 500
button_parameters.height = 500
button_parameters.font_size = 100

self.createButton(button_parameters)

function Check_Position()
    pos = self.getPosition()
    print("The current position of this checker is:\nX: "..pos[1]..",\nY: "..pos[2]..",\nZ: "..pos[3]..".")
end
