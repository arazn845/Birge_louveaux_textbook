crops = [:wheat , :corn , :beets];
cost = Dict(:wheat=> 150 , :corn => 230 , :beets=>260);
land = 500
required = Dict(:wheat=> 200 , :corn => 240);
purchase_price = Dict(:wheat=> 238 , :corn => 210);
sell_price = Dict(:wheat=> 170 , :corn => 150 , :beets=> 36 , :extrabeets=> 10);
yield = Dict(:wheat=> 2.5 , :corn => 3 , :beets=>20);

m = Model(CPLEX.Optimizer)

@variable(m, 0 ≤ x[i in crops])
@variable(m, 0 ≤ y[i in setdiff(crops , [:beets] ) ])
@variable(m, 0 ≤ w[i in crops ∪ [:extrabeets] ])

@objective(m, Min, sum( x[i] * cost[i] for i in crops) +  
                    sum( y[i] * purchase_price[i] for i in setdiff( crops , [:beets] ) ) -
                    sum( w[i] * sell_price[i] for i in crops ∪ [:extrabeets] )
)

@constraint(m, c1, sum(x[i] for i in crops) ≤ land )

@constraint(m, c2_min_requirement[ i in setdiff(crops, [:beets])  ],  x[i] * yield[i] + y[i] - w[i] ≥ required[i]  )

@constraint(m, c3, w[:beets] ≤ 6000 )

@constraint(m, c4, w[:beets] + w[:extrabeets] ≤ yield[:beets] * x[:beets])

optimize!(m)
print(m)
println("wheat", " = ", value(x[:wheat])  )

[value(x[i]) for i in crops ]

for i in crops
    println( i , " = ", value(x[i]) )
end

for i in setdiff( crops, [:beets] )
    println("purchase of ", i , " = ", value(y[i]))
end

for i in crops ∪ [:extrabeets]
    println("sell of ", i, " = ", value(w[i]) )
end
    


