include("../algorithms/CD.jl")
include("../algorithms/functions.jl")
include("../algorithms/slackgon.jl")

using Random
using MAT

function multiple_slackgon_matrix(
    extrapoled::Bool = true)
    
    # Choice of random seed
    Random.seed!(2024)

    nb_tests = 10^5
    max_n = 12
    alpha = 0.99999
    file_path = "slack matrices of n-gons"
    open("results/$(file_path)/slackgon_matrix_extrapoled=$(extrapoled)_aplha=$(alpha)_n=12-9_10^5runs.txt", "w") do file
        for i in max_n:-1:9
            println("Matrix of size : ",i)
            write(file, "Matrix : $i x $i\n")
            M, _ = slackngon(i)
            for r in i-1:-1:i-3
                println("Rank : ",r)
                nb_good = 0
                best_error = Inf
                best_U = zeros(i,r)
                best_V = zeros(r,i)
                for _ in 1:nb_tests
                    U, V = init_matrix(M, r, "random")
                    if extrapoled
                        U, V = coordinate_descent_extrapoled(10000, M, U, V, alpha = alpha)
                    else
                        U, V = coordinate_descent(100000, M, U, V, alpha = alpha)
                    end
                    error = norm(M - (U * V).^2) / norm(M)
                    if error < norm(M - (best_U * best_V).^2) / norm(M)
                        best_U = copy(U)
                        best_V = copy(V)
                    end
                    if error < 1e-3
                        nb_good += 1
                    end
                    if error < best_error
                        best_error = error
                    end
                end
                accuracy = nb_good / nb_tests
                write(file, "accuracy for r = $r : $(accuracy*100)%\n")
                write(file, "best error for r = $r : $best_error\n")
                # Create a dictionary containing the matrices
                data_dict = Dict("bU" => best_U, "bV" => best_V)
                # Save the dictionary to a .mat file
                matwrite("results/slack matrices of n-gons/matrices/$(i)x$(i)_r=$(r)_best_error=$(best_error).mat", data_dict)
                #= if accuracy == 0
                    break
                end =#
            end
        end
    end
end

function multiple_slackgon_matrix_big_test(
    extrapoled::Bool = true)
    
    # Choice of random seed
    Random.seed!(2024)

    nb_tests = 10^8
    max_n = 9
    alpha = 1.0
    file_path = "slack matrices of n-gons"
    open("results/$(file_path)/slackgon_matrix_extrapoled=$(extrapoled)_aplha=$(alpha)_n=10_and_9_r=8.txt", "w") do file
        for i in max_n:-1:9
            println("Matrix of size : ",i)
            write(file, "Matrix : $i x $i\n")
            M, _ = slackngon(i)
            for r in 8:8
                println("Rank : ",r)
                nb_good = 0
                best_error = Inf
                best_U = zeros(i,r)
                best_V = zeros(r,i)
                start = time()
                tem_time = 1
                for _ in 1:nb_tests
                    U, V = init_matrix(M, r, "random")
                    if extrapoled
                        U, V = coordinate_descent_extrapoled(10000, M, U, V, alpha = alpha)
                    else
                        U, V = coordinate_descent(100000, M, U, V, alpha = alpha)
                    end
                    error = norm(M - (U * V).^2) / norm(M)

                    if error < norm(M - (best_U * best_V).^2) / norm(M)
                        best_U = copy(U)
                        best_V = copy(V)
                        if div(time()-start,14400) == 1
                            # Create a dictionary containing the matrices
                            data_dict = Dict("U" => best_U, "V" => best_V)
                            # Save the dictionary to a .mat file
                            matwrite("results/slack matrices of n-gons/matrices/$(i)x$(i)_r=$(r)_time=$(tem_time)_best_error=$((norm(M - (best_U * best_V).^2) / norm(M))).mat", data_dict)
                            write(file, "Error at $tem_time : $(norm(M - (best_U * best_V).^2) / norm(M))\n")
                            best_U = zeros(i,r)
                            best_V = zeros(r,i)
                            tem_time += 1
                            start = time()
                        end
                    end

                    if error < 1e-3
                        nb_good += 1
                    end

                    if error < best_error
                        best_error = error
                    end

                    if time()-start > 108000
                        break
                    end
                end
                accuracy = nb_good / nb_tests
                write(file, "At the end of the test:\n")
                write(file, "accuracy for r = $r : $(accuracy*100)%\n")
                write(file, "best error for r = $r : $best_error\n")
                # Create a dictionary containing the matrices
                data_dict = Dict("U" => best_U, "V" => best_V)
                # Save the dictionary to a .mat file
                matwrite("results/slack matrices of n-gons/matrices/$(i)x$(i)_r=$(r)_time=end_best_error=$((norm(M - (best_U * best_V).^2) / norm(M))).mat", data_dict)
                #= if accuracy == 0
                    break
                end =#
            end
        end
    end
end