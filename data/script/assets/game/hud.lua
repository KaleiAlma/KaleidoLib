local M = {}

M.resdesc = {
    { name = 'hud:bg', type = 'imgfile', args = {'hud/bg.png'} },
    { name = 'hud:elements', type = 'tex', args = {'hud/elements.png', true} },
    { name = 'hud:life', type = 'img', args = {'hud:elements', 0, 0, 128, 128} },
    { name = 'hud:bomb', type = 'img', args = {'hud:elements', 128, 0, 128, 128} },
    { name = 'hud:power', type = 'img', args = {'hud:elements', 256, 0, 128, 128} },
    { name = 'hud:point', type = 'img', args = {'hud:elements', 384, 0, 128, 128} },
    { name = 'hud:nonspell', type = 'img', args = {'hud:elements', 512, 0, 128, 128} },
    { name = 'hud:spell', type = 'img', args = {'hud:elements', 640, 0, 128, 128} },
    { name = 'hud:timeout', type = 'img', args = {'hud:elements', 768, 0, 128, 128} },
    { name = 'hud:lastspell', type = 'img', args = {'hud:elements', 896, 0, 128, 128} },
}

return M