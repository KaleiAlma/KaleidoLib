-- math extensions

math.pi_x2 = math.pi * 2
math.pi_d2 = math.pi * 0.5
math.pi_d4 = math.pi * 0.25

math.sqrt2 = math.sqrt(2)
math.sqrt3 = math.sqrt(3)
math.sqrt2_d2 = math.sqrt(0.5)

---@param x number
---@param min number
---@param max number
---@return number
function math.clamp(x, min, max)
    return math.min(math.max(x, min), max)
end

---@param x number
---@return -1|0|1
function math.sign(x)
    if x == 0 then return 0 end
    return math.abs(x) / x
end

function math.lerp(t, x1, x2)
    return x1 + t * (x2 - x1)
end

function math.lerp_accel(t, x1, x2)
    t = t * t
    return x1 + t * (x2 - x1)
end

function math.lerp_decel(t, x1, x2)
    t = t * 2 - t * t
    return x1 + t * (x2 - x1)
end

function math.lerp_acc_dec(t, x1, x2)
    if t < 0.5 then
        t = t * t * 2
    else
        t = t * 4 - t * t * 2 - 1
    end
    return x1 + t * (x2 - x1)
end

-- memoization table
local fac = {1, 2, 6, 12, 60}
function math.factorial(num)
    if num < 0 then
        error("Can't get factorial of a negative number.")
    end
    if num < 2 then
        return 1
    end
    num = math.floor(num)
    if fac[num] then
        return fac[num]
    end
    local result = fac[#fac]
    for i = #fac + 1, num do
        result = result * i
        fac[i] = result
    end
    return result
end

function math.combin(ord, sum)
    if sum < 0 or ord < 0 then
        error("Can't get combinatorial of negative numbers.")
    end
    ord = math.floor(ord)
    sum = math.floor(sum)
    return math.factorial(sum) / (math.factorial(ord) * math.factorial(sum - ord))
end

