using Printf
using Glob
using CairoMakie
using FFMPEG_jll

function main()
    x = -π:0.01:π
    y = -2:0.01:2

    k = 2
    ω = 3

    Nf = 200
    for n in 1:Nf
        t = n/Nf * 10
        f = @. exp(-abs(y' - sin(k*x - ω*t))) + (1-sqrt(n/Nf))*randn()

        fig = Figure(size = (600, 400))
        ax = Axis(fig[1, 1]; xlabel = "x", ylabel = "y")
        hmap = heatmap!(ax, x, y, f)
        
        @info "Saving frame $n"
        save(@sprintf("frame%06d.png", n), fig)
    end

    return nothing
end

main()

FFMPEG_jll.ffmpeg() do exe
    run(`$exe -y -framerate 30 -i frame%06d.png -c:v libx264 -pix_fmt yuv420p test.mp4`)
end

rm.(glob("frame*.png"))
