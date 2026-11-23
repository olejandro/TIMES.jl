# TIMES.jl

A Julia implementation of the TIMES energy system optimization model, currently in prototype form.

After TIMES.jl is registered, install it with:

```julia
using Pkg
Pkg.add("TIMES")
```

Create a model from a TIMES SQLite input database:

```julia
using TIMES

model = create_model("path/to/input.db3")
```

`create_model` builds a JuMP optimization model; it does not select or run a solver. The repository includes a prototype database and a HiGHS demo that builds and solves it. To run the demo from the repository root:

```sh
julia --project=. -e "using Pkg; Pkg.instantiate()"
julia --project=. demo.jl
```

To profile the demo, first develop TIMES.jl into its separate profiling environment, then run the profile script from the repository root:

```sh
julia --project=profiling -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
julia --project=profiling profile.jl
```
