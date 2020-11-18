globals
  rect array cells// 8x8 rect area
  unit array pieces//
  integer turn = 1
  effect array avail
  boolean validMove = true
  boolean array pawnMoved
  boolean p0KingInCheck = false
  boolean p1KingInCheck = false
  boolean p0KingMoved = false
  boolean p1KingMoved = false
  boolean p0Rook0Moved = false
  boolean p0Rook1Moved = false
  boolean p1Rook0Moved = false
  boolean p1Rook1Moved = false
  boolean p0ShortCastleUnderAttack = false
  boolean p0LongCastleUnderAttack = false
  boolean p1ShortCastleUnderAttack = false
  boolean p1LongCastleUnderAttack = false
  integer array attackingSquare
  unit attack0CastleUnit = null
  unit attack1CastleUnit = null
  integer cellSubOfAttack0CastleUnit = -1
  integer cellSubOfAttack1CastleUnit = -1
  
  unit upgradeUnit
  location upgradeLocation
  integer upgradePlayer = 0
  dialog chooseUpgrade = DialogCreate()
  button btnRook = DialogAddButton(chooseUpgrade, "Rook", 0)
  button btnKnight = DialogAddButton(chooseUpgrade, "Knight", 0)
  button btnBishop = DialogAddButton(chooseUpgrade, "Bishop", 0)
  button btnQueen = DialogAddButton(chooseUpgrade, "Queen", 0)
endglobals

function subOfCell takes integer row, integer col returns integer
  return row*8+col
endfunction
function getRow takes integer sub returns integer
  return sub/8
endfunction
function getCol takes integer sub returns integer
  return ModuloInteger(sub, 8)
endfunction

function createBoard takes nothing returns nothing
  local real x0 = -1205
  local real y0 = 700
  local real width = 260
  local integer i
  local integer j
  local integer k
  local unit u
  local unit t
  set i = 0
  loop
    exitwhen i >= 8
    set j = 0
    loop
      exitwhen j >= 8
      set cells[subOfCell(i, j)] = Rect(x0+j*width,y0-i*width,x0+(j+1)*width,y0-(i+1)*width)
      set j = j + 1
    endloop
    set i = i + 1
  endloop
  // create pieces for player0
  set i = 0
  set k = 0
  loop
    exitwhen i>=8
    set pieces[k] = CreateUnitAtLoc(Player(0), 'hfoo' ,GetRectCenter(cells[subOfCell(1, i)]), 270)
    set i = i + 1
    set k = k + 1
  endloop
  set i = 0
  set pieces[k] = CreateUnitAtLoc(Player(0), 'hmtt' ,GetRectCenter(cells[subOfCell(0, 0)]), 270)
  set pieces[k+1] = CreateUnitAtLoc(Player(0), 'hkni' ,GetRectCenter(cells[subOfCell(0, 1)]), 270)
  set pieces[k+2] = CreateUnitAtLoc(Player(0), 'hrif' ,GetRectCenter(cells[subOfCell(0, 2)]), 270)
  set pieces[k+3] = CreateUnitAtLoc(Player(0), 'hsor' ,GetRectCenter(cells[subOfCell(0, 3)]), 270)
  set pieces[k+4] = CreateUnitAtLoc(Player(0), 'Hart' ,GetRectCenter(cells[subOfCell(0, 4)]), 270)
  set pieces[k+5] = CreateUnitAtLoc(Player(0), 'hrif' ,GetRectCenter(cells[subOfCell(0, 5)]), 270)
  set pieces[k+6] = CreateUnitAtLoc(Player(0), 'hkni' ,GetRectCenter(cells[subOfCell(0, 6)]), 270)
  set pieces[k+7] = CreateUnitAtLoc(Player(0), 'hmtt' ,GetRectCenter(cells[subOfCell(0, 7)]), 270)
  set k = k + 8
  // create pieces for player1
  loop
    exitwhen i>=8
    set pieces[k] = CreateUnitAtLoc(Player(1), 'hfoo' ,GetRectCenter(cells[subOfCell(6, i)]), 90)
    set i = i + 1
    set k = k + 1
  endloop
  set pieces[k] = CreateUnitAtLoc(Player(1), 'hmtt' ,GetRectCenter(cells[subOfCell(7, 0)]), 90)
  set pieces[k+1] = CreateUnitAtLoc(Player(1), 'hkni' ,GetRectCenter(cells[subOfCell(7, 1)]), 90)
  set pieces[k+2] = CreateUnitAtLoc(Player(1), 'hrif' ,GetRectCenter(cells[subOfCell(7, 2)]), 90)
  set pieces[k+3] = CreateUnitAtLoc(Player(1), 'hsor' ,GetRectCenter(cells[subOfCell(7, 3)]), 90)
  set pieces[k+4] = CreateUnitAtLoc(Player(1), 'Hart' ,GetRectCenter(cells[subOfCell(7, 4)]), 90)
  set pieces[k+5] = CreateUnitAtLoc(Player(1), 'hrif' ,GetRectCenter(cells[subOfCell(7, 5)]), 90)
  set pieces[k+6] = CreateUnitAtLoc(Player(1), 'hkni' ,GetRectCenter(cells[subOfCell(7, 6)]), 90)
  set pieces[k+7] = CreateUnitAtLoc(Player(1), 'hmtt' ,GetRectCenter(cells[subOfCell(7, 7)]), 90)
  
  set i = 0
  loop
    exitwhen i>=64
    set pawnMoved[i] = false
    set i = i + 1
  endloop
  set i = 0
  loop // player0's changed to neutral's
    exitwhen i>=16
    call SetUnitOwner(pieces[i], Player(PLAYER_NEUTRAL_PASSIVE), true)
    set i = i + 1
  endloop
endfunction
function rectHasUnit takes rect r returns boolean
  local integer i
  set i = 0
  loop
    exitwhen i>=32
    if RectContainsUnit(r, pieces[i]) and IsUnitAliveBJ(pieces[i]) then
      return true
    endif
    set i = i + 1
  endloop
  return false
endfunction
function p0CanShortCastle takes nothing returns boolean
  if not p0ShortCastleUnderAttack and not p0KingMoved and not p0Rook1Moved and not rectHasUnit(cells[5]) and not rectHasUnit(cells[6]) then
    return true
  else
    return false
  endif
endfunction
function p0CanLongCastle takes nothing returns boolean
  if not p0LongCastleUnderAttack and not p0KingMoved and not p0Rook0Moved and not rectHasUnit(cells[1]) and not rectHasUnit(cells[2]) and not rectHasUnit(cells[3]) then
    return true
  else
    return false
  endif
endfunction
function p1CanShortCastle takes nothing returns boolean
  if not p1ShortCastleUnderAttack and not p1KingMoved and not p1Rook1Moved and not rectHasUnit(cells[61]) and not rectHasUnit(cells[62]) then
    return true
  else
    return false
  endif
endfunction
function p1CanLongCastle takes nothing returns boolean
  if not p1LongCastleUnderAttack and not p1KingMoved and not p1Rook0Moved and not rectHasUnit(cells[57]) and not rectHasUnit(cells[58]) and not rectHasUnit(cells[59]) then
    return true
  else
    return false
  endif
