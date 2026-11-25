# TIMES.jl

[![codecov](https://codecov.io/github/olejandro/TIMES.jl/graph/badge.svg?token=L1J34EO0XW)](https://codecov.io/github/olejandro/TIMES.jl)

A Julia implementation of the [TIMES](https://github.com/etsap-TIMES/TIMES_model/) energy system optimization model, currently in prototype form.

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

`create_model` builds a JuMP optimization model, but it does not select or run a solver. The repository includes a prototype database and a demo that builds the model and solves it using HiGHS. The demo should be run from root using a separate profiling environment:

```sh
julia --project=profiling -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
julia --project=profiling demo.jl
```

To profile the demo, run the profile script from the repository root:

```sh
julia --project=profiling profile.jl
```
