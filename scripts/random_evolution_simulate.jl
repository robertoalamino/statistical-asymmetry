using Random

hamming(x, y) = sum(x .!= y)

function h_translations(grid)
    half_width = size(grid, 2) ÷ 2
    distances = [hamming(grid, circshift(grid, (0, shift)))
                 for shift in 0:half_width]
    return distances, half_width + 1
end

function v_translations(grid)
    half_height = size(grid, 1) ÷ 2
    distances = [hamming(grid, circshift(grid, (shift, 0)))
                 for shift in 0:half_height]
    return distances, half_height + 1
end

function h_reflections(grid)
    return [0, hamming(grid, reverse(grid; dims=1))], 2
end

function v_reflections(grid)
    return [0, hamming(grid, reverse(grid; dims=2))], 2
end

function rotations(grid)
    distances = zeros(Int, 4)
    rotated = grid
    for turn in 1:4
        rotated = rotl90(rotated)
        distances[turn] = hamming(grid, rotated)
    end
    return distances, 4
end

function statistical_asymmetry(grid, transform)
    distances, group_size = transform(grid)
    probabilities = [count(==(d), distances) / length(distances)
                     for d in unique(distances)]
    entropy = -sum(p -> p * log(p), probabilities)
    return (entropy / log(group_size)) * maximum(distances) / length(grid)
end

function life_step(grid)
    rows, cols = size(grid)
    next_grid = similar(grid)

    for col in 1:cols, row in 1:rows
        live_neighbours = 0
        for dc in -1:1, dr in -1:1
            if dr != 0 || dc != 0
                live_neighbours += grid[mod1(row + dr, rows), mod1(col + dc, cols)]
            end
        end
        next_grid[row, col] =
            live_neighbours == 3 || (grid[row, col] == 1 && live_neighbours == 2)
    end

    return next_grid
end

function check_life_step()
    horizontal = zeros(Int, 5, 5)
    horizontal[3, [5, 1, 2]] .= 1

    vertical = zeros(Int, 5, 5)
    vertical[2:4, 1] .= 1

    @assert life_step(horizontal) == vertical "Wrapped blinker failed at step 1"
    @assert life_step(vertical) == horizontal "Wrapped blinker failed at step 2"
end

function ghm_step(grid)
    rows, cols = size(grid)
    next_grid = similar(grid)

    for col in 1:cols, row in 1:rows
        state = grid[row, col]
        if state == 0
            excited_neighbour =
                grid[mod1(row - 1, rows), col] == 1 ||
                grid[mod1(row + 1, rows), col] == 1 ||
                grid[row, mod1(col - 1, cols)] == 1 ||
                grid[row, mod1(col + 1, cols)] == 1
            next_grid[row, col] = excited_neighbour ? 1 : 0
        elseif state == 1
            next_grid[row, col] = 2
        else
            next_grid[row, col] = 0
        end
    end

    return next_grid
end

function check_ghm_step()
    grid = zeros(Int, 5, 5)
    grid[1, 1] = 1
    grid[3, 3] = 2

    expected = zeros(Int, 5, 5)
    expected[1, 1] = 2
    expected[2, 1] = expected[5, 1] = 1
    expected[1, 2] = expected[1, 5] = 1

    @assert ghm_step(grid) == expected "Greenberg–Hastings update failed"
end

function simulate_random_evolution(runs, side, steps, states; update_grid=nothing)
    transforms = (
        h_translations,
        v_translations,
        h_reflections,
        v_reflections,
        rotations,
    )
    totals = zeros(length(transforms), steps)
    squared_totals = zeros(length(transforms), steps)

    for run in 1:runs
        grid = rand(0:(states - 1), side, side)

        for step in 1:steps
            for (row, transform) in enumerate(transforms)
                score = statistical_asymmetry(grid, transform)
                totals[row, step] += score
                squared_totals[row, step] += score^2
            end

            if step < steps
                grid = update_grid === nothing ? rand(0:(states - 1), side, side) :
                                                update_grid(grid)
            end
        end
    end

    return totals, squared_totals
end

length(ARGS) <= 2 ||
    error("Usage: random_evolution_simulate.jl [smoke|benchmark|full] [binary|ternary]")
mode = isempty(ARGS) ? "smoke" : ARGS[1]
model = length(ARGS) == 2 ? ARGS[2] : "binary"

model in ("binary", "ternary", "life", "ghm") ||
    error("Use binary, ternary, life, or ghm.")

states = model in ("ternary", "ghm") ? 3 : 2
figure = Dict(
    "binary" => "figure10",
    "ternary" => "figure08",
    "life" => "figure09",
    "ghm" => "figure07",
)[model]

update_grid = Dict("life" => life_step, "ghm" => ghm_step)
update_rule = get(update_grid, model, nothing)

if mode == "smoke"
    if model == "life"
        check_life_step()
        println("Game of Life wraparound blinker passed")
    elseif model == "ghm"
        check_ghm_step()
        println("Greenberg–Hastings wraparound and state transitions passed")
    end
end

configurations = Dict(
    "smoke"     => (runs=8, side=20, steps=10),
    "benchmark" => (runs=10, side=100, steps=100),
    "full"      => (runs=3000, side=100, steps=100),
)

haskey(configurations, mode) || error("Unknown mode '$mode'. Use smoke, benchmark, or full.")
runs, side, steps = configurations[mode]

Random.seed!(55)
println("Julia ", VERSION, " | ", mode, " | ", runs, " runs | ",
        side, " × ", side, " grid | ", steps, " recorded time points")

timed = @timed simulate_random_evolution(runs, side, steps, states; update_grid=update_rule)
totals, squared_totals = timed.value

@assert size(totals) == (5, steps)
@assert size(squared_totals) == (5, steps)
@assert all(isfinite, totals) && all(isfinite, squared_totals)
variance = squared_totals ./ runs .- (totals ./ runs).^2
@assert all(variance .>= -1e-12)
@assert all(totals[:, 1] .> 0) "Expected positive initial asymmetry for all five measurements"

output_dir = normpath(joinpath(@__DIR__, "..", "outputs", "$(figure)_$(mode)"))
mkpath(output_dir)

for (filename, values) in (("Bdata.txt", totals), ("VBdata.txt", squared_totals))
    open(joinpath(output_dir, filename), "w") do io
        for row in eachrow(values)
            println(io, join(row, "\t"))
        end
    end
end

println("Aggregate shapes: ", size(totals), " and ", size(squared_totals))
println("Simulation time: ", round(timed.time; digits=2), " seconds")
println("Wrote files to ", output_dir)