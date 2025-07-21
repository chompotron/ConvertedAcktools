-- ============================================================
-- AK ANIMATION KEYS TOOLS 
-- Combined Push, Pull, and Negate Keys 
-- 
-- Credit to Aaron Koressel (www.aaronkoressel.com) for the original melscript tool
-- Ported to 3DS Max by Austin Hardwicke
-- INSTALLATION INSTRUCTIONS:
-- 1)drag and drop *.ms file in 3dsmax viewport or run this script
-- 2. The scripts will be automatically installed in the "Animation Keys" category
-- 3. To access the tools:
--    - Go to Customize > Customize User Interface
--    - Look in the "Animation Keys" category
--    - Drag the tools to your toolbar or assign hotkeys:
--      • "Push Keys Away from Pivot"
--      • "Pull Keys Toward Pivot"
--      • "Negate/Flip Keys Around Pivot"
-- 
-- USAGE:
-- 1. Select an object with animation
-- 2. In the Curve Editor or Dope Sheet, select the keys you want to modify
-- 3. Run the desired tool
-- 
-- FEATURES:
-- - Works with standard controllers and Animation Layers
-- - Processes Position, Rotation, and Scale keys
-- - Uses the key to the left of selection as pivot point
-- - Push/Pull use a 0.9 scale factor (10% change per execution)
-- ============================================================

