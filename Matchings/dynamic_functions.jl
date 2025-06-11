
# to print out extracted values from worker and firm constraints
function print_shadow_prices(worker_constraints, firm_constraints)
    no_w = length(worker_constraints)
    no_f = length(firm_constraints)

    worker_value = zeros(no_w)
    firm_value = zeros(no_f)

    for i in 1:no_w
        worker_value[i] = shadow_price(worker_constraints[i])
    end

    for f in 1:no_f
        firm_value[f] = shadow_price(firm_constraints[f])
    end

    println("Worker values: ", round.(worker_value, digits=3))
    println("Firm values:   ", round.(firm_value, digits=3))
end



function solve_model(matrix, print_match = false, q = fill(1, size(matrix)[2]))
    no_w, no_f = size(matrix)[1], size(matrix)[2]

    model = Model(GLPK.Optimizer) 

    @variable(model, 0 <= μ[1:no_w, 1:no_f] <= 1)

    @objective(model, Max, sum(matrix[i,f] * μ[i,f] for i in 1:no_w, f in 1:no_f))

    worker = @constraint(model, [i=1:no_w], sum(μ[i,f] for f in 1:no_f) <= 1)
    firm = @constraint(model, [f=1:no_f], sum(μ[i,f] for i in 1:no_w) <= q[f])

    optimize!(model)
    μ_opt = value.(μ)
    print_match && display(μ_opt) 
    # print_shadow_prices(worker, firm)
    return μ_opt
end


function update_signal(signal, match)
    no_w, no_f = size(signal)[1], size(signal)[2]
    for i in 1:no_w, j in 1:no_f
        if match[i,j] == 1
            signal[i,j] = ability[i,j] #signal becomes true ablity as firms learn
        end
    end
end


function retention(signal, match)
    retention = []
    no_w, no_f = size(signal)[1], size(signal)[2]
    for worker in 1:no_w, firm in 1:no_f
        if match[worker, firm] == 1
            others = [signal[i, firm] for i in 1:no_w if match[i, firm] == 0]
            # println(signal[worker, firm], others)
            if signal[worker,firm] > quantile(others, 0.75)
                push!(retention, (worker,firm))
            end
        end
    end
    return retention 
end 


function mask(signal, retention_list)
    remove_row = [i[1] for i in retention_list]
    keep_row = [i for i in 1:size(signal)[1] if !(i in remove_row)]
    return signal[keep_row, :]
end 