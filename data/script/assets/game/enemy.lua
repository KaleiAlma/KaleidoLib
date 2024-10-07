
local M = {}

M.resdesc = {
    { name = 'enemy:fairy', type = 'tex', args = {'enemy/fairy.png', true} },
    { name = 'enemy:yinyang', type = 'tex', args = {'enemy/yinyang.png', true} },
    { name = 'enemy:undefined', type = 'imgfile', args = {'enemy/undefined.png'} },
    { name = 'enemy:fairy_head_a', type = 'imggrp', args = {'enemy:fairy', 0, 0, 96, 96, 4, 1} },
    { name = 'enemy:fairy_head_b', type = 'imggrp', args = {'enemy:fairy', 0, 96, 128, 128, 2, 1} },
    { name = 'enemy:fairy_head_c', type = 'imggrp', args = {'enemy:fairy', 256, 96, 128, 128, 2, 1} },
    { name = 'enemy:fairy_head_d', type = 'imggrp', args = {'enemy:fairy', 384, 0, 128, 96, 2, 1} },
    { name = 'enemy:fairy_head_e', type = 'imggrp', args = {'enemy:fairy', 512, 96, 128, 112, 4, 1} },
    { name = 'enemy:fairy_head_f', type = 'imggrp', args = {'enemy:fairy', 0, 224, 96, 128, 4, 1} },
    { name = 'enemy:fairy_arm_a', type = 'imggrp', args = {'enemy:fairy', 0, 352, 48, 64, 10, 1} },
    { name = 'enemy:fairy_arm_b', type = 'imggrp', args = {'enemy:fairy', 0, 416, 64, 80, 4, 1} },
    { name = 'enemy:fairy_body_a', type = 'imggrp', args = {'enemy:fairy', 0, 512, 192, 128, 4, 1} },
    { name = 'enemy:fairy_body_b', type = 'imggrp', args = {'enemy:fairy', 0, 640, 192, 128, 2, 1} },
    { name = 'enemy:fairy_body_c', type = 'imggrp', args = {'enemy:fairy', 768, 512, 256, 208, 1, 2} },
    { name = 'enemy:fairy_body_d', type = 'imggrp', args = {'enemy:fairy', 384, 640, 192, 128, 2, 1} },
    { name = 'enemy:fairy_body_e', type = 'imggrp', args = {'enemy:fairy', 0, 768, 160, 128, 2, 2} },
    { name = 'enemy:fairy_body_f', type = 'imggrp', args = {'enemy:fairy', 320, 768, 160, 128, 2, 2} },
    { name = 'enemy:fairy_wing_a', type = 'img', args = {'enemy:fairy', 608, 432, 80, 64} },
    { name = 'enemy:fairy_wing_b', type = 'img', args = {'enemy:fairy', 592, 208, 112, 224} },
    { name = 'enemy:fairy_wing_c', type = 'imggrp', args = {'enemy:fairy', 704, 208, 128, 192, 2, 1} },
    { name = 'enemy:fairy_wing_d', type = 'img', args = {'enemy:fairy', 704, 400, 96, 112} },
    { name = 'enemy:fairy_wing_e', type = 'img', args = {'enemy:fairy', 800, 400, 96, 112} },
    { name = 'enemy:fairy_wing_f', type = 'img', args = {'enemy:fairy', 896, 400, 96, 80} },
    { name = 'enemy:fairy_legs', type = 'imggrp', args = {'enemy:fairy', 640, 64, 32, 48, 12, 1} },
    { name = 'enemy:yinyang', type = 'imggrp', args = {'enemy:yinyang', 0, 0, 128, 128, 1, 6} },
    { name = 'enemy:yinyang_aura', type = 'imggrp', args = {'enemy:yinyang', 128, 0, 128, 128, 1, 6} },
}

