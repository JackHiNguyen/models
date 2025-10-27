

function utility_gen(linear_guess, nonlinear_guess, 
                    product_char, price, n_consumer)::Matrix{Float64}
    alpha, beta = linear_guess[1], linear_guess[2]
    sigma = nonlinear_guess
    alpha_i = fill(alpha, n_consumer)
    noise = rand(n_consumer)
    beta_i = beta .+ sigma .* noise
    utility_matrix = beta_i' .* product_char .- alpha_i' .* price
    return utility_matrix
end;
# each row is a product
# each column is a consumer 

# For estimation 
function choice_prob(utility_matrix::Matrix{Float64})
    exp_u = exp.(utility_matrix)
    denom = sum(exp_u, dims=1)
    return exp_u ./ denom
end;
# each row is a product 
# each column is a cosumer

function predicted_share(utility_matrix::Matrix{Float64}, delta_guess::Vector{Float64})
    no_consumers = size(utility_matrix, 2)
    adjusted_utilities = utility_matrix .+ delta_guess[:, ones(Int, no_consumers)]
    choice_matrix = choice_prob(adjusted_utilities)
    pred_share = mean(choice_matrix, dims=2)
    pred_share = max.(pred_share, 1e-10)  # Prevent log(0)
    return vec(pred_share)
end; 
# should return one vector of shares all sum up to one 

function contraction_mapping(utility_matrix::Matrix{Float64}, observed_share::Vector{Float64}, tolerance::Float64)
    delta_guess = zeros(size(utility_matrix, 1))
    difference = 1
    while difference > tolerance
        predicted = predicted_share(utility_matrix, delta_guess)
        safe_obs = max.(observed_share, 1e-30)
        delta_new = delta_guess .+ log.(safe_obs) .- log.(predicted)
        difference = maximum(abs.(delta_new .- delta_guess))
        delta_guess = delta_new
    end
    return delta_guess
end;
# return an array of mean utilities deltas 

function mean_utility(input_df, sigma, linear_para, tolerance, n_cons)
    no_markets = length(unique(input_df.market_id))
    all_deltas = Float64[]
    for mkt in 0:no_markets-1
        market_data = input_df[input_df.market_id .== mkt, :]
        observed_share = market_data.share
        sim_utilities = utility_gen(linear_para, sigma, market_data.prod_char, market_data.price, n_cons)
        delta_mkt = contraction_mapping(sim_utilities, observed_share, tolerance)
        append!(all_deltas, delta_mkt)
        # print("done!", all_deltas)
    end
    return all_deltas
end

function estimate_parameter(input_df::DataFrame, instrument_name::Symbol, delta::Vector{Float64})
    X = Matrix(input_df[:, [:prod_char, :price]])
    Z = Matrix(input_df[:, [instrument_name, :price]])
    y = delta
    Pi = inv(Z' * Z) * (Z' * X)
    X_hat = Z * Pi
    θ = inv(X_hat' * X_hat) * (X_hat' * y)
    alpha_hat = -θ[2]
    beta_hat = θ[1]
    return alpha_hat, beta_hat
end
# return estimated linear parameters 