endfunction
function addMana takes integer p returns nothing
  local integer i
  
  if p == 0 then
    call BJDebugMsg("addMana 0")
    set i = 0
    loop
      exitwhen i >=16
      call SetUnitManaBJ(pieces[i], GetUnitState(pieces[i], UNIT_STATE_MANA)+20)
      
      set i = i + 1
    endloop
  endif
  
  if p == 1 then
    call BJDebugMsg("addMana 1")
    set i = 16
    loop
      exitwhen i >=32
      call SetUnitManaBJ(pieces[i], GetUnitState(pieces[i], UNIT_STATE_MANA)+20)
      
      set i = i + 1
    endloop
  endif
endfunction
function flipTurn takes nothing returns nothing
  local integer i
  
  if turn == 0 then // player0 gives command
    set i = 0
    loop // player0's changed to neutral's
      exitwhen i>=16
      call SetUnitOwner(pieces[i], Player(PLAYER_NEUTRAL_PASSIVE), true)
      set i = i + 1
    endloop
    
    loop // player1's changed to player1's
      exitwhen i>=32
      call SetUnitOwner(pieces[i], Player(1), true)
      set i = i + 1
    endloop
    call addMana(0)
    set turn = 1
  elseif turn == 1 then
    set i = 0
    loop // player0's changed to player0's
      exitwhen i>=16
      call SetUnitOwner(pieces[i], Player(0), true)
      set i = i + 1
    endloop
    
    loop // player1's changed to neutral's
      exitwhen i>=32
      call SetUnitOwner(pieces[i], Player(PLAYER_NEUTRAL_PASSIVE), true)
      set i = i + 1
    endloop
    call addMana(1)
    set turn = 0
  endif
  
endfunction
function subOfUnit takes unit piece returns integer
  local integer i = 0
  loop
    exitwhen i>=32
    if pieces[i] == piece then
      return i
    endif
    set i = i + 1
  endloop
  return 0
endfunction
function location2CellSub takes location l returns integer
  local integer i = 0
  loop
    exitwhen i >= 64
    if RectContainsLoc(cells[i], l) then
      return i
    endif
    set i = i + 1
  endloop
  return 0
endfunction
function cellSubOfUnit takes unit u returns integer
  local integer i = 0
  loop
    if RectContainsUnit (cells[i], u) then
      return i
    endif
    set i = i + 1
  endloop
  return 0
endfunction
function checkUnitAttackingSquare takes unit u returns nothing
  local integer i = cellSubOfUnit(u)
  local integer j
  local integer k
  local integer t
  if GetUnitTypeId(u) == 'hfoo' then
    if IsUnitOwnedByPlayer(u, Player(0)) then
      set attackingSquare[0] = 2
      if i + 9 <= 63 then
        set attackingSquare[1] = i + 7
        set attackingSquare[2] = i + 9
      endif
    endif
    if IsUnitOwnedByPlayer(u, Player(1)) then
      set attackingSquare[0] = 2
      if i - 9 >= 0 then
        set attackingSquare[1] = i - 7
        set attackingSquare[2] = i - 9
      endif
    endif
  elseif GetUnitTypeId(u) == 'hmtt' then
    set j = 0
    set k = 1
    
    loop
      exitwhen j>=getRow(i) or rectHasUnit(cells[subOfCell(getRow(i)-1-j, getCol(i))])
      set attackingSquare[k] = subOfCell(getRow(i)-1-j, getCol(i))
      set k = k + 1
      set j = j + 1
    endloop
    set j = 0
    loop
      exitwhen j>=7-getRow(i) or rectHasUnit(cells[subOfCell(getRow(i)+1+j, getCol(i))])
      set attackingSquare[k] = subOfCell(getRow(i)+1+j, getCol(i))
      set k = k + 1
      set j = j + 1
    endloop
    set j = 0
    loop
      exitwhen j>=getCol(i) or rectHasUnit(cells[subOfCell(getRow(i), getCol(i)-1-j)])
      set attackingSquare[k] = subOfCell(getRow(i), getCol(i)-1-j)
      set k = k + 1
      set j = j + 1
    endloop
    set j = 0
    loop
      exitwhen j>=7-getCol(i) or rectHasUnit(cells[subOfCell(getRow(i), getCol(i)+1+j)])
      set attackingSquare[k] = subOfCell(getRow(i), getCol(i)+1+j)
      set k = k + 1
      set j = j + 1
    endloop
    set attackingSquare[0] = k - 1
  elseif GetUnitTypeId(u) == 'hsor' then
    set j = 0
    set k = 1
    
    loop
      exitwhen j>=getRow(i) or rectHasUnit(cells[subOfCell(getRow(i)-1-j, getCol(i))])
      set attackingSquare[k] = subOfCell(getRow(i)-1-j, getCol(i))
      set k = k + 1
      set j = j + 1
    endloop
    set j = 0
    loop
      exitwhen j>=7-getRow(i) or rectHasUnit(cells[subOfCell(getRow(i)+1+j, getCol(i))])
      set attackingSquare[k] = subOfCell(getRow(i)+1+j, getCol(i))
      set k = k + 1
      set j = j + 1
    endloop
    set j = 0
    loop
      exitwhen j>=getCol(i) or rectHasUnit(cells[subOfCell(getRow(i), getCol(i)-1-j)])
      set attackingSquare[k] = subOfCell(getRow(i), getCol(i)-1-j)
      set k = k + 1
      set j = j + 1
    endloop
    set j = 0
    loop
      exitwhen j>=7-getCol(i) or rectHasUnit(cells[subOfCell(getRow(i), getCol(i)+1+j)])
      set attackingSquare[k] = subOfCell(getRow(i), getCol(i)+1+j)
      set k = k + 1
      set j = j + 1
    endloop
    
    set j = 1
    loop
      set t = -7*j + i
      exitwhen t<0 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
      set attackingSquare[k] = t
      set j = j + 1
      set k = k + 1
    endloop
    set j = 1
    loop
      set t = 7*j + i
      exitwhen t>63 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
      set attackingSquare[k] = t
      set j = j + 1
      set k = k + 1
    endloop
    set j = 1
    loop
      set t = -9*j + i
      exitwhen t<0 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
      set attackingSquare[k] = t
      set j = j + 1
      set k = k + 1
    endloop
    set j = 1
    loop
      set t = 9*j + i
      exitwhen t>63 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
      set attackingSquare[k] = t
      set j = j + 1
      set k = k + 1
    endloop
    set attackingSquare[0] = k - 1
  elseif GetUnitTypeId(u) == 'hkni' then
    set k = 1
    if (i-10)>=0 and IAbsBJ(getRow(i-10)-getRow(i))<=3 and IAbsBJ(getCol(i-10)-getCol(i))<=3 then
      set attackingSquare[k] = i
      set k = k + 1
    endif
    if (i+10)<=63 and IAbsBJ(getRow(i+10)-getRow(i))<=3 and IAbsBJ(getCol(i+10)-getCol(i))<=3 then
      set attackingSquare[k] = i+10
      set k = k + 1
    endif
    if (i-6)>=0 and IAbsBJ(getRow(i-6)-getRow(i))<=3 and IAbsBJ(getCol(i-6)-getCol(i))<=3 then
      set attackingSquare[k] = i-6
      set k = k + 1
    endif
    if (i+6)<=63 and IAbsBJ(getRow(i+6)-getRow(i))<=3 and IAbsBJ(getCol(i+6)-getCol(i))<=3 then
      set attackingSquare[k] = i+6
      set k = k + 1
    endif
    if (i-15)>=0 and IAbsBJ(getRow(i-15)-getRow(i))<=3 and IAbsBJ(getCol(i-15)-getCol(i))<=3 then
      set attackingSquare[k] = i-15
      set k = k + 1
    endif
    if (i+15)<=63 and IAbsBJ(getRow(i+15)-getRow(i))<=3 and IAbsBJ(getCol(i+15)-getCol(i))<=3 then
      set attackingSquare[k] = i+15
      set k = k + 1
    endif
    if (i-17)>=0 and IAbsBJ(getRow(i-17)-getRow(i))<=3 and IAbsBJ(getCol(i-17)-getCol(i))<=3 then
      set attackingSquare[k] = i-17
      set k = k + 1
    endif
    if (i+17)<=63 and IAbsBJ(getRow(i+17)-getRow(i))<=3 and IAbsBJ(getCol(i+17)-getCol(i))<=3 then
      set attackingSquare[k] = i+17
      set k = k + 1
    endif
    set attackingSquare[0] = k - 1
  elseif GetUnitTypeId(u) == 'hrif' then
    set j = 1
    set k = 1
    loop
      set t = -7*j + i
      exitwhen t<0 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
      set attackingSquare[k] = t
      set j = j + 1
      set k = k + 1
    endloop
    set j = 1
    loop
      set t = 7*j + i
      exitwhen t>63 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
      set attackingSquare[k] = t
      set j = j + 1
      set k = k + 1
    endloop
    set j = 1
    loop
      set t = -9*j + i
      exitwhen t<0 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
      set attackingSquare[k] = t
      set j = j + 1
      set k = k + 1
    endloop
    set j = 1
    loop
      set t = 9*j + i
      exitwhen t>63 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
      set attackingSquare[k] = t
      set j = j + 1
      set k = k + 1
    endloop
    set attackingSquare[0] = k - 1
  elseif GetUnitTypeId(u) == 'Hart' then
    set k = 1
    if (i+8)<=63 and not rectHasUnit(cells[i+8]) then
      set attackingSquare[k] = i+8
      set k = k + 1
    endif
    if (i-8)>=0 and not rectHasUnit(cells[i-8]) then
      set attackingSquare[k] = i-8
      set k = k + 1
    endif
    if (i+1)<=63 and IAbsBJ(getRow(i)-getRow(i+1))<=2 and not rectHasUnit(cells[i+1]) then
      set attackingSquare[k] = i+1
      set k = k + 1
    endif
    if (i-1)>=0 and IAbsBJ(getRow(i)-getRow(i-1))<=2 and not rectHasUnit(cells[i-1]) then
      set attackingSquare[k] = i-1
      set k = k + 1
    endif
    if (i+7)<=63 and IAbsBJ(getRow(i)-getRow(i+7))<=2 and not rectHasUnit(cells[i+7]) then
      set attackingSquare[k] = i+7
      set k = k + 1
    endif
    if (i-7)>=0 and IAbsBJ(getRow(i)-getRow(i-7))<=2 and not rectHasUnit(cells[i-7]) then
      set attackingSquare[k] = i-7
      set k = k + 1
    endif
    if (i+9)<=63 and IAbsBJ(getRow(i)-getRow(i+9))<=2 and not rectHasUnit(cells[i+9]) then
      set attackingSquare[k] = i+9
      set k = k + 1
    endif
    if (i-9)>=0 and IAbsBJ(getRow(i)-getRow(i-9))<=2 and not rectHasUnit(cells[i-9]) then
      set attackingSquare[k] = i-9
      set k = k + 1
    endif
    set attackingSquare[0] = k - 1
  endif