-- ============================================================
-- PUSH KEYS MACRO
-- ============================================================
macroScript ackPushKeys
category:"Animation Keys"
toolTip:"Push Keys Away from Pivot"
buttonText:"Push Keys"
icon:#("AnimLayerToolbar", 3)
(
    on execute do
    (
        undo label:"Push Keys" on
        (
            -- Shared function for push/pull operations
            fn ackPushPull command pivotMode scaleFactor = (
                local totalKeysProcessed = 0
                
                -- Helper function to process keys
                fn processKeys ctrl ctrlName pivotMode scaleFactor command = (
                    local processed = 0
                    
                    if ctrl != undefined and ctrl.keys != undefined then (
                        -- Get selected key times
                        local keyTimes = #()
                        for i = 1 to ctrl.keys.count do (
                            if ctrl.keys[i].selected then append keyTimes ctrl.keys[i].time
                        )
                        sort keyTimes
                        
                        if keyTimes.count > 0 then (
                            -- Find pivot value
                            local pivotValue = undefined
                            local targetTime = if pivotMode == "left" then keyTimes[1] else keyTimes[keyTimes.count]
                            local bestTime = undefined
                            
                            for i = 1 to ctrl.keys.count do (
                                local keyTime = ctrl.keys[i].time
                                if pivotMode == "left" then (
                                    if keyTime < targetTime and (bestTime == undefined or keyTime > bestTime) then (
                                        bestTime = keyTime
                                        pivotValue = ctrl.keys[i].value
                                    )
                                ) else (
                                    if keyTime > targetTime and (bestTime == undefined or keyTime < bestTime) then (
                                        bestTime = keyTime
                                        pivotValue = ctrl.keys[i].value
                                    )
                                )
                            )
                            
                            -- Scale keys if pivot found
                            if pivotValue != undefined then (
                                local actualScaleFactor = if command == "push" then (1.0 / scaleFactor) else scaleFactor
                                for i = 1 to ctrl.keys.count do (
                                    if ctrl.keys[i].selected then (
                                        local originalValue = ctrl.keys[i].value
                                        ctrl.keys[i].value = pivotValue + (originalValue - pivotValue) * actualScaleFactor
                                        processed += 1
                                    )
                                )
                            )
                        )
                    )
                    
                    processed
                )
                
                for obj in getCurrentSelection() do (
                    -- POSITION CONTROLLER
                    if obj.pos.controller != undefined then (
                        if classOf obj.pos.controller == Position_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.pos.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.pos.controller prop
                                    if layer.controller != undefined then (
                                        -- X Position
                                        try (
                                            totalKeysProcessed += processKeys layer.controller.x_position.controller ("X Pos [" + propName + "]") pivotMode scaleFactor command
                                        ) catch ()
                                        
                                        -- Y Position
                                        try (
                                            totalKeysProcessed += processKeys layer.controller.y_position.controller ("Y Pos [" + propName + "]") pivotMode scaleFactor command
                                        ) catch ()
                                        
                                        -- Z Position
                                        try (
                                            totalKeysProcessed += processKeys layer.controller.z_position.controller ("Z Pos [" + propName + "]") pivotMode scaleFactor command
                                        ) catch ()
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard position controller
                            try (totalKeysProcessed += processKeys obj.pos.controller.x_position.controller "X Pos" pivotMode scaleFactor command) catch ()
                            try (totalKeysProcessed += processKeys obj.pos.controller.y_position.controller "Y Pos" pivotMode scaleFactor command) catch ()
                            try (totalKeysProcessed += processKeys obj.pos.controller.z_position.controller "Z Pos" pivotMode scaleFactor command) catch ()
                        )
                    )
                    
                    -- ROTATION CONTROLLER
                    if obj.rotation.controller != undefined then (
                        if classOf obj.rotation.controller == Rotation_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.rotation.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.rotation.controller prop
                                    if layer.controller != undefined then (
                                        -- For Euler XYZ rotation
                                        if classOf layer.controller == Euler_XYZ then (
                                            -- X Rotation
                                            try (
                                                totalKeysProcessed += processKeys layer.controller.x_rotation.controller ("X Rot [" + propName + "]") pivotMode scaleFactor command
                                            ) catch ()
                                            
                                            -- Y Rotation
                                            try (
                                                totalKeysProcessed += processKeys layer.controller.y_rotation.controller ("Y Rot [" + propName + "]") pivotMode scaleFactor command
                                            ) catch ()
                                            
                                            -- Z Rotation
                                            try (
                                                totalKeysProcessed += processKeys layer.controller.z_rotation.controller ("Z Rot [" + propName + "]") pivotMode scaleFactor command
                                            ) catch ()
                                        )
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard rotation controller
                            if classOf obj.rotation.controller == Euler_XYZ then (
                                try (totalKeysProcessed += processKeys obj.rotation.controller.x_rotation.controller "X Rot" pivotMode scaleFactor command) catch ()
                                try (totalKeysProcessed += processKeys obj.rotation.controller.y_rotation.controller "Y Rot" pivotMode scaleFactor command) catch ()
                                try (totalKeysProcessed += processKeys obj.rotation.controller.z_rotation.controller "Z Rot" pivotMode scaleFactor command) catch ()
                            )
                        )
                    )
                    
                    -- SCALE CONTROLLER
                    if obj.scale.controller != undefined then (
                        if classOf obj.scale.controller == Scale_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.scale.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.scale.controller prop
                                    if layer.controller != undefined then (
                                        totalKeysProcessed += processKeys layer.controller ("Scale [" + propName + "]") pivotMode scaleFactor command
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard scale controller
                            totalKeysProcessed += processKeys obj.scale.controller "Scale" pivotMode scaleFactor command
                        )
                    )
                )
                
                format "Pushed % keys\n" totalKeysProcessed
                return totalKeysProcessed > 0
            )
            
            -- Execute push
            ackPushPull "push" "left" 0.9
        )
    )
)

