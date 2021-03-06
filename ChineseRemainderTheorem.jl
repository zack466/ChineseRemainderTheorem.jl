struct Mod
    ## dividend (mod modulus) ##
    dividend::BigInt
    modulus::BigInt

    #ensure smallest positive dividend
    Mod(dividend, modulus) = new(mod(dividend,modulus), modulus)
end

function evaluate(m::Mod)
    #returns smallest solution that satisfies m
    return m.dividend
end

function evaluate(m::Mod,ur::UnitRange)
    #returns solutions that satisfy m (multiples of dividend)
    return [m.dividend + m.modulus * (x - 1) for x in ur]
end

function mod_equals(x::BigInt, m::Mod)
    #returns whether x satisfies m
    return m.dividend == mod(x,m.modulus)
end

function chinese_remainder_theorem(a::Mod,b::Mod)
    ## given a: x ≡ a mod m
    ## given b: x ≡ b mod n
    ## 
    ## c = n^-1 mod m
    ## d ≡ m^-1 mod n
    ##
    ## solution: (acn + bdm) mod mn
    try
        c = invmod(b.modulus, a.modulus)
        d = invmod(a.modulus,b.modulus)
        return Mod(a.dividend * c * b.modulus + b.dividend * d * a.modulus, a.modulus * b.modulus)
    catch
        @info "gcd of moduli must be 1"
        return nothing
    end
end

function chinese_remainder_theorem(arr::Array{Mod})
    #recursively solves for the solution for an array of mods
    
    @assert gcd([m.modulus for m in arr]) == 1 "gcd of moduli must be 1"
    #base case 1: one mod provided
    if length(arr) == 1
        return arr[1]
    #base case 2: two mods provided
    elseif length(arr) == 2
        return chinese_remainder_theorem(arr[1],arr[2])
    #recursive step: replaces first two mods in array with a single solution
    else
        first = chinese_remainder_theorem(arr[1],arr[2])
        newarr = vcat([first],arr[3:end])
        return chinese_remainder_theorem(newarr)
    end
end

function verify(x::BigInt, arr::Array{Mod})
    #verifies that integer x satisfies each mod in arr
    return all(m -> mod_equals(x,m), arr)
end

function verify(x::Mod, arr::Array{Mod})
    #verifies that all solutions to x also satisfy each mod in arr
    return all(m -> mod_equals(x.dividend,m), arr) && x.modulus == prod([m.modulus for m in arr])
end

function main()

    #test cases
    m1 = Mod(0,17)
    m2 = Mod(-11,37)
    m3 = Mod(-17,449)
    m4 = Mod(-25,23)
    m5 = Mod(-30,13)
    m6 = Mod(-36,19)
    m7 = Mod(-48,607)
    m8 = Mod(-58,41)
    m9 = Mod(-77,29)

    mods = [m1, m2, m3, m4, m5, m6, m7, m8, m9]
    solution = chinese_remainder_theorem(mods)

    println("Solution:")
    println(solution)
    println()

    println("Verify solution:")
    println(verify(solution, mods))
end

# main()