endfunction
function lookSquare takes nothing returns nothing
  local integer i = 0
  local string str = ""
  loop
    exitwhen i>attackingSquare[0]
    set str = str + I2S(attackingSquare[i]) + " "
    set i = i + 1
  endloop
  call BJDebugMsg(str)
endfunction
function move takes unit piece, location target returns nothing
  local integer i
  local integer j
  local effect tx
  
  
  if GetUnitTypeId(piece) == 'Hart' then
    if IsUnitOwnedByPlayer(piece, Player(0)) then
      set p0KingMoved = true
    elseif IsUnitOwnedByPlayer(piece, Player(1)) then
      set p1KingMoved = true
    endif
  endif
  if GetUnitTypeId(piece) == 'hmtt' then
    if IsUnitOwnedByPlayer(piece, Player(0)) then
      //call BJDebugMsg("player0 rook moving")
      if subOfUnit(piece) == 8 then
        set p0Rook0Moved = true
      endif
      if subOfUnit(piece) == 15 then
        set p0Rook1Moved = true
      endif
      
    elseif IsUnitOwnedByPlayer(piece, Player(1)) then
      if subOfUnit(piece) == 24 then
        set p1Rook0Moved = true
      endif
      if subOfUnit(piece) == 31 then
        set p1Rook1Moved = true
      endif
    endif
  endif
  
  call BJDebugMsg("spell location: "+R2S(GetLocationX(target))+", "+R2S(GetLocationY(target)))
  set i = 0
  loop
    exitwhen i >= 64
    if RectContainsLoc(cells[i], target) then
      set tx = AddSpecialEffectLocBJ(GetRectCenter(cells[i]), "Abilities\\Spells\\Human\\Blizzard\\BlizzardTarget.mdl" )
      call DestroyEffect(tx)
      call SetUnitPositionLoc(piece, GetRectCenter(cells[i]))
      call checkUnitAttackingSquare(piece)
      call lookSquare()
      
      if attack0CastleUnit != null and not RectContainsUnit(cells[cellSubOfAttack0CastleUnit], attack0CastleUnit) or not IsUnitAliveBJ(attack1CastleUnit) then
        set p0LongCastleUnderAttack = false
        set p0ShortCastleUnderAttack = false
      endif
      if attack1CastleUnit != null and not RectContainsUnit(cells[cellSubOfAttack1CastleUnit], attack1CastleUnit) or not IsUnitAliveBJ(attack1CastleUnit) then
        set p1LongCastleUnderAttack = false
        set p1ShortCastleUnderAttack = false
      endif
      set j = 1
      loop
        exitwhen j >= attackingSquare[0]
        if subOfUnit(piece) >=16 and attackingSquare[j] == 4 then // if Player(1) owns piece
          set attack0CastleUnit = piece
          set cellSubOfAttack0CastleUnit = cellSubOfUnit(piece)
          set p0LongCastleUnderAttack = true
          set p0ShortCastleUnderAttack = true
        endif
        if subOfUnit(piece) >=16 and (attackingSquare[j] == 2 or attackingSquare[j] == 3) then
          set attack0CastleUnit = piece
          set cellSubOfAttack0CastleUnit = cellSubOfUnit(piece)
          set p0LongCastleUnderAttack = true
        endif
        if subOfUnit(piece) >=16 and (attackingSquare[j] == 5 or attackingSquare[j] == 6) then
          set attack0CastleUnit = piece
          set cellSubOfAttack0CastleUnit = cellSubOfUnit(piece)
          set p0ShortCastleUnderAttack = true
        endif
        
        
        if subOfUnit(piece) <=15 and attackingSquare[j] == 60 then // if Player(0) owns piece
          set attack1CastleUnit = piece
          set cellSubOfAttack1CastleUnit = cellSubOfUnit(piece)
          set p1LongCastleUnderAttack = true
          set p1ShortCastleUnderAttack = true
        endif
        if subOfUnit(piece) <=15 and (attackingSquare[j] == 58 or attackingSquare[j] == 59) then
          set attack1CastleUnit = piece
          set cellSubOfAttack1CastleUnit = cellSubOfUnit(piece)
          set p1LongCastleUnderAttack = true
        endif
        if subOfUnit(piece) <=15 and (attackingSquare[j] == 61 or attackingSquare[j] == 62) then
          set attack1CastleUnit = piece
          set cellSubOfAttack1CastleUnit = cellSubOfUnit(piece)
          set p1ShortCastleUnderAttack = true
        endif
        set j = j + 1
      endloop
    endif
    set i = i + 1
  endloop
  set tx = null
