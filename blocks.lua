----------------------------------------------------------------------
-- blocks ipelet
----------------------------------------------------------------------

label = "Pivoting squares"

revertOriginal = _G.revertOriginal

V = ipe.Vector

function round(p)
  return V(math.floor(p.x + 0.5), math.floor(p.y + 0.5))
end

function get_block_robots(model)
  local p = model:page()
  local block = nil
  local robots = {}
  for i, obj, sel, layer in p:objects() do
    if obj:type() == "reference" then
      local s = obj:get("markshape")
      if sel and s:sub(1,10)  == "mark/block" then
	if block then model.ui:explain("do not select more than one block") return end
	block = obj
      elseif s:sub(1,5) == "mark/" and s:sub(6, 10) ~= "block" then
	robots[#robots+1] = obj
      end
    end
  end
  if not block then model.ui:explain("no block selected") return end
  return block, robots
end

function check_joint(robots, center)
  for _,r in ipairs(robots) do
    local p = round(r:matrix() * r:position())
    if center == p then return true end
  end
  return false
end

function rotate(model, num)
  local block, robots
  block, robots = get_block_robots(model)
  if not block then return end
  local m = block:matrix()
  local mid = round(m * block:position())
  local center, rot
  if num == 1 or num == 5 then
    center = mid + V(8, -8)
  elseif num == 2 or num == 6 then
    center = mid + V(-8, -8)
  elseif num == 3 or num == 7 then
    center = mid + V(-8, 8)
  elseif num == 4 or num == 8 then
    center = mid + V(8, 8)
  end
  if num <= 4 then
    rot = ipe.Rotation(-math.pi / 2.0)
  else
    rot = ipe.Rotation(math.pi / 2.0)
  end

  if not check_joint(robots, center) then
      model.ui:explain("there is no robot on that joint") 
      return
  end
  
  local matrix = ipe.Translation(center) * rot * ipe.Translation(-center)

  local t = { label = label,
	      pno = model.pno,
	      vno = model.vno,
	      selection = model:selection(),
	      original = model:page():clone(),
	      matrix = matrix,
	      undo = revertOriginal,
	    }
  t.redo = function (t, doc)
	     local p = doc[t.pno]
	     for _,i in ipairs(t.selection) do p:transform(i, t.matrix) end
	   end
  model:register(t)
end

methods = {
  { label = "Right bottom right", run=rotate },
  { label = "Right bottom left", run=rotate },
  { label = "Right top left", run=rotate },
  { label = "Right top right", run=rotate },
  { label = "Left bottom right", run=rotate },
  { label = "Left bottom left", run=rotate },
  { label = "Left top left", run=rotate },
  { label = "Left top right", run=rotate },
}

shortcuts.ipelet_1_blocks = "L"
shortcuts.ipelet_2_blocks = "K"
shortcuts.ipelet_3_blocks = "I"
shortcuts.ipelet_4_blocks = "O"
shortcuts.ipelet_5_blocks = "J"
shortcuts.ipelet_6_blocks = "H"
shortcuts.ipelet_7_blocks = "Y"
shortcuts.ipelet_8_blocks = "U"
shortcuts.mode_label = nil
shortcuts.mode_splines = nil
shortcuts.mode_circle1 = nil
shortcuts.mode_ink = nil
shortcuts.jump_page = nil

----------------------------------------------------------------------
