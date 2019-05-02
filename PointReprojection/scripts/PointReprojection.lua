--[[----------------------------------------------------------------------------

  Application Name:
  PointReprojection

  Summary:
  Finding all corner points of checkerboard target and visualizing the X and Y axes

  Description:
  Finding all corner points of a three-dot checkerboard calibration target and
  calibrating the camera using One-Shot calibration method. Reprojecting and visualizing
  the X and Y axes (defined in world units) in the original image.

  How to Run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  To run this sample a device with SICK Algorithm API is necessary.
  For example InspectorP or SIM4000 with latest firmware. Alternatively the
  Emulator on AppStudio 2.2 or higher can be used. The images can be seen in the
  image viewer on the DevicePage.

  More Information:
  Tutorial "Algorithms - Calibration2D".

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

-- Delay in ms between visualization steps for demonstration purpose
local DELAY = 1000

-- Creating viewer
local viewer = View.create()
viewer:setID('viewer2D')

-- Creating axes' label texts
local textDecoX = View.TextDecoration.create()
textDecoX:setSize(25)

local textDecoY = View.TextDecoration.create()
textDecoY:setSize(25)

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

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function main()
  local checkerBoard = Image.load('resources/pose.bmp')
  viewer:view(checkerBoard)
  Script.sleep(DELAY) -- For demonstration purpose only

  -- Specifying the size of a square in the world
  local squareSize = 16.002 -- mm

  -- Performing a one-shot calibration
  local cameraModel, error = Image.Calibration.Pose.estimateOneShot(
    checkerBoard,
    {squareSize},
    'THREE_DOT',
    true,
    false
  )
  print('Camera calibrated with average error: ' ..(math.floor(error * 10)) / 10 .. ' px')

  -- Finding all checkerboard corner points
  local cameraCalib = Image.Calibration.Camera.create()
  cameraCalib:setCheckerSquareSideLength(squareSize)
  local _,
    cornerPoints = cameraCalib:findCornerPoints(checkerBoard)
  viewer:add(cornerPoints, decoZ)

  -- Defining points in world coordinates for coordinate system graphics
  local axisLengthFactor = 2 -- Length of drawn X and Y axes in number of squares
  local origin = Point.create(0, 0, 0)
  local xAxisEnd = Point.create(squareSize * axisLengthFactor, 0, 0)
  local yAxisEnd = Point.create(0, squareSize * axisLengthFactor, 0)
  local xAxisLabel = Point.create(squareSize * axisLengthFactor * 1.1, 0, 0) -- Position of "X axis label"
  local yAxisLabel = Point.create(0, squareSize * axisLengthFactor * 1.1, 0) -- Position of "Y axis label"
  local coordSystWorld = {origin, xAxisEnd, yAxisEnd, xAxisLabel, yAxisLabel}

  -- Reprojecting points/axes in original image coordinates
  local coordSystPixels =
    cameraModel:mapPoints(coordSystWorld, 'EXTERNAL_WORLD', 'CAMERA_PIXEL')

  -- Drawing graphics in image coordinates
  local xAxis = Shape.createLineSegment(coordSystPixels[1], coordSystPixels[2])
  local yAxis = Shape.createLineSegment(coordSystPixels[1], coordSystPixels[3])
  viewer:add(xAxis, decoX)
  viewer:add(yAxis, decoY)
  textDecoX:setPosition(coordSystPixels[4]:getX() - 12, coordSystPixels[4]:getY())
  viewer:add('X', textDecoX)
  textDecoY:setPosition(coordSystPixels[5]:getX(), coordSystPixels[5]:getY() - 12)
  viewer:add('Y', textDecoY)
  viewer:add(coordSystPixels[1], decoZ) -- Dot in origin to symbolize z axis
  viewer:present()
  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