function M.postLoad()
    for i = 1, 4 do
        lstg.SetImageCenter('enemy:fairy_head_a' .. i, 48, 88)
        lstg.SetImageScale('enemy:fairy_head_a' .. i, 0.25)
    end
    for i = 1, 2 do
        lstg.SetImageCenter('enemy:fairy_head_b' .. i, 64, 90)
        lstg.SetImageScale('enemy:fairy_head_b' .. i, 0.25)
    end
    for i = 1, 2 do
        lstg.SetImageCenter('enemy:fairy_head_c' .. i, 64, 90)
        lstg.SetImageScale('enemy:fairy_head_c' .. i, 0.25)
    end
    for i = 1, 2 do
        lstg.SetImageCenter('enemy:fairy_head_d' .. i, 64, 88)
        lstg.SetImageScale('enemy:fairy_head_d' .. i, 0.25)
    end
    for i = 1, 4 do
        lstg.SetImageCenter('enemy:fairy_head_e' .. i, 64, 84)
        lstg.SetImageScale('enemy:fairy_head_e' .. i, 0.25)
    end
    for i = 1, 4 do
        lstg.SetImageCenter('enemy:fairy_head_f' .. i, 48, 84)
        lstg.SetImageScale('enemy:fairy_head_f' .. i, 0.25)
    end
    for i = 1, 10 do
        lstg.SetImageCenter('enemy:fairy_arm_a' .. i, 6, 16)
        lstg.SetImageScale('enemy:fairy_arm_a' .. i, 0.25)
    end
    for i = 1, 4 do
        lstg.SetImageCenter('enemy:fairy_arm_b' .. i, 12, 18)
        lstg.SetImageScale('enemy:fairy_arm_b' .. i, 0.25)
    end
    for i = 1, 4 do
        lstg.SetImageCenter('enemy:fairy_body_a' .. i, 96, 32)
        lstg.SetImageScale('enemy:fairy_body_a' .. i, 0.25)
    end
    for i = 1, 2 do
        lstg.SetImageCenter('enemy:fairy_body_b' .. i, 96, 32)
        lstg.SetImageScale('enemy:fairy_body_b' .. i, 0.25)
    end
    for i = 1, 2 do
        lstg.SetImageCenter('enemy:fairy_body_c' .. i, 128, 94)
        lstg.SetImageScale('enemy:fairy_body_c' .. i, 0.25)
    end
    for i = 1, 2 do
        lstg.SetImageCenter('enemy:fairy_body_d' .. i, 96, 23)
        lstg.SetImageScale('enemy:fairy_body_d' .. i, 0.25)
    end
    for i = 1, 4 do
        lstg.SetImageCenter('enemy:fairy_body_e' .. i, 80, 32)
        lstg.SetImageScale('enemy:fairy_body_e' .. i, 0.25)
    end
    for i = 1, 4 do
        lstg.SetImageCenter('enemy:fairy_body_f' .. i, 80, 19)
        lstg.SetImageScale('enemy:fairy_body_f' .. i, 0.25)
    end
    lstg.SetImageCenter('enemy:fairy_wing_a', 5, 59)
    lstg.SetImageScale('enemy:fairy_wing_a', 0.25)
    lstg.SetImageCenter('enemy:fairy_wing_b', 5, 112)
    lstg.SetImageScale('enemy:fairy_wing_b', 0.25)
    for i = 1, 2 do
        lstg.SetImageCenter('enemy:fairy_wing_c' .. i, 18, 96)
        lstg.SetImageScale('enemy:fairy_wing_c' .. i, 0.25)
    end
    lstg.SetImageCenter('enemy:fairy_wing_d', 12, 100)
    lstg.SetImageScale('enemy:fairy_wing_d', 0.25)
    lstg.SetImageCenter('enemy:fairy_wing_e', 18, 88)
    lstg.SetImageScale('enemy:fairy_wing_e', 0.25)
    lstg.SetImageCenter('enemy:fairy_wing_f', 50, 8)
    lstg.SetImageScale('enemy:fairy_wing_f', 0.25)
    for i = 1, 12 do
        lstg.SetImageCenter('enemy:fairy_legs' .. i, 16, 0)
        lstg.SetImageScale('enemy:fairy_legs' .. i, 0.25)
    end

    for i = 1, 6 do
        lstg.SetImageScale('enemy:yinyang_aura' .. i, 0.5)
        lstg.SetImageScale('enemy:yinyang' .. i, 0.3)
    end
    lstg.SetImageScale('enemy:undefined', 0.8)
end


M.data = {
    fairy_data = {
        prefix = {'enemy:fairy_head_', 'enemy:fairy_arm_', 'enemy:fairy_body_', 'enemy:fairy_wing_', 'enemy:fairy_legs'},
        a = {
            {'a1', 'a1', 'a1', 'a', '1'},
            {'a2', 'a2', 'a2', 'a', '2'},
            {'a3', 'a3', 'a3', 'a', '3'},
            {'a4', 'a4', 'a4', 'a', '4'},
        },
        b = {
            {'b1', 'a1', 'b1', 'b', '1'},
            {'b2', 'a3', 'b2', 'b', '3'},
        },
        c = {
            {'c1', 'a5', 'c1', 'c1', '1'},
            {'c2', 'a6', 'c2', 'c2', '5'},
        },
        d = {
            {'d1', 'a1', 'd1', 'd', '1'},
            {'d2', 'a3', 'd2', 'd', '3'},
        },
        e = {
            {'e1', 'a7',  'e1', 'e', '6'},
            {'e2', 'a8',  'e2', 'e', '7'},
            {'e3', 'a9',  'e3', 'e', '8'},
            {'e4', 'a10', 'e4', 'e', '9'},
        },
        f = {
            {'f1', 'b1', 'f1', 'f', '1'},
            {'f2', 'b2', 'f2', 'f', '10'},
            {'f3', 'b3', 'f3', 'f', '11'},
            {'f4', 'b4', 'f4', 'f', '12'},
        },
    },
}

return M