-- ============================================================
-- PULL KEYS MACRO
-- ============================================================
macroScript ackPullKeys
category:"Animation Keys"
toolTip:"Pull Keys Toward Pivot"
buttonText:"Pull Keys"
icon:#("AnimLayerToolbar", 4)
(
    on execute do
    (
        undo label:"Pull Keys" on
        (
            -- Shared function for push/pull operations
            fn ackPushPull command pivotMode scaleFactor = (
                local totalKeysProcessed = 0
                
                -- Helper function to process keys
                fn processKeys ctrl ctrlName pivotMode scaleFactor command = (
                    local processed = 0
                    
                    if ctrl != undefined and ctrl.keys != undefined then (
                        -- Get selected key times
                        local keyTimes = #()
                        for i = 1 to ctrl.keys.count do (
                            if ctrl.keys[i].selected then append keyTimes ctrl.keys[i].time
                        )
                        sort keyTimes
                        
                        if keyTimes.count > 0 then (
                            -- Find pivot value
                            local pivotValue = undefined
                            local targetTime = if pivotMode == "left" then keyTimes[1] else keyTimes[keyTimes.count]
                            local bestTime = undefined
                            
                            for i = 1 to ctrl.keys.count do (
                                local keyTime = ctrl.keys[i].time
                                if pivotMode == "left" then (
                                    if keyTime < targetTime and (bestTime == undefined or keyTime > bestTime) then (
                                        bestTime = keyTime
                                        pivotValue = ctrl.keys[i].value
                                    )
                                ) else (
                                    if keyTime > targetTime and (bestTime == undefined or keyTime < bestTime) then (
                                        bestTime = keyTime
                                        pivotValue = ctrl.keys[i].value
                                    )
                                )
                            )
                            
                            -- Scale keys if pivot found
                            if pivotValue != undefined then (
                                local actualScaleFactor = if command == "push" then (1.0 / scaleFactor) else scaleFactor
                                for i = 1 to ctrl.keys.count do (
                                    if ctrl.keys[i].selected then (
                                        local originalValue = ctrl.keys[i].value
                                        ctrl.keys[i].value = pivotValue + (originalValue - pivotValue) * actualScaleFactor
                                        processed += 1
                                    )
                                )
                            )
                        )
                    )
                    
                    processed
                )
                
                for obj in getCurrentSelection() do (
                    -- POSITION CONTROLLER
                    if obj.pos.controller != undefined then (
                        if classOf obj.pos.controller == Position_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.pos.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.pos.controller prop
                                    if layer.controller != undefined then (
                                        -- X Position
                                        try (
                                            totalKeysProcessed += processKeys layer.controller.x_position.controller ("X Pos [" + propName + "]") pivotMode scaleFactor command
                                        ) catch ()
                                        
                                        -- Y Position
                                        try (
                                            totalKeysProcessed += processKeys layer.controller.y_position.controller ("Y Pos [" + propName + "]") pivotMode scaleFactor command
                                        ) catch ()
                                        
                                        -- Z Position
                                        try (
                                            totalKeysProcessed += processKeys layer.controller.z_position.controller ("Z Pos [" + propName + "]") pivotMode scaleFactor command
                                        ) catch ()
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard position controller
                            try (totalKeysProcessed += processKeys obj.pos.controller.x_position.controller "X Pos" pivotMode scaleFactor command) catch ()
                            try (totalKeysProcessed += processKeys obj.pos.controller.y_position.controller "Y Pos" pivotMode scaleFactor command) catch ()
                            try (totalKeysProcessed += processKeys obj.pos.controller.z_position.controller "Z Pos" pivotMode scaleFactor command) catch ()
                        )
                    )
                    
                    -- ROTATION CONTROLLER
                    if obj.rotation.controller != undefined then (
                        if classOf obj.rotation.controller == Rotation_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.rotation.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.rotation.controller prop
                                    if layer.controller != undefined then (
                                        -- For Euler XYZ rotation
                                        if classOf layer.controller == Euler_XYZ then (
                                            -- X Rotation
                                            try (
                                                totalKeysProcessed += processKeys layer.controller.x_rotation.controller ("X Rot [" + propName + "]") pivotMode scaleFactor command
                                            ) catch ()
                                            
                                            -- Y Rotation
                                            try (
                                                totalKeysProcessed += processKeys layer.controller.y_rotation.controller ("Y Rot [" + propName + "]") pivotMode scaleFactor command
                                            ) catch ()
                                            
                                            -- Z Rotation
                                            try (
                                                totalKeysProcessed += processKeys layer.controller.z_rotation.controller ("Z Rot [" + propName + "]") pivotMode scaleFactor command
                                            ) catch ()
                                        )
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard rotation controller
                            if classOf obj.rotation.controller == Euler_XYZ then (
                                try (totalKeysProcessed += processKeys obj.rotation.controller.x_rotation.controller "X Rot" pivotMode scaleFactor command) catch ()
                                try (totalKeysProcessed += processKeys obj.rotation.controller.y_rotation.controller "Y Rot" pivotMode scaleFactor command) catch ()
                                try (totalKeysProcessed += processKeys obj.rotation.controller.z_rotation.controller "Z Rot" pivotMode scaleFactor command) catch ()
                            )
                        )
                    )
                    
                    -- SCALE CONTROLLER
                    if obj.scale.controller != undefined then (
                        if classOf obj.scale.controller == Scale_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.scale.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.scale.controller prop
                                    if layer.controller != undefined then (
                                        totalKeysProcessed += processKeys layer.controller ("Scale [" + propName + "]") pivotMode scaleFactor command
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard scale controller
                            totalKeysProcessed += processKeys obj.scale.controller "Scale" pivotMode scaleFactor command
                        )
                    )
                )
                
                format "Pulled % keys\n" totalKeysProcessed
                return totalKeysProcessed > 0
            )
            
            -- Execute pull
            ackPushPull "pull" "left" 0.9
        )
    )
)

