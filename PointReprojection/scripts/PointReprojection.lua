
--Start of Global Scope---------------------------------------------------------

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 1000

-- Creating viewer
local viewer = View.create()

-- Creating axes' label texts
local fontSize = 25
local textDeco = View.TextDecoration.create()
textDeco:setSize(fontSize)
textDeco:setColor(0, 180, 180)

-- Creating decoration attributes for text and graphics
local lineWidth = 5

local decoX = View.ShapeDecoration.create()
decoX:setLineWidth(lineWidth)
decoX:setLineColor(255, 0, 0)

local decoY = View.ShapeDecoration.create()
decoY:setLineWidth(lineWidth)
decoY:setLineColor(0, 255, 0)

local decoZ = View.ShapeDecoration.create()
decoZ:setLineColor(0, 0, 255)
decoZ:setPointType('DOT')
decoZ:setPointSize(12)

local decoPoints = View.ShapeDecoration.create()
decoPoints:setLineColor(190, 0, 190)
decoPoints:setPointType('DOT')
decoPoints:setPointSize(12)

local decoText = View.TextDecoration.create()
decoText:setSize(10)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function main()
  -- Load a previously created camera model
  local cameraModel = Object.load('resources/model.json')

  -- Load the calibration image that was used to place the camera
  local checkerBoard = Image.load('resources/pose.bmp')

  -- Finding all checkerboard corner points
  local cornerPoints,
    cornerIndices =
    Image.Calibration.Pattern.detectCheckerboard(checkerBoard, 'THREE_DOT')

  -- Check that the corners are detected properly
  viewer:clear()
  viewer:addImage(checkerBoard)
  viewer:addShape(cornerPoints, decoPoints)
  for i = 1, #cornerIndices do
    local x, y = cornerPoints[i]:getXY()
    local xi, yi = cornerIndices[i]:getXY()
    decoText:setPosition(x, y - 10)
    viewer:addText(string.format('(%d, %d)', xi, yi), decoText)
  end
  viewer:present()
  Script.sleep(DELAY) -- For demonstration purpose only

  -- Specifying the size of a square in the world
  local squareSize = 16.002 -- mm

  -- Defining points in world coordinates for coordinate system graphics
  local axisLengthFactor = 2 -- Length of drawn X and Y axes in number of squares
  local origin = Point.create(0, 0, 0)
  local xAxisEnd = Point.create(squareSize * axisLengthFactor, 0, 0)
  local yAxisEnd = Point.create(0, squareSize * axisLengthFactor, 0)
  local xAxisLabel =
    Point.create(squareSize * axisLengthFactor, -squareSize / 2, 0) -- Position of "X axis label"
  local yAxisLabel =
    Point.create(-squareSize / 2, squareSize * axisLengthFactor, 0) -- Position of "Y axis label"
  local coordSystWorld = {origin, xAxisEnd, yAxisEnd, xAxisLabel, yAxisLabel}

  -- Reprojecting points/axes in original image coordinates
  local coordSystPixels =
    cameraModel:mapPoints(coordSystWorld, 'EXTERNAL_WORLD', 'CAMERA_PIXEL')
  local xAxis = Shape.createLineSegment(coordSystPixels[1], coordSystPixels[2])
  local yAxis = Shape.createLineSegment(coordSystPixels[1], coordSystPixels[3])

  -- Plot origin marker
  viewer:addShape(xAxis, decoX) -- Line from origin to some distance in X
  viewer:addShape(yAxis, decoY) -- Line from origin to some distance in Y
  viewer:addShape(coordSystPixels[1], decoZ) -- Dot in origin to symbolize z axis

  -- Plot origin labels
  textDeco:setPosition(
    coordSystPixels[4]:getX() - fontSize / 2,
    coordSystPixels[4]:getY() + fontSize / 2
  )
  viewer:addText('X', textDeco)
  textDeco:setPosition(
    coordSystPixels[5]:getX() - fontSize / 2,
    coordSystPixels[5]:getY() + fontSize / 2
  )
  viewer:addText('Y', textDeco)

  viewer:present()
  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