endfunction
function updateAttackingSquareAfterKill takes unit piece returns nothing
  local integer j
  call checkUnitAttackingSquare(piece)
  call lookSquare()
  if attack0CastleUnit != null and not RectContainsUnit(cells[cellSubOfAttack0CastleUnit], attack0CastleUnit) or not IsUnitAliveBJ(attack0CastleUnit) then
    set p0LongCastleUnderAttack = false
    set p0ShortCastleUnderAttack = false
  endif
  if attack1CastleUnit != null and not RectContainsUnit(cells[cellSubOfAttack1CastleUnit], attack1CastleUnit) or not IsUnitAliveBJ(attack1CastleUnit) then
    set p1LongCastleUnderAttack = false
    set p1ShortCastleUnderAttack = false
  endif
  set j = 1
  loop
    exitwhen j >= attackingSquare[0]
    if subOfUnit(piece) >=16 and attackingSquare[j] == 4 then // if Player(1) owns piece
      set attack0CastleUnit = piece
      set cellSubOfAttack0CastleUnit = cellSubOfUnit(piece)
      set p0LongCastleUnderAttack = true
      set p0ShortCastleUnderAttack = true
    endif
    if subOfUnit(piece) >=16 and (attackingSquare[j] == 2 or attackingSquare[j] == 3) then
      set attack0CastleUnit = piece
      set cellSubOfAttack0CastleUnit = cellSubOfUnit(piece)
      set p0LongCastleUnderAttack = true
    endif
    if subOfUnit(piece) >=16 and (attackingSquare[j] == 5 or attackingSquare[j] == 6) then
      set attack0CastleUnit = piece
      set cellSubOfAttack0CastleUnit = cellSubOfUnit(piece)
      set p0ShortCastleUnderAttack = true
    endif
    
    if subOfUnit(piece) <=15 and attackingSquare[j] == 60 then // if Player(0) owns piece
      set attack1CastleUnit = piece
      set cellSubOfAttack1CastleUnit = cellSubOfUnit(piece)
      set p1LongCastleUnderAttack = true
      set p1ShortCastleUnderAttack = true
    endif
    if subOfUnit(piece) <=15 and (attackingSquare[j] == 58 or attackingSquare[j] == 59) then
      set attack1CastleUnit = piece
      set cellSubOfAttack1CastleUnit = cellSubOfUnit(piece)
      set p1LongCastleUnderAttack = true
    endif
    if subOfUnit(piece) <=15 and (attackingSquare[j] == 61 or attackingSquare[j] == 62) then
      set attack1CastleUnit = piece
      set cellSubOfAttack1CastleUnit = cellSubOfUnit(piece)
      set p1ShortCastleUnderAttack = true
    endif
    set j = j + 1
  endloop
endfunction