-- ============================================================
-- NEGATE/FLIP KEYS MACRO
-- ============================================================
macroScript ackNegateKeys
category:"Animation Keys"
toolTip:"Negate/Flip Keys Around Pivot"
buttonText:"Negate Keys"
icon:#("AnimLayerToolbar", 5)
(
    on execute do
    (
        undo label:"Negate Keys" on
        (
            clearListener()
            
            if selection.count == 0 then (
                messageBox "Please select an object first!"
            ) else (
                local totalFlipped = 0
                local direction = "left"  -- Change to "right" if needed
                
                for obj in selection do (
                    format "\n=== Processing: % ===\n" obj.name
                    
                    -- Helper function to flip keys
                    fn flipKeys ctrl ctrlName flipDirection = (
                        local flipped = 0
                        
                        if ctrl != undefined and ctrl.keys != undefined then (
                            -- Get selected keys
                            local selectedKeys = #()
                            for i = 1 to ctrl.keys.count do (
                                if ctrl.keys[i].selected then (
                                    append selectedKeys i
                                )
                            )
                            
                            if selectedKeys.count > 0 then (
                                format "  %: % keys, % selected\n" ctrlName ctrl.keys.count selectedKeys.count
                                
                                -- Get the time of first/last selected key
                                local targetTime = if flipDirection == "left" then ctrl.keys[selectedKeys[1]].time else ctrl.keys[selectedKeys[selectedKeys.count]].time
                                
                                -- Find pivot
                                local pivotValue = undefined
                                local pivotTime = undefined
                                
                                for i = 1 to ctrl.keys.count do (
                                    local keyTime = ctrl.keys[i].time
                                    if flipDirection == "left" then (
                                        if keyTime < targetTime and (pivotTime == undefined or keyTime > pivotTime) then (
                                            pivotTime = keyTime
                                            pivotValue = ctrl.keys[i].value
                                        )
                                    ) else (
                                        if keyTime > targetTime and (pivotTime == undefined or keyTime < pivotTime) then (
                                            pivotTime = keyTime
                                            pivotValue = ctrl.keys[i].value
                                        )
                                    )
                                )
                                
                                if pivotValue != undefined then (
                                    format "    Pivot: time % value %\n" pivotTime pivotValue
                                    
                                    -- Flip each selected key
                                    for idx in selectedKeys do (
                                        local oldVal = ctrl.keys[idx].value
                                        ctrl.keys[idx].value = 2 * pivotValue - oldVal
                                        flipped += 1
                                    )
                                    format "    Flipped % keys\n" flipped
                                ) else (
                                    format "    No pivot found\n"
                                )
                            )
                        )
                        
                        flipped
                    )
                    
                    -- POSITION CONTROLLER
                    if obj.pos.controller != undefined then (
                        format " Position Controller: %\n" (classOf obj.pos.controller)
                        
                        if classOf obj.pos.controller == Position_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.pos.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.pos.controller prop
                                    if layer.controller != undefined then (
                                        format "  Layer: %\n" propName
                                        
                                        -- X Position
                                        try (
                                            totalFlipped += flipKeys layer.controller.x_position.controller ("X Pos [" + propName + "]") direction
                                        ) catch ()
                                        
                                        -- Y Position
                                        try (
                                            totalFlipped += flipKeys layer.controller.y_position.controller ("Y Pos [" + propName + "]") direction
                                        ) catch ()
                                        
                                        -- Z Position
                                        try (
                                            totalFlipped += flipKeys layer.controller.z_position.controller ("Z Pos [" + propName + "]") direction
                                        ) catch ()
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard position controller
                            try (totalFlipped += flipKeys obj.pos.controller.x_position.controller "X Pos" direction) catch ()
                            try (totalFlipped += flipKeys obj.pos.controller.y_position.controller "Y Pos" direction) catch ()
                            try (totalFlipped += flipKeys obj.pos.controller.z_position.controller "Z Pos" direction) catch ()
                        )
                    )
                    
                    -- ROTATION CONTROLLER
                    if obj.rotation.controller != undefined then (
                        format " Rotation Controller: %\n" (classOf obj.rotation.controller)
                        
                        if classOf obj.rotation.controller == Rotation_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.rotation.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.rotation.controller prop
                                    if layer.controller != undefined then (
                                        format "  Layer: %\n" propName
                                        
                                        -- For Euler XYZ rotation
                                        if classOf layer.controller == Euler_XYZ then (
                                            -- X Rotation
                                            try (
                                                totalFlipped += flipKeys layer.controller.x_rotation.controller ("X Rot [" + propName + "]") direction
                                            ) catch ()
                                            
                                            -- Y Rotation
                                            try (
                                                totalFlipped += flipKeys layer.controller.y_rotation.controller ("Y Rot [" + propName + "]") direction
                                            ) catch ()
                                            
                                            -- Z Rotation
                                            try (
                                                totalFlipped += flipKeys layer.controller.z_rotation.controller ("Z Rot [" + propName + "]") direction
                                            ) catch ()
                                        )
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard rotation controller
                            if classOf obj.rotation.controller == Euler_XYZ then (
                                try (totalFlipped += flipKeys obj.rotation.controller.x_rotation.controller "X Rot" direction) catch ()
                                try (totalFlipped += flipKeys obj.rotation.controller.y_rotation.controller "Y Rot" direction) catch ()
                                try (totalFlipped += flipKeys obj.rotation.controller.z_rotation.controller "Z Rot" direction) catch ()
                            )
                        )
                    )
                    
                    -- SCALE CONTROLLER
                    if obj.scale.controller != undefined then (
                        format " Scale Controller: %\n" (classOf obj.scale.controller)
                        
                        if classOf obj.scale.controller == Scale_Layer then (
                            -- Handle layers
                            local props = getPropNames obj.scale.controller
                            
                            for prop in props do (
                                local propName = prop as string
                                
                                -- Skip non-layer properties
                                if matchPattern propName pattern:"Weight_*" or 
                                   findString "average,exposedX,exposedY,exposedZ,count,active" propName != undefined then continue
                                
                                try (
                                    local layer = getProperty obj.scale.controller prop
                                    if layer.controller != undefined then (
                                        totalFlipped += flipKeys layer.controller ("Scale [" + propName + "]") direction
                                    )
                                ) catch ()
                            )
                        ) else (
                            -- Standard scale controller
                            totalFlipped += flipKeys obj.scale.controller "Scale" direction
                        )
                    )
                )
                
                format "\n=== TOTAL FLIPPED: % keys ===\n" totalFlipped
            )
        )
    )
)

-- ============================================================
-- END OF AK ANIMATION KEYS TOOLS
-- ============================================================