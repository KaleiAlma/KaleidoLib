function math.identity_matrix3()
    return lstg.Matrix3(1,0,0,0,1,0,0,0,1)
end

function math.rotate_matrix3(heading)
    return lstg.Matrix3(heading.x,heading.y,0,heading.y,heading.x,0,0,0,1)
end

function math.scale_matrix3(scale)
    return lstg.Matrix3(scale.x,0,0,0,scale.y,0,0,0,1)
end

function math.translate_matrix3(move)
    return lstg.Matrix3(1,0,move.x,0,1,move.y,0,0,1)
end

function math.shear_matrix3(shear)
    return lstg.Matrix3(1,0,shear.x,0,1,shear.y,0,0,1)
end

function math.matrix3_from_object(obj)
    return math.scale_matrix3(lstg.Vector2(obj.hscale,obj.vscale)) * 
           math.rotate_matrix3(lstg.Vector2(cos(obj.rot),sin(obj.rot))) *
           math.translate_matrix3(lstg.Vector2(obj.x,obj.y))
end