function checkMove takes player p, unit piece, location target, integer act returns boolean
  local integer unitType = GetUnitTypeId(piece)
  local location pieceLocation = GetUnitLoc(piece)
  local integer i = 0
  local integer j = 0
  local integer t = 0
  local integer k = 0
  local integer targetCellSub
  set i = 0
  loop // find where the target is
    exitwhen RectContainsLoc(cells[i], target) or i>= 64
    set i = i + 1
  endloop
  set targetCellSub = i
  call BJDebugMsg("checkMove target location: "+R2S(GetLocationX(target))+", "+R2S(GetLocationY(target)))
  set i = 0
  loop
    exitwhen i>=64
    if RectContainsLoc(cells[i], pieceLocation) then //find where the piece is
      
      if unitType == 'hfoo' then
        if IsUnitOwnedByPlayer(piece, Player(0)) then
          if act == 0 then
            if pawnMoved[subOfUnit(piece)] then
              if targetCellSub == i + 8 and not rectHasUnit(cells[targetCellSub]) then
                return true
              else
                return false
              endif
            else
              if (targetCellSub == i + 8 and not rectHasUnit(cells[targetCellSub])) or (targetCellSub == i + 16 and not rectHasUnit(cells[i+8]) and not rectHasUnit(cells[targetCellSub])) then
                set pawnMoved[subOfUnit(piece)] = true
                return true
              else
                return false
              endif
            endif
          endif
          
          if act == 1 then
            if targetCellSub == i + 7 or targetCellSub == i + 9 then
              return true
            else
              return false
            endif
          endif
        elseif IsUnitOwnedByPlayer(piece, Player(1)) then
          if act == 0 then
            if pawnMoved[subOfUnit(piece)] then
              if targetCellSub == i - 8 and not rectHasUnit(cells[targetCellSub]) then
                return true
              else
                return false
              endif
            else
              if (targetCellSub == i - 8 and not rectHasUnit(cells[targetCellSub])) or (targetCellSub == i - 16 and not rectHasUnit(cells[i-8]) and not rectHasUnit(cells[targetCellSub])) then
                set pawnMoved[subOfUnit(piece)] = true
                return true
              else
                return false
              endif
            endif
          endif
          
          if act == 1 then
            if targetCellSub == i - 7 or targetCellSub == i - 9 then
              return true
            else
              return false
            endif
          endif
        endif
        return false
      elseif unitType == 'hkni' then
        
        if (i-10)>=0 and IAbsBJ(getRow(i-10)-getRow(i))<=3 and IAbsBJ(getCol(i-10)-getCol(i))<=3 then
          if RectContainsLoc(cells[i-10], target) then
            if act == 1 then
              return true
            elseif act == 0 and not rectHasUnit(cells[i-10]) then
              return true
            endif
          endif
        endif
        if (i+10)<=63 and IAbsBJ(getRow(i+10)-getRow(i))<=3 and IAbsBJ(getCol(i+10)-getCol(i))<=3 then
          if RectContainsLoc(cells[i+10], target) then
            if act == 1 then
              return true
            elseif act == 0 and not rectHasUnit(cells[i+10]) then
              return true
            endif
          endif
        endif
        if (i-6)>=0 and IAbsBJ(getRow(i-6)-getRow(i))<=3 and IAbsBJ(getCol(i-6)-getCol(i))<=3 then
          if RectContainsLoc(cells[i-6], target) then
            if act == 1 then
              return true
            elseif act == 0 and not rectHasUnit(cells[i-6]) then
              return true
            endif
          endif
        endif
        if (i+6)<=63 and IAbsBJ(getRow(i+6)-getRow(i))<=3 and IAbsBJ(getCol(i+6)-getCol(i))<=3 then
          if RectContainsLoc(cells[i+6], target) then
            if act == 1 then
              return true
            elseif act == 0 and not rectHasUnit(cells[i+6]) then
              return true
            endif
          endif
        endif
        if (i-15)>=0 and IAbsBJ(getRow(i-15)-getRow(i))<=3 and IAbsBJ(getCol(i-15)-getCol(i))<=3 then
          if RectContainsLoc(cells[i-15], target) then
            if act == 1 then
              return true
            elseif act == 0 and not rectHasUnit(cells[i-15]) then
              return true
            endif
          endif
        endif
        if (i+15)<=63 and IAbsBJ(getRow(i+15)-getRow(i))<=3 and IAbsBJ(getCol(i+15)-getCol(i))<=3 then
          if RectContainsLoc(cells[i+15], target) then
            if act == 1 then
              return true
            elseif act == 0 and not rectHasUnit(cells[i+15]) then
              return true
            endif
          endif
        endif
        if (i-17)>=0 and IAbsBJ(getRow(i-17)-getRow(i))<=3 and IAbsBJ(getCol(i-17)-getCol(i))<=3 then
          if RectContainsLoc(cells[i-17], target) then
            if act == 1 then
              return true
            elseif act == 0 and not rectHasUnit(cells[i-17]) then
              return true
            endif
          endif
        endif
        if (i+17)<=63 and IAbsBJ(getRow(i+17)-getRow(i))<=3 and IAbsBJ(getCol(i+17)-getCol(i))<=3 then
          if RectContainsLoc(cells[i+17], target) then
            if act == 1 then
              return true
            elseif act == 0 and not rectHasUnit(cells[i+17]) then
              return true
            endif
          endif
        endif
        return false
      elseif unitType == 'hrif' then
        call BJDebugMsg("targetCellSub: "+I2S(targetCellSub))
        
        if (IAbsBJ(getRow(targetCellSub) - getRow(i))) == (IAbsBJ(getCol(targetCellSub) - getCol(i))) then
          
          
          if getRow(targetCellSub) - getRow(i) < 0 and getCol(targetCellSub) - getCol(i) < 0 then
            
            set k = 0
            loop
              exitwhen k >= getRow(i) - getRow(targetCellSub)
              set j = 0
              if rectHasUnit(cells[subOfCell(getRow(i)-1-k, getCol(i)-1-k)]) then
                if (k == (getRow(i) - getRow(targetCellSub) - 1)) and (act == 1) then
                  
                  return true
                else
                  
                  return false
                endif
              endif
              set k = k + 1
            endloop
            
            return true
          endif
          
          if getRow(targetCellSub) - getRow(i) > 0 and getCol(targetCellSub) - getCol(i) < 0 then
            
            set k = 0
            loop
              exitwhen k >= getRow(targetCellSub) - getRow(i)
              call BJDebugMsg(I2S(getRow(i)+1+k)+", "+I2S(getCol(i)-1-k))
              call BJDebugMsg(I2S(subOfCell(getRow(i)+1+k, getCol(i)-1-k)))
              
              if rectHasUnit(cells[subOfCell(getRow(i)+1+k, getCol(i)-1-k)]) then
                
                call BJDebugMsg(I2S(getRow(i)+1+k)+", "+I2S(getCol(i)-1-k))
                if (k == (getRow(targetCellSub) - getRow(i) - 1)) and (act == 1) then
                  
                  return true
                else
                  
                  return false
                endif
              endif
              set k = k + 1
            endloop
            
            return true
          endif
          
          if getRow(targetCellSub) - getRow(i) < 0 and getCol(targetCellSub) - getCol(i) > 0 then
            
            set k = 0
            loop
              exitwhen k >= getRow(i) - getRow(targetCellSub)
              
              if rectHasUnit(cells[subOfCell(getRow(i)-1-k, getCol(i)+1+k)]) then
                if (k == (getRow(i) - getRow(targetCellSub) - 1)) and (act == 1) then
                  
                  return true
                else
                  
                  return false
                endif
              endif
              set k = k + 1
            endloop
            
            return true
          endif
          
          if getRow(targetCellSub) - getRow(i) > 0 and getCol(targetCellSub) - getCol(i) > 0 then
            
            set k = 0
            loop
              exitwhen k >= getRow(targetCellSub) - getRow(i)
              
              set j = 0
              if rectHasUnit(cells[subOfCell(getRow(i)+1+k, getCol(i)+1+k)]) then
                if (k == (getRow(targetCellSub) - getRow(i) - 1)) and(act == 1) then
                  
                  return true
                else
                  
                  return false
                endif
              endif
              set k = k + 1
            endloop
            
            
            return true
          endif
        endif
        return false
      elseif unitType == 'hsor' then
        if (IAbsBJ(getRow(targetCellSub) - getRow(i))) == (IAbsBJ(getCol(targetCellSub) - getCol(i))) then
          if getRow(targetCellSub) - getRow(i) < 0 and getCol(targetCellSub) - getCol(i) < 0 then
            
            set k = 0
            loop
              exitwhen k >= getRow(i) - getRow(targetCellSub)
              set j = 0
              if rectHasUnit(cells[subOfCell(getRow(i)-1-k, getCol(i)-1-k)]) then
                if (k == (getRow(i) - getRow(targetCellSub) - 1)) and (act == 1) then
                  
                  return true
                else
                  
                  return false
                endif
              endif
              set k = k + 1
            endloop
            
            return true
          endif
          
          if getRow(targetCellSub) - getRow(i) > 0 and getCol(targetCellSub) - getCol(i) < 0 then
            
            set k = 0
            loop
              exitwhen k >= getRow(targetCellSub) - getRow(i)
              
              if rectHasUnit(cells[subOfCell(getRow(i)+1+k, getCol(i)-1-k)]) then
                
                if (k == (getRow(targetCellSub) - getRow(i) - 1)) and (act == 1) then
                  
                  return true
                else
                  
                  return false
                endif
              endif
              set k = k + 1
            endloop
            
            return true
          endif
          
          if getRow(targetCellSub) - getRow(i) < 0 and getCol(targetCellSub) - getCol(i) > 0 then
            
            set k = 0
            loop
              exitwhen k >= getRow(i) - getRow(targetCellSub)
              
              if rectHasUnit(cells[subOfCell(getRow(i)-1-k, getCol(i)+1+k)]) then
                if (k == (getRow(i) - getRow(targetCellSub) - 1)) and (act == 1) then
                  
                  return true
                else
                  
                  return false
                endif
              endif
              set k = k + 1
            endloop
            
            return true
          endif
          
          if getRow(targetCellSub) - getRow(i) > 0 and getCol(targetCellSub) - getCol(i) > 0 then
            
            set k = 0
            loop
              exitwhen k >= getRow(targetCellSub) - getRow(i)
              
              set j = 0
              if rectHasUnit(cells[subOfCell(getRow(i)+1+k, getCol(i)+1+k)]) then
                if (k == (getRow(targetCellSub) - getRow(i) - 1)) and(act == 1) then
                  
                  return true
                else
                  
                  return false
                endif
              endif
              set k = k + 1
            endloop
            
            return true
          endif
        endif
        
        if getRow(targetCellSub) == getRow(i) or getCol(targetCellSub) == getCol(i) then
          if getRow(targetCellSub) == getRow(i) and getCol(targetCellSub) == getCol(i) then
            return false
          endif
          if getCol(targetCellSub) == getCol(i) and getRow(targetCellSub) < getRow(i) then
            
            if act == 1 then
              set k = 0
              loop
                exitwhen k >= getRow(i) - getRow(targetCellSub) - 1
                if rectHasUnit(cells[subOfCell(getRow(i)-1-k, getCol(i))]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
            if act == 0 then
              set k = 0
              loop
                exitwhen k >= getRow(i) - getRow(targetCellSub)
                if rectHasUnit(cells[subOfCell(getRow(i)-1-k, getCol(i))]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
          endif
          if getCol(targetCellSub) == getCol(i) and getRow(targetCellSub) > getRow(i) then
            if act == 1 then
              set k = 0
              loop
                exitwhen k >= getRow(targetCellSub) - getRow(i) - 1
                if rectHasUnit(cells[subOfCell(getRow(i)+1+k, getCol(i))]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
            if act == 0 then
              set k = 0
              loop
                exitwhen k >= getRow(targetCellSub) - getRow(i)
                if rectHasUnit(cells[subOfCell(getRow(i)+1+k, getCol(i))]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
          endif
          if getRow(targetCellSub) == getRow(i) and getCol(targetCellSub) < getCol(i) then
            if act == 1 then
              set k = 0
              loop
                exitwhen k >= getCol(i) - getCol(targetCellSub) - 1
                if rectHasUnit(cells[subOfCell(getRow(i), getCol(i)-1-k)]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
            if act == 0 then
              set k = 0
              loop
                exitwhen k >= getCol(i) - getCol(targetCellSub)
                if rectHasUnit(cells[subOfCell(getRow(i), getCol(i)-1-k)]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
          endif
          if getRow(targetCellSub) == getRow(i) and getCol(targetCellSub) > getCol(i) then
            if act == 1 then
              set k = 0
              loop
                exitwhen k >= getCol(targetCellSub) - getCol(i) - 1
                if rectHasUnit(cells[subOfCell(getRow(i), getCol(i)+1+k)]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
            if act == 0 then
              set k = 0
              loop
                exitwhen k >= getCol(targetCellSub) - getCol(i)
                if rectHasUnit(cells[subOfCell(getRow(i), getCol(i)+1+k)]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
          endif
        endif
        return false
        
      elseif unitType == 'hmtt' then
        set k = 0
        set j = 0
        if getRow(targetCellSub) == getRow(i) or getCol(targetCellSub) == getCol(i) then
          if getRow(targetCellSub) == getRow(i) and getCol(targetCellSub) == getCol(i) then
            return false
          endif
          if getCol(targetCellSub) == getCol(i) and getRow(targetCellSub) < getRow(i) then
            
            if act == 1 then
              set k = 0
              loop
                exitwhen k >= getRow(i) - getRow(targetCellSub) - 1
                if rectHasUnit(cells[subOfCell(getRow(i)-1-k, getCol(i))]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
            if act == 0 then
              set k = 0
              loop
                exitwhen k >= getRow(i) - getRow(targetCellSub)
                if rectHasUnit(cells[subOfCell(getRow(i)-1-k, getCol(i))]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
          endif
          if getCol(targetCellSub) == getCol(i) and getRow(targetCellSub) > getRow(i) then
            if act == 1 then
              set k = 0
              loop
                exitwhen k >= getRow(targetCellSub) - getRow(i) - 1
                if rectHasUnit(cells[subOfCell(getRow(i)+1+k, getCol(i))]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
            if act == 0 then
              set k = 0
              loop
                exitwhen k >= getRow(targetCellSub) - getRow(i)
                if rectHasUnit(cells[subOfCell(getRow(i)+1+k, getCol(i))]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
          endif
          if getRow(targetCellSub) == getRow(i) and getCol(targetCellSub) < getCol(i) then
            if act == 1 then
              set k = 0
              loop
                exitwhen k >= getCol(i) - getCol(targetCellSub) - 1
                if rectHasUnit(cells[subOfCell(getRow(i), getCol(i)-1-k)]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
            if act == 0 then
              set k = 0
              loop
                exitwhen k >= getCol(i) - getCol(targetCellSub)
                if rectHasUnit(cells[subOfCell(getRow(i), getCol(i)-1-k)]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
          endif
          if getRow(targetCellSub) == getRow(i) and getCol(targetCellSub) > getCol(i) then
            if act == 1 then
              set k = 0
              loop
                exitwhen k >= getCol(targetCellSub) - getCol(i) - 1
                if rectHasUnit(cells[subOfCell(getRow(i), getCol(i)+1+k)]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
            if act == 0 then
              set k = 0
              loop
                exitwhen k >= getCol(targetCellSub) - getCol(i)
                if rectHasUnit(cells[subOfCell(getRow(i), getCol(i)+1+k)]) then
                  return false
                endif
                set k = k + 1
              endloop
              return true
            endif
          endif
        else
          return false
        endif
        return false
      elseif unitType == 'Hart' then
        if not p0ShortCastleUnderAttack and not p0KingMoved and not p0Rook1Moved then
          call BJDebugMsg("player0 short castle check")
          if RectContainsLoc(cells[6], target) and not rectHasUnit(cells[6]) and not rectHasUnit(cells[5]) then
            call BJDebugMsg("player0 short castle move rook")
            call move(pieces[15], GetRectCenter(cells[5]))
            call BJDebugMsg("player0 short castle move rook finished")
            return true
          endif
          
          
        endif
        if not p0LongCastleUnderAttack and not p0KingMoved and not p0Rook0Moved then
          if RectContainsLoc(cells[2], target) and not rectHasUnit(cells[1]) and not rectHasUnit(cells[2]) and not rectHasUnit(cells[3]) then
            call move(pieces[8], GetRectCenter(cells[3]))
            call BJDebugMsg("player0 long castle check pass")
            return true
          endif
        endif
        
        if not p1ShortCastleUnderAttack and not p1KingMoved and not p1Rook1Moved then
          if RectContainsLoc(cells[62], target) and not rectHasUnit(cells[62]) and not rectHasUnit(cells[61]) then
            call move(pieces[31], GetRectCenter(cells[61]))
            return true
          endif
          
          
        endif
        if not p1LongCastleUnderAttack and not p1KingMoved and not p1Rook0Moved then
          if RectContainsLoc(cells[58], target) and not rectHasUnit(cells[57]) and not rectHasUnit(cells[58]) and not rectHasUnit(cells[59]) then
            call move(pieces[24], GetRectCenter(cells[59]))
            return true
          endif
        endif
        if (i+8)<=63 then
          if act == 0 then
            if RectContainsLoc(cells[i+8], target) and not rectHasUnit(cells[i+8]) then
              return true
            endif
          endif
          if act == 1 then
            if RectContainsLoc(cells[i+8], target) then
              return true
            endif
          endif
        endif
        if (i-8)>=0 then
          if act == 0 then
            if RectContainsLoc(cells[i-8], target) and not rectHasUnit(cells[i-8]) then
              return true
            endif
          endif
          if act == 1 then
            if RectContainsLoc(cells[i-8], target) then
              return true
            endif
          endif
        endif
        if (i+1)<=63 and IAbsBJ(getRow(i)-getRow(i+1))<=2 then
          if act == 0 then
            if RectContainsLoc(cells[i+1], target) and not rectHasUnit(cells[i+1]) then
              return true
            endif
          endif
          if act == 1 then
            if RectContainsLoc(cells[i+1], target) then
              return true
            endif
          endif
        endif
        if (i-1)>=0 and IAbsBJ(getRow(i)-getRow(i-1))<=2 then
          if act == 0 then
            if RectContainsLoc(cells[i-1], target) and not rectHasUnit(cells[i-1]) then
              return true
            endif
          endif
          if act == 1 then
            if RectContainsLoc(cells[i-1], target) then
              return true
            endif
          endif
          
        endif
        if (i+7)<=63 and IAbsBJ(getRow(i)-getRow(i+7))<=2 then
          if act == 0 then
            if RectContainsLoc(cells[i+7], target) and not rectHasUnit(cells[i+7]) then
              return true
            endif
          endif
          if act == 1 then
            if RectContainsLoc(cells[i+7], target) then
              return true
            endif
          endif
        endif
        if (i-7)>=0 and IAbsBJ(getRow(i)-getRow(i-7))<=2 then
          if act == 0 then
            if RectContainsLoc(cells[i-7], target) and not rectHasUnit(cells[i-7]) then
              return true
            endif
          endif
          if act == 1 then
            if RectContainsLoc(cells[i-7], target) then
              return true
            endif
          endif
        endif
        if (i+9)<=63 and IAbsBJ(getRow(i)-getRow(i+9))<=2 then
          if act == 0 then
            if RectContainsLoc(cells[i+9], target) and not rectHasUnit(cells[i+9]) then
              return true
            endif
          endif
          if act == 1 then
            if RectContainsLoc(cells[i+9], target) then
              return true
            endif
          endif
        endif
        if (i-9)>=0 and IAbsBJ(getRow(i)-getRow(i-9))<=2 then
          if act == 0 then
            if RectContainsLoc(cells[i-9], target) and not rectHasUnit(cells[i-9]) then
              return true
            endif
          endif
          if act == 1 then
            if RectContainsLoc(cells[i-9], target) then
              return true
            endif
          endif
        endif
        
        return false
      endif
      
      set i = 64
    endif
    set i = i + 1
  endloop
  return false
endfunction


function cleanHint takes nothing returns nothing
  local integer i
  set i = 0
  loop
    exitwhen i>=32
    if avail[i]!=null then
      call DestroyEffect(avail[i])
    endif
    set i = i + 1
  endloop
endfunction
function rectHasEnemyUnit takes rect r returns boolean
  local integer i
  set i = 0
  loop
    exitwhen i>=32
    if RectContainsUnit(r, pieces[i]) and IsUnitAliveBJ(pieces[i]) and IsUnitOwnedByPlayer(pieces[i], Player(PLAYER_NEUTRAL_PASSIVE)) then
      return true
    endif
    set i = i + 1
  endloop
  return false
endfunction
function hint takes unit piece returns nothing
  local integer unitType = GetUnitTypeId(piece)
  local location pieceLocation = GetUnitLoc(piece)
  local integer i = 0
  local integer j = 0
  local integer t = 0
  local integer k = 0
  local string highlight = "Doodads\\Cinematic\\FireRockSmall\\FireRockSmall.mdl"
  
  call cleanHint()
  
  call BJDebugMsg("selected unit location " + "(" + R2S(GetLocationX(pieceLocation))+", "+R2S(GetLocationY(pieceLocation))+")")
  set i = 0
  loop
    exitwhen i>=64
    if RectContainsLoc(cells[i], pieceLocation) then //find where the piece is
      if unitType == 'hfoo' then
        if IsUnitOwnedByPlayer(piece, Player(0)) then
          if rectHasEnemyUnit(cells[i+7]) then // if diagnal cell contains enemy's piece
            set avail[2] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+7]), highlight)
          endif
          if rectHasEnemyUnit(cells[i+9]) then
            set avail[3] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+9]), highlight)
          endif
          if getRow(i) == 1 then
            if not rectHasUnit(cells[i+8]) then
              set avail[0] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+8]), highlight)
              if not rectHasUnit(cells[i+16]) then
                set avail[1] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+16]), highlight)
              endif
            endif
          else
            if not rectHasEnemyUnit(cells[i+8]) then
              set avail[0] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+8]), highlight)
            endif
          endif
          
        elseif IsUnitOwnedByPlayer(piece, Player(1)) then
          
          if rectHasEnemyUnit(cells[i-7]) then
            set avail[2] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-7]), highlight)
          endif
          if rectHasEnemyUnit(cells[i-9]) then
            set avail[3] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-9]), highlight)
          endif
          
          if getRow(i) == 6 then
            if not rectHasUnit(cells[i-8]) then
              set avail[0] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-8]), highlight)
              if not rectHasUnit(cells[i-16]) then
                set avail[1] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-16]), highlight)
              endif
            endif
          else
            if not rectHasUnit(cells[i-8]) then
              set avail[0] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-8]), highlight)
            endif
          endif
        endif
      elseif unitType == 'hkni' then
        if (i-10)>=0 and IAbsBJ(getRow(i-10)-getRow(i))<=3 and IAbsBJ(getCol(i-10)-getCol(i))<=3 then
          set avail[0] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-10]), highlight)
        endif
        if (i+10)<=63 and IAbsBJ(getRow(i+10)-getRow(i))<=3 and IAbsBJ(getCol(i+10)-getCol(i))<=3 then
          
          set avail[1] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+10]), highlight)
        endif
        if (i-6)>=0 and IAbsBJ(getRow(i-6)-getRow(i))<=3 and IAbsBJ(getCol(i-6)-getCol(i))<=3 then
          set avail[2] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-6]), highlight)
        endif
        if (i+6)<=63 and IAbsBJ(getRow(i+6)-getRow(i))<=3 and IAbsBJ(getCol(i+6)-getCol(i))<=3 then
          set avail[3] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+6]), highlight)
        endif
        if (i-15)>=0 and IAbsBJ(getRow(i-15)-getRow(i))<=3 and IAbsBJ(getCol(i-15)-getCol(i))<=3 then
          set avail[4] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-15]), highlight)
        endif
        if (i+15)<=63 and IAbsBJ(getRow(i+15)-getRow(i))<=3 and IAbsBJ(getCol(i+15)-getCol(i))<=3 then
          set avail[5] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+15]), highlight)
        endif
        if (i-17)>=0 and IAbsBJ(getRow(i-17)-getRow(i))<=3 and IAbsBJ(getCol(i-17)-getCol(i))<=3 then
          set avail[6] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-17]), highlight)
        endif
        if (i+17)<=63 and IAbsBJ(getRow(i+17)-getRow(i))<=3 and IAbsBJ(getCol(i+17)-getCol(i))<=3 then
          set avail[7] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+17]), highlight)
        endif
      elseif unitType == 'hrif' then
        set j = 1
        set k = 0
        loop
          set t = -7*j + i
          exitwhen t<0 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[t]), highlight)
          set j = j + 1
          set k = k + 1
        endloop
        set j = 1
        loop
          set t = 7*j + i
          exitwhen t>63 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[t]), highlight)
          set j = j + 1
          set k = k + 1
        endloop
        set j = 1
        loop
          set t = -9*j + i
          exitwhen t<0 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[t]), highlight)
          set j = j + 1
          set k = k + 1
        endloop
        set j = 1
        loop
          set t = 9*j + i
          exitwhen t>63 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[t]), highlight)
          set j = j + 1
          set k = k + 1
        endloop
      elseif unitType == 'hsor' then
        set j = 0
        set k = 0
        
        loop
          exitwhen j>=getRow(i) or rectHasUnit(cells[subOfCell(getRow(i)-1-j, getCol(i))])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[subOfCell(getRow(i)-1-j, getCol(i))]), highlight)
          set k = k + 1
          set j = j + 1
        endloop
        set j = 0
        loop
          exitwhen j>=7-getRow(i) or rectHasUnit(cells[subOfCell(getRow(i)+1+j, getCol(i))])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[subOfCell(getRow(i)+1+j, getCol(i))]), highlight)
          set k = k + 1
          set j = j + 1
        endloop
        set j = 0
        loop
          exitwhen j>=getCol(i) or rectHasUnit(cells[subOfCell(getRow(i), getCol(i)-1-j)])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[subOfCell(getRow(i), getCol(i)-1-j)]), highlight)
          set k = k + 1
          set j = j + 1
        endloop
        set j = 0
        loop
          exitwhen j>=7-getCol(i) or rectHasUnit(cells[subOfCell(getRow(i), getCol(i)+1+j)])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[subOfCell(getRow(i), getCol(i)+1+j)]), highlight)
          set k = k + 1
          set j = j + 1
        endloop
        
        set j = 1
        loop
          set t = -7*j + i
          exitwhen t<0 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[t]), highlight)
          set j = j + 1
          set k = k + 1
        endloop
        set j = 1
        loop
          set t = 7*j + i
          exitwhen t>63 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[t]), highlight)
          set j = j + 1
          set k = k + 1
        endloop
        set j = 1
        loop
          set t = -9*j + i
          exitwhen t<0 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[t]), highlight)
          set j = j + 1
          set k = k + 1
        endloop
        set j = 1
        loop
          set t = 9*j + i
          exitwhen t>63 or IAbsBJ(getRow(i)-getRow(t))!=IAbsBJ(getCol(i)-getCol(t)) or rectHasUnit(cells[t])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[t]), highlight)
          set j = j + 1
          set k = k + 1
        endloop
      elseif unitType == 'hmtt' then
        set j = 0
        set k = 0
        
        loop
          exitwhen j>=getRow(i) or rectHasUnit(cells[subOfCell(getRow(i)-1-j, getCol(i))])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[subOfCell(getRow(i)-1-j, getCol(i))]), highlight)
          set k = k + 1
          set j = j + 1
        endloop
        set j = 0
        loop
          exitwhen j>=7-getRow(i) or rectHasUnit(cells[subOfCell(getRow(i)+1+j, getCol(i))])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[subOfCell(getRow(i)+1+j, getCol(i))]), highlight)
          set k = k + 1
          set j = j + 1
        endloop
        set j = 0
        loop
          exitwhen j>=getCol(i) or rectHasUnit(cells[subOfCell(getRow(i), getCol(i)-1-j)])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[subOfCell(getRow(i), getCol(i)-1-j)]), highlight)
          set k = k + 1
          set j = j + 1
        endloop
        set j = 0
        loop
          exitwhen j>=7-getCol(i) or rectHasUnit(cells[subOfCell(getRow(i), getCol(i)+1+j)])
          set avail[k] = AddSpecialEffectLocBJ(GetRectCenter(cells[subOfCell(getRow(i), getCol(i)+1+j)]), highlight)
          set k = k + 1
          set j = j + 1
        endloop
      elseif unitType == 'Hart' then
        if IsUnitOwnedByPlayer(piece, Player(0)) then
          if p0CanShortCastle() then
            set avail[15] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+2]), highlight)
          endif
          if p0CanLongCastle() then
            set avail[16] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-2]), highlight)
          endif
        endif
        if IsUnitOwnedByPlayer(piece, Player(1)) then
          if p1CanShortCastle() then
            set avail[15] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+2]), highlight)
          endif
          if p1CanLongCastle() then
            set avail[16] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-2]), highlight)
          endif
        endif
        if (i+8)<=63 and not rectHasUnit(cells[i+8]) then
          set avail[0] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+8]), highlight)
        endif
        if (i-8)>=0 and not rectHasUnit(cells[i-8]) then
          set avail[1] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-8]), highlight)
        endif
        if (i+1)<=63 and IAbsBJ(getRow(i)-getRow(i+1))<=2 and not rectHasUnit(cells[i+1]) then
          set avail[2] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+1]), highlight)
        endif
        if (i-1)>=0 and IAbsBJ(getRow(i)-getRow(i-1))<=2 and not rectHasUnit(cells[i-1]) then
          set avail[3] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-1]), highlight)
        endif
        if (i+7)<=63 and IAbsBJ(getRow(i)-getRow(i+7))<=2 and not rectHasUnit(cells[i+7]) then
          set avail[4] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+7]), highlight)
        endif
        if (i-7)>=0 and IAbsBJ(getRow(i)-getRow(i-7))<=2 and not rectHasUnit(cells[i-7]) then
          set avail[5] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-7]), highlight)
        endif
        if (i+9)<=63 and IAbsBJ(getRow(i)-getRow(i+9))<=2 and not rectHasUnit(cells[i+9]) then
          set avail[6] = AddSpecialEffectLocBJ(GetRectCenter(cells[i+9]), highlight)
        endif
        if (i-9)>=0 and IAbsBJ(getRow(i)-getRow(i-9))<=2 and not rectHasUnit(cells[i-9]) then
          set avail[7] = AddSpecialEffectLocBJ(GetRectCenter(cells[i-9]), highlight)
        endif
      endif
      
      set i = 64
    endif
    set i = i + 1
  endloop
  
endfunction
function displayUpgradeDialog takes unit u, location l returns nothing
  set upgradeUnit = u
  set upgradeLocation = l
  if IsUnitOwnedByPlayer(u, Player(0)) then
    set upgradePlayer = 0
    call DialogDisplay(Player(0), chooseUpgrade, true)
  else
    set upgradePlayer = 1
    call DialogDisplay(Player(1), chooseUpgrade, true)
  endif
endfunction

function upgrade takes unit u, location l, integer t returns nothing
  local integer i
  set i = location2CellSub(l)
  call BJDebugMsg("upgrade at "+I2S(i))
  call RemoveUnit(u)
  set pieces[subOfUnit(u)]=CreateUnitAtLoc(Player(PLAYER_NEUTRAL_PASSIVE), t, GetRectCenter(cells[i]), 90)
endfunction
function index takes nothing returns nothing
  call createBoard()
endfunction
