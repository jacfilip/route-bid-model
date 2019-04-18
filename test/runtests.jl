using Pkg

Pkg.add("LightGraphs")
Pkg.add("SimpleWeightedGraphs")
Pkg.add("OpenStreetMapX")
Pkg.add("OpenStreetMapXPlot")
Pkg.add("DataFrames")
Pkg.add("DataFramesMeta")
Pkg.add("Distributions")
Pkg.add("CSV")
Pkg.add("Compose")

using Test
using OpenStreetMapX
using LightGraphs, SimpleWeightedGraphs
using DataFrames, DataFramesMeta
using Compose
using Distributions
using CSV
using DelimitedFiles

include("../src/decls.jl")
include("../src/Visuals.jl")
include("../src/osm_convert.jl")

nw = CreateNetworkFromFile(raw".\maps\buffaloF.osm")
Decls.SetSpawnAndDestPts!(nw, Decls.GetNodesOutsideRadius(nw,(-2000.,-2000.),4000.), Decls.GetNodesInRadius(nw,(-2000.,-2000.),2000.))

sim = Decls.Simulation(nw, 200.0, maxAgents = 1000)

@time Decls.RunSim(sim)

CSV.write(raw".\results\history.csv", sim.simData)
CSV.write(raw".\results\coords.csv", Decls.GetIntersectionCoords2(sim.network))
writedlm(raw".\results\log.txt", Decls.simLog, "\n")

pth = Vector{Int}()
from, to = 1, 1004

k = from
while k != to
    global k = dijkstra_shortest_paths(nw.graph,to).parents[k]
    push!(pth,k)
    if length(pth) > 2000
        break
    end
end

yen = LightGraphs.yen_k_shortest_paths(nw.graph,from,to,nw.graph.weights,3